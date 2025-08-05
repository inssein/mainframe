module "cert-manager" {
  source = "../modules/cert-manager"
}

resource "kubernetes_manifest" "cloudflare-secret" {
  manifest = {
    apiVersion = "bitnami.com/v1alpha1"
    kind       = "SealedSecret"

    metadata = {
      name      = "cloudflare"
      namespace = "default"
    }

    spec = {
      template = {
        type = "Opaque"
        metadata = {
          name      = "cloudflare"
          namespace = "default"
        }
      },
      encryptedData = {
        api_token = "AgCz6gTzr2U9c1SDQggtrcmvGDwMNjqpGUq0rXyVtyrQqP8mu0Tj1HLZWBdQzArgO4NBbreMoK3E1cm9Ua3KnkZJcs82xy0kac6VOTxtWRjX360WTDr/S4GBG+T8MMK8MpQvdjYbThHAmGy+zCmxcpc2w21fRjoofAitSdQBEjC3zIUweORkgAx/qVanTH9jjC8TTeqG/2nTKs+LxkpvFWh6INdMf/sDmXD9gLweS8YhT7zUzklZKhqxeyR1P1GwP23E/CMtG+KWslhGn5Wz85lQ1rL8bJ6MQwx+0bjBOmNuD1WFakzx4SoRCdxysrlS/S9YndEwMC9nOYWxl0AxwXvxdC+I+uW+MEhgAQFVAUuEp9QaM7iL/NXy4ywH2nup5exUpYTe8hC5ZCK2Li/y0zEM4Gb6/sxgtuZ7BxJdJNNuRbv0QMm4NT7LCa6DLXlKO7DDuOviAH2eRPfIGYBWWVpY9z4TmYZPcDq46N4lhED7wj8B9UMlHBIoacYilMoJse02DCkkrB8v6ejiItCjY/gvdBX2BeKL/28uEQXzMvA+uADwrGn9Lhw1CbcSEycK5oVKONVyItc5NSKyPU/XzdqJQHWXRZSERyuR8k5FO422PpazRLIOefuPHnfHZdqrv0HQjuGGJ5YE879Rv4qFAC9OUbDctwzqwxyohJ0i6FPRW5b+GS6+E1Id3xsA1CUIC2s//Fk2jbcKgK27n8OvKuUkMkWeenxzqAHfp01CUbndX+zPdwrOj830"
      }
    }
  }
}

resource "kubernetes_manifest" "cert-manager-issuer" {
  depends_on = [module.cert-manager, kubernetes_manifest.cloudflare-secret]
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
  depends_on = [kubernetes_manifest.cert-manager-issuer]
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

resource "kubernetes_manifest" "cert-manager-internal-mnara" {
  depends_on = [kubernetes_manifest.cert-manager-issuer]
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

module "cloudflare-ddns-external-wildcard" {
  depends_on               = [kubernetes_manifest.cloudflare-secret]
  source                   = "../modules/cloudflare-ddns"
  name                     = "external-wildcard"
  host                     = "*.mnara.ca"
  cf_zone_id               = "9d13d3a6329627faab9c0a409f67a748"
  cf_record_id             = "3b51e921281be3e25c8a9838ec0efcfc"
  cf_api_token_secret_name = kubernetes_manifest.cloudflare-secret.manifest.metadata.name
  cf_api_token_secret_key  = "api_token"
}
