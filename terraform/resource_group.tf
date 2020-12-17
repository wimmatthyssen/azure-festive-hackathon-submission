resource "azurerm_resource_group" "shared" {
  name     = "${var.app_name}-shared-rg"
  location = var.primary_region
}

resource "azurerm_resource_group" "main" {
  for_each = var.app_locations
  name     = "${var.app_name}-${each.key}-rg"
  location = each.key
}
