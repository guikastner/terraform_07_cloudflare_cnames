output "cname_hostnames" {
  description = "CNAMEs criados: hostname => destino."
  value = {
    for _, rec in local.cnames : rec.hostname => rec.target
  }
}

output "redirects" {
  description = "Redirecionamentos ativos: hostname => URL de destino."
  value = {
    for _, rec in local.redirects : rec.hostname => {
      to            = rec.to
      status_code   = rec.status_code
      preserve_path = rec.preserve_path
    }
  }
}
