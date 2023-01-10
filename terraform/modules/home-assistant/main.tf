resource "helm_release" "home-assistant" {
  name       = "home-assistant"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "home-assistant"
  values     = [file("${path.module}/values.yaml")]
}
