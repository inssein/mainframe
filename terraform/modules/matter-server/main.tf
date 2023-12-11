resource "kubernetes_persistent_volume_claim" "matter-server-claim" {
  metadata {
    name = "matter-server-data"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_service" "matter-server" {
  metadata {
    name = "matter-server"
  }

  spec {
    type = "ClusterIP"

    port {
      name        = "http"
      port        = 5580
      target_port = "http"
    }

    selector = {
      "app.kubernetes.io/name" = "matter-server"
    }
  }
}

resource "kubernetes_deployment" "matter-server" {
  metadata {
    name = "matter-server"
  }

  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "matter-server"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "matter-server"
        }
        annotations = {
          "container.apparmor.security.beta.kubernetes.io/matter-server" : "unconfined"
        }
      }

      spec {
        container {
          image = "ghcr.io/home-assistant-libs/python-matter-server:5.0.3"
          name  = "matter-server"
          port {
            name           = "http"
            container_port = 5580
            protocol       = "TCP"
          }
          volume_mount {
            mount_path = "/data"
            name       = "matter-server-data"
          }
          volume_mount {
            mount_path = "/run/dbus"
            name       = "bluetooth"
            read_only  = true
          }
          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW", "SYS_ADMIN"]
            }
            privileged = true
          }
        }
        host_network = true
        volume {
          name = "matter-server-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.matter-server-claim.metadata.0.name
          }
        }
        volume {
          name = "bluetooth"
          host_path {
            path = "/run/dbus"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "matter-server" {
  metadata {
    name = "matter-server"
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      secret_name = "wildcard-internal-mnara-ca-tls"
    }

    rule {
      host = "matter.internal.mnara.ca"
      http {
        path {
          backend {
            service {
              name = "matter-server"
              port {
                number = 5580
              }
            }
          }
        }
      }
    }
  }
}
