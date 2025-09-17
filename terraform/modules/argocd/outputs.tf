output "server_url" {
  description = "ArgoCD server URL"
  value       = "http://argocd.local"
}

output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}