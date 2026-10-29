variable "api_token" {
  description = "API token com permissões Zone:DNS:Edit e Zone:Single Redirect (ou Dynamic Redirect):Edit na zona."
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "ID da zona Cloudflare."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.zone_id))
    error_message = "zone_id deve ter 32 caracteres hexadecimais."
  }
}

variable "zone_name" {
  description = "Domínio raiz da zona (ex.: kastner.com.br)."
  type        = string
}

variable "proxied" {
  description = "Valor padrão de 'proxied' para CNAMEs. Pode ser sobrescrito por registro no JSON."
  type        = bool
  default     = true
}

variable "dns_file" {
  description = "Caminho do JSON com 'cnames' e 'redirects'. Não versionado; veja dns.example.json."
  type        = string
  default     = "dns.json"
}

variable "redirect_placeholder_ip" {
  description = "IP fictício dos registros A proxied usados só para redirecionamento (192.0.2.1 é o recomendado pela Cloudflare)."
  type        = string
  default     = "192.0.2.1"
}
