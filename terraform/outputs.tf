output "acr_repository_name" {
  value     = azurerm_container_registry.santawishlist.admin_username
  sensitive = true
}

output "traffic_manager_url" {
  value = "http://${azurerm_traffic_manager_profile.santawishlist.fqdn}"
}
