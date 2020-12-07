output "acr_repository" {
  value = azurerm_container_registry.santawishlist.name
}

output "front_door_url" {
  value = azurerm_frontdoor.santawishlist.cname
}
