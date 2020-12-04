resource "azurerm_storage_account" "hackathon" {
  for_each                 = var.app_locations
  name                     = "${var.service_name}${each.key}"
  resource_group_name      = azurerm_resource_group.hackathon[each.key].name
  location                 = azurerm_resource_group.hackathon[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}