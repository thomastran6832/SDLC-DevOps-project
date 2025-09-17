# ArgoCD Module
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/name" = "argocd"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.8"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        domain = "argocd.local"
      }

      server = {
        extraArgs = ["--insecure"]
        service = {
          type = "NodePort"
          nodePortHttp = 30080
          nodePortHttps = 30443
        }
        ingress = {
          enabled = true
          hosts   = ["argocd.local"]
          tls     = false
        }
      }

      repoServer = {
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }

      applicationSet = {
        enabled = true
      }

      notifications = {
        enabled = true
      }

      configs = {
        secret = {
          argocdServerAdminPassword = "$2a$10$rRyBsGSHK6.uc8fntPwVIuLiM9TCCZmCGhfp3S1Kzb8g2T.5SMAW6" # admin
        }

        cm = {
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          "server.rbac.log.enforce.enable" = "false"
          "policy.default" = "role:readonly"
          "policy.csv" = <<-EOT
            p, role:admin, applications, *, */*, allow
            p, role:admin, certificates, *, *, allow
            p, role:admin, clusters, *, *, allow
            p, role:admin, repositories, *, *, allow
            g, argocd-admins, role:admin
          EOT
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Apply ArgoCD project and applications
resource "kubectl_manifest" "argocd_project" {
  yaml_body = file("${path.module}/../../../argocd/projects/pictshare-project.yaml")
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "pictshare_staging_app" {
  yaml_body = file("${path.module}/../../../argocd/applications/pictshare-staging.yaml")
  depends_on = [kubectl_manifest.argocd_project]
}

resource "kubectl_manifest" "pictshare_production_app" {
  yaml_body = file("${path.module}/../../../argocd/applications/pictshare-production.yaml")
  depends_on = [kubectl_manifest.argocd_project]
}