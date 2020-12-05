data "azuread_service_principal" "santawishlist" {
  display_name = "santawishlist"
}

resource "azurerm_role_assignment" "santawishlist" {
  for_each             = var.app_locations
  scope                = azurerm_resource_group.santawishlist[each.key].id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.santawishlist.id
}
