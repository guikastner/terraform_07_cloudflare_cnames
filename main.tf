provider "cloudflare" {
  api_token = var.api_token
}

locals {
  # Arquivo JSON local (fora do git) com CNAMEs e redirecionamentos.
  # Se não existir, nada é criado — permite `tofu validate` no CI.
  dns_config = fileexists(var.dns_file) ? jsondecode(file(var.dns_file)) : {}

  raw_cnames    = try(local.dns_config.cnames, {})
  raw_redirects = try(local.dns_config.redirects, {})

  cnames = {
    for name, rec in local.raw_cnames :
    name => {
      label    = name
      hostname = name == "@" ? var.zone_name : "${name}.${var.zone_name}"
      target   = rec.target
      proxied  = tobool(try(rec.proxied, var.proxied))
      # TTL precisa ser 1 (automático) quando o registro é proxied
      ttl     = tobool(try(rec.proxied, var.proxied)) ? 1 : tonumber(try(rec.ttl, 1))
      comment = try(rec.comment, "Managed by OpenTofu")
    }
  }

  redirects = {
    for name, rec in local.raw_redirects :
    name => {
      label          = name
      hostname       = name == "@" ? var.zone_name : "${name}.${var.zone_name}"
      to             = trimsuffix(rec.to, "/")
      status_code    = tonumber(try(rec.status_code, 301))
      preserve_path  = tobool(try(rec.preserve_path, true))
      preserve_query = tobool(try(rec.preserve_query, true))
      comment        = try(rec.comment, "Redirect managed by OpenTofu")
    }
  }

  duplicated_labels = setintersection(keys(local.cnames), keys(local.redirects))
}

resource "cloudflare_record" "cname" {
  for_each = local.cnames

  zone_id = var.zone_id
  name    = each.value.label
  type    = "CNAME"
  content = each.value.target
  proxied = each.value.proxied
  ttl     = each.value.ttl
  comment = each.value.comment

  lifecycle {
    precondition {
      condition     = length(local.duplicated_labels) == 0
      error_message = "Subdomínios declarados em 'cnames' e 'redirects' ao mesmo tempo: ${join(", ", local.duplicated_labels)}."
    }
  }
}

# Registro "fantasma" proxied: só existe para o tráfego passar pela Cloudflare,
# onde a Redirect Rule responde antes de chegar a qualquer origem.
# CNAME não pode apontar para IP, por isso é um registro A.
resource "cloudflare_record" "redirect_host" {
  for_each = local.redirects

  zone_id = var.zone_id
  name    = each.value.label
  type    = "A"
  content = var.redirect_placeholder_ip
  proxied = true
  ttl     = 1
  comment = each.value.comment

  lifecycle {
    precondition {
      condition     = length(local.duplicated_labels) == 0
      error_message = "Subdomínios declarados em 'cnames' e 'redirects' ao mesmo tempo: ${join(", ", local.duplicated_labels)}."
    }

    precondition {
      condition     = can(regex("^https?://[^/\\s]+", each.value.to))
      error_message = "redirects.${each.key}.to deve ser uma URL http(s) absoluta."
    }

    precondition {
      condition     = contains([301, 302, 307, 308], each.value.status_code)
      error_message = "redirects.${each.key}.status_code deve ser 301, 302, 307 ou 308."
    }
  }
}

# A Cloudflare permite um único ruleset por fase na zona.
# Se já existir um criado pelo painel, importe-o antes do primeiro apply (ver README).
resource "cloudflare_ruleset" "redirects" {
  count = length(local.redirects) > 0 ? 1 : 0

  zone_id     = var.zone_id
  name        = "Redirects managed by OpenTofu"
  description = "Single Redirects gerados a partir de ${var.dns_file}"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  dynamic "rules" {
    for_each = local.redirects

    content {
      action      = "redirect"
      description = "${rules.value.hostname} -> ${rules.value.to}"
      enabled     = true
      expression  = "(http.host eq \"${rules.value.hostname}\")"

      action_parameters {
        from_value {
          status_code           = rules.value.status_code
          preserve_query_string = rules.value.preserve_query

          target_url {
            value      = rules.value.preserve_path ? null : rules.value.to
            expression = rules.value.preserve_path ? "concat(\"${rules.value.to}\", http.request.uri.path)" : null
          }
        }
      }
    }
  }

  depends_on = [cloudflare_record.redirect_host]
}
