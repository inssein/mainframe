resource "helm_release" "uptime-kuma" {
  name       = "uptime-kuma"
  repository = "https://dirsigler.github.io/uptime-kuma-helm"
  chart      = "uptime-kuma"
  values     = [file("${path.module}/values.yaml")]
  version    = "2.21.2"
}
