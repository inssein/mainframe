variable "namespace_name" {
  type        = string
  default     = "default"
  description = "name of the k8s namespace to deploy the service to"
}

variable "cf_url" {
  type        = string
  default     = "https://api.cloudflare.com"
  description = "Cloudflare hostname (used for testing)"
}
