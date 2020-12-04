resource "azurerm_resource_group" "hackathon" {
  for_each = var.app_locations
  name     = "${var.service_name}-${each.key}-rg"
  location = each.key
}