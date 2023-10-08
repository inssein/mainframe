resource "helm_release" "home-bridge" {
  name       = "home-bridge"
  repository = "https://k8s-at-home.com/charts/"
  chart      = "homebridge"
  values     = [file("${path.module}/values.yaml")]
}
