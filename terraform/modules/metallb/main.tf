resource "kubernetes_namespace" "metallb-system" {
  metadata {
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }

    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  depends_on = [kubernetes_namespace.metallb-system]
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "metallb-system"
  version    = "0.14.9"
}

resource "kubernetes_manifest" "ip_address_pool" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default-pool"
      namespace = "metallb-system"
    }
    spec = {
      addresses = ["192.168.0.50-192.168.0.60"]
    }
  }
}

resource "kubernetes_manifest" "l2_advertisement" {
  depends_on = [helm_release.metallb]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default-pool"
      namespace = "metallb-system"
    }
  }
}
