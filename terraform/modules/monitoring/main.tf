# Monitoring Module
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "54.0.1"
  namespace  = "monitoring"

  values = [
    yamlencode({
      grafana = {
        adminPassword = "admin123"
        service = {
          type = "NodePort"
          nodePort = 30300
        }
        ingress = {
          enabled = true
          hosts   = ["grafana.local"]
        }
      }

      prometheus = {
        service = {
          type = "NodePort"
          nodePort = 30900
        }
        ingress = {
          enabled = true
          hosts   = ["prometheus.local"]
        }
      }

      alertmanager = {
        service = {
          type = "NodePort"
          nodePort = 30930
        }
      }
    })
  ]

  create_namespace = false
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "monitoring"
    }
  }
}