resource "helm_release" "home-assistant" {
  name       = "home-assistant"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "home-assistant"
  values     = [templatefile("${path.module}/values.yaml", {})]
}
