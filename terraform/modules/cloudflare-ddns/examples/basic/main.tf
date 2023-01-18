provider "kubernetes" {
  config_path = "~/.kube/config"
}

# since this is for testing, we are creating a fake secret
# in production, you would want to use something like a sealed secret
resource "kubernetes_secret_v1" "cf-secret" {
  metadata {
    name      = "cf-secret"
    namespace = var.namespace_name
  }

  data = {
    api-token = "SECRET"
  }
}

module "cloudflare-ddns-ha" {
  source                   = "../../"
  name                     = "identifier"
  namespace_name           = var.namespace_name
  host                     = "subdomain.example.com"
  cf_zone_id               = "9d13d3a6329627faab9c0a409f67a748"
  cf_record_id             = "3b51e921281be3e25c8a9838ec0efcfc"
  cf_api_token_secret_name = "cf-secret"
  cf_api_token_secret_key  = "api-token"

  # the following parameters are just for the unit testing
  cf_url   = var.cf_url
  schedule = "*/1 * * * *"
}
