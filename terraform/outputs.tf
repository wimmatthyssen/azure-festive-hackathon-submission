output "acr_repository_name" {
  description = "Used by github actions to pass to the container build stage"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "traffic_manager_url" {
  value = "http://${azurerm_traffic_manager_profile.main.fqdn}"
}
