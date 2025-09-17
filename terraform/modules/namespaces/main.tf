# Namespaces Module
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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "monitoring"
    }
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
    labels = {
      "app.kubernetes.io/name" = "vault"
    }
  }
}