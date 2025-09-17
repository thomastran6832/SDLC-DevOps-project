# Complete DevOps Platform - Main Terraform Configuration
terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

# Namespaces
module "namespaces" {
  source = "./modules/namespaces"
}

# ArgoCD
module "argocd" {
  source = "./modules/argocd"
  depends_on = [module.namespaces]
}

# HashiCorp Vault
module "vault" {
  source = "./modules/vault"
  depends_on = [module.namespaces]
}

# Monitoring Stack
module "monitoring" {
  source = "./modules/monitoring"
  depends_on = [module.namespaces]
}

# PictShare Application
module "pictshare" {
  source = "./modules/pictshare"
  depends_on = [module.namespaces, module.vault]
}

# Outputs
output "argocd_server_url" {
  description = "ArgoCD server URL"
  value       = module.argocd.server_url
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = module.monitoring.grafana_url
}

output "vault_url" {
  description = "Vault server URL"
  value       = module.vault.vault_url
}