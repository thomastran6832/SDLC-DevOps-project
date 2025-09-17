output "vault_url" {
  description = "Vault server URL"
  value       = "http://vault.local"
}

output "vault_token" {
  description = "Vault root token"
  value       = "root"
  sensitive   = true
}