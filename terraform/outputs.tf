output "traffic_manager_url" {
  value = "http://${azurerm_traffic_manager_profile.santawishlist.fqdn}"
}
