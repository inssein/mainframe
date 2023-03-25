resource "kubernetes_manifest" "cloudflare-secret" {
  manifest = {
    apiVersion = "bitnami.com/v1alpha1"
    kind       = "SealedSecret"

    metadata = {
      name      = "cloudflare"
      namespace = "default"
    }

    spec = {
      template = {
        type = "Opaque"
        metadata = {
          name              = "cloudflare"
          namespace         = "default",
          creationTimestamp = "2022-12-29T12:21:28Z"
        }
      },
      encryptedData = {
        api_token = "AgCkoh1Sg4Ovc7N6XTWQ/5bXLca2VKMyh1IzTyfxTQlIeUYtS5fcNbOoJOqRRrzmhwB2b+3NpCGN2WfLt95xmZ7vCJFXpZpU9F0KrxWgLbqAFhHHa4XFGmNEW2LK4xUROBKw0E37tqFQLEFDesy0krxSXrEV6zk5Kc2GEdhXBdJjtbOMroUz9FLPBEREesI2O7bT5RE2Ul2XcuRsyyisCrXDI35ycMupCW4h2vgU6v8JFoZF1kMWKH7CS5Zs5+ZvHtuzR8T361FvuKzkK536cwV2l370Ey/+B5vByVGtwdsOSrB425KRb+tqKNnNDurBxzFsvvnwlebQjmNmA55Eebk3tJCAfanS3OwjOezcygeDRSABEz+6ulrLq6aH0F0yX5yR3ACy9RqQ0kcpMwkFh3GZSguKY5OebtYiKusouLRKXxD4m+35FNFph4Z0lE9RE3qMTClKyOrPbJaZKjgRswgAhskYk9wk8+JykHuj2t0d0jFl7eJsJnjfZlOUdGhnhPem+T9bzJBvq+LAPv3LVOUIuvnLUX1Jmc33KR2JZsLlBHSxwx2zXbz/aZ5pyJElFCfsGp8P+Rbx3J1rM5xRNmRFUvnza/O4PDl+O6rtNBAEOXqOcG8hcdMYRouko3BbAhKPl/9xH0zVL4N6rTSoRCgViudpGULdXau/Sueowo7EE1kcWIXKh9LmXtGzfY+7UPyBsadooXdC4fyNMYeUe1LTkGb93nxc82nRHL8jrraVYU6YHEcb5Es+"
      }
    }
  }
}

module "cloudflare-ddns-external-wildcard" {
  source                   = "../modules/cloudflare-ddns"
  name                     = "external-wildcard"
  host                     = "*.mnara.ca"
  cf_zone_id               = "9d13d3a6329627faab9c0a409f67a748"
  cf_record_id             = "3b51e921281be3e25c8a9838ec0efcfc"
  cf_api_token_secret_name = kubernetes_manifest.cloudflare-secret.manifest.metadata.name
  cf_api_token_secret_key  = "api_token"
}