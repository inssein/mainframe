resource "kubernetes_service_v1" "traefik-dashboard" {
  metadata {
    name      = "traefik-dashboard"
    namespace = "kube-system"
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "traefik"
      port        = 9000
      target_port = 9000
    }

    selector = {
      "app.kubernetes.io/name" = "traefik"
    }
  }
}

resource "kubernetes_ingress_v1" "traefik-ingress" {
  metadata {
    name      = "traefik-ingress"
    namespace = "kube-system"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "traefik.internal.mnara.ca"
      http {
        path {
          backend {
            service {
              name = "traefik-dashboard"
              port {
                number = 9000
              }
            }
          }
        }
      }
    }

    tls {
      secret_name = "wildcard-mnara-ca-tls"
    }
  }
}