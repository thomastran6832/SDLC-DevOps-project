# Vault Module
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      "app.kubernetes.io/name" = "vault"
    }
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.25.0"
  namespace  = kubernetes_namespace.vault.metadata[0].name

  values = [
    yamlencode({
      server = {
        dev = {
          enabled = true
          devRootToken = "root"
        }
        service = {
          type = "NodePort"
          nodePort = 30820
        }
        ingress = {
          enabled = true
          hosts = [{
            host = "vault.local"
            paths = ["/"]
          }]
        }
      }

      ui = {
        enabled = true
        serviceType = "NodePort"
      }

      injector = {
        enabled = true
      }
    })
  ]

  depends_on = [kubernetes_namespace.vault]
}