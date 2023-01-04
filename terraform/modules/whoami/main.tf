resource "kubernetes_deployment_v1" "whoami" {
  metadata {
    name = "whoami"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "whoami"
      }
    }

    template {
      metadata {
        labels = {
          app = "whoami"
        }
      }

      spec {
        container {
          image = "containous/whoami:v1.5.0"
          name  = "whoami"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "whoami" {
  metadata {
    name = kubernetes_deployment_v1.whoami.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment_v1.whoami.metadata.0.name
    }
    type = "ClusterIP"
    port {
      port        = 5678
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "whoami" {
  metadata {
    name = kubernetes_deployment_v1.whoami.metadata.0.name
  }

  spec {
    ingress_class_name = "traefik"

    tls {
      secret_name = "wildcard-mnara-ca-tls"
    }

    rule {
      host = "home.mnara.ca"
      http {
        path {
          backend {
            service {
              name = kubernetes_deployment_v1.whoami.metadata.0.name
              port {
                number = 5678
              }
            }
          }

          path      = "/bar"
          path_type = "Prefix"
        }

        path {
          backend {
            service {
              name = kubernetes_deployment_v1.whoami.metadata.0.name
              port {
                number = 5678
              }
            }
          }

          path      = "/foo"
          path_type = "Prefix"
        }
      }
    }
  }
}