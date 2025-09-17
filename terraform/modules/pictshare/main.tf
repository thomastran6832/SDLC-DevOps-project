# PictShare Module

# GitLab Registry Secret for staging
resource "kubernetes_secret" "gitlab_registry_staging" {
  metadata {
    name      = "gitlab-registry-secret"
    namespace = "pictshare-staging"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.gitlab.com" = {
          username = "thomastran6832"
          password = "your-gitlab-token"
          auth     = base64encode("thomastran6832:your-gitlab-token")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.pictshare_staging]
}

# GitLab Registry Secret for production
resource "kubernetes_secret" "gitlab_registry_production" {
  metadata {
    name      = "gitlab-registry-secret"
    namespace = "pictshare-production"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "registry.gitlab.com" = {
          username = "thomastran6832"
          password = "your-gitlab-token"
          auth     = base64encode("thomastran6832:your-gitlab-token")
        }
      }
    })
  }

  depends_on = [kubernetes_namespace.pictshare_production]
}

# Reference to namespaces
resource "kubernetes_namespace" "pictshare_staging" {
  metadata {
    name = "pictshare-staging"
    labels = {
      "app.kubernetes.io/name" = "pictshare"
      "environment" = "staging"
    }
  }
}

resource "kubernetes_namespace" "pictshare_production" {
  metadata {
    name = "pictshare-production"
    labels = {
      "app.kubernetes.io/name" = "pictshare"
      "environment" = "production"
    }
  }
}