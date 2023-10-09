resource "kubernetes_deployment_v1" "whoami" {
  metadata {
    name      = var.name
    namespace = var.namespace_name
  }

  spec {
    replicas = var.num_replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
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
    name      = kubernetes_deployment_v1.whoami.metadata.0.name
    namespace = var.namespace_name
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
    name      = kubernetes_deployment_v1.whoami.metadata.0.name
    namespace = var.namespace_name
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      secret_name = var.tls_secret_name
    }

    rule {
      host = var.host
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
