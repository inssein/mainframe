variable "name" {
  type        = string
  description = "Suffix for the cron job name."
}

variable "namespace_name" {
  type        = string
  default     = "default"
  description = "name of the k8s namespace to deploy the service to"
}

variable "schedule" {
  type        = string
  default     = "*/5 * * * *"
  description = "how often dns gets synchronized (cron format)"
}

variable "host" {
  type        = string
  description = "Domain name that needs to be updated"
}

variable "cf_zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "cf_record_id" {
  type        = string
  description = "Cloudflare Record ID"
}

variable "cf_api_token_secret_name" {
  type        = string
  description = "Name of the kubernetes secret containing the cloudflare api token"
}

variable "cf_api_token_secret_key" {
  type        = string
  description = "Key of the kubernetes secret containing the cloudflare api token"
}

variable "cf_url" {
  type        = string
  default     = "https://api.cloudflare.com"
  description = "Cloudflare hostname (used for testing)"
}