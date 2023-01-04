resource "kubernetes_manifest" "cert-manager-issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      name      = "letsencrypt"
      namespace = "default"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "hussein@jafferjee.ca"
        privateKeySecretRef = {
          name = "letsencrypt-key"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "cloudflare"
                  key  = "api_token"
                }
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "cert-manager-mnara" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "mnara-ca"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-mnara-ca-tls"
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
      dnsNames = ["*.mnara.ca"]
    }
  }
}

# kubernetes doesn't seem to like using *.mnara.ca for *.internal.mnara.ca
# generate a new cert for internal dashboards
resource "kubernetes_manifest" "cert-manager-internal-mnara" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "internal-mnara-ca"
      namespace = "default"
    }
    spec = {
      secretName = "wildcard-internal-mnara-ca-tls"
      issuerRef = {
        name = "letsencrypt"
        kind = "Issuer"
      }
      dnsNames = ["*.internal.mnara.ca"]
    }
  }
}