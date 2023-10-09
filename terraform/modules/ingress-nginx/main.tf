resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"

  # todo: move generation of certs into kubernetes stage
  set {
    name  = "controller.extraArgs.default-ssl-certificate"
    value = "default/wildcard-internal-mnara-ca-tls"
  }
}
