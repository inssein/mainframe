variable "name" {
  type        = string
  description = "Suffix for the cron job name."
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