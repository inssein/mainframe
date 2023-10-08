# todo: storage
resource "helm_release" "prometheus-stack" {
  name             = "prometheus-community"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  values           = [file("${path.module}/values.yaml")]
  namespace        = "monitoring"
  create_namespace = true
  version          = "51.3.0"
}

# expose longhorn metrics
# this took a long time to figure out because the service monitor was not being picked up
# turns out, we need to have the `release` label, based on:
# kubectl get prometheuses.monitoring.coreos.com -n monitoring -o jsonpath="{.items[*].spec.serviceMonitorSelector}"
resource "kubernetes_manifest" "longhorn-service-monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "longhorn-prometheus-servicemonitor"
      namespace = "monitoring"
      labels = {
        name    = "longhorn-prometheus-servicemonitor"
        release = "prometheus-community"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          app = "longhorn-manager"
        }
      }
      namespaceSelector = {
        matchNames = ["longhorn-system"]
      }
      endpoints = [
        {
          port = "manager"
        }
      ]
    }
  }
}
