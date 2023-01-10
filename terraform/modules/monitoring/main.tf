# todo: storage
resource "helm_release" "prometheus-stack" {
  name             = "prometheus-community"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  values           = [file("${path.module}/values.yaml")]
  namespace        = "monitoring"
  create_namespace = true
}
