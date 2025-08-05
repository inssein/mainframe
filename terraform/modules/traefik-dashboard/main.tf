resource "kubernetes_service_v1" "traefik-dashboard" {
  metadata {
    name      = "traefik-dashboard"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/instance" = "traefik"
      "app.kubernetes.io/name"     = "traefik-dashboard"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "traefik"
      port        = 8080
      target_port = "traefik"
      protocol    = "TCP"
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
                number = 8080
              }
            }
          }
        }
      }
    }

    tls {
      hosts = ["traefik.internal.mnara.ca"]
    }
  }
}
