resource "azurerm_resource_group" "shared" {
  name     = "${var.service_name}-shared-rg"
  location = var.primary_region
}

resource "azurerm_resource_group" "santawishlist" {
  for_each = var.app_locations
  name     = "${var.service_name}-${each.key}-rg"
  location = each.key
}
