resource "azurerm_storage_account" "main" {
  for_each                 = var.app_locations
  name                     = "${var.app_name}${each.key}"
  resource_group_name      = azurerm_resource_group.main[each.key].name
  location                 = azurerm_resource_group.main[each.key].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}
