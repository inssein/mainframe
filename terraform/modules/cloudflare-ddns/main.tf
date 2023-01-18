resource "kubernetes_cron_job_v1" "cloudflare-ddns" {
  metadata {
    name      = "cloudflare-ddns-${var.name}"
    namespace = var.namespace_name
  }
  spec {
    schedule = var.schedule
    job_template {
      metadata {}
      spec {
        template {
          metadata {}
          spec {
            restart_policy = "OnFailure"
            container {
              name    = "cloudflare-ddns"
              image   = "curlimages/curl"
              command = [
                "sh",
                "-c",
                file("${path.module}/command.sh")
              ]
              env {
                name = "API_TOKEN"
                value_from {
                  secret_key_ref {
                    name     = var.cf_api_token_secret_name
                    key      = var.cf_api_token_secret_key
                    optional = false
                  }
                }
              }
              env {
                name  = "ZONE_ID"
                value = var.cf_zone_id
              }
              env {
                name  = "RECORD_ID"
                value = var.cf_record_id
              }
              env {
                name  = "NAME"
                value = var.host
              }
              env {
                name  = "CLOUDFLARE_URL"
                value = var.cf_url
              }
            }
          }
        }
      }
    }
  }
}