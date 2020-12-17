resource "azurerm_traffic_manager_profile" "main" {
  name                = "${var.service_name}${random_string.main.result}"
  resource_group_name = azurerm_resource_group.shared.name

  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "${var.service_name}${random_string.main.result}"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "https"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_endpoint" "main" {
  for_each            = var.app_locations
  name                = each.key
  resource_group_name = azurerm_resource_group.shared.name
  profile_name        = azurerm_traffic_manager_profile.main.name
  target_resource_id  = azurerm_app_service.main[each.key].id
  type                = "azureEndpoints"
  geo_mappings        = each.value.country_codes
}
