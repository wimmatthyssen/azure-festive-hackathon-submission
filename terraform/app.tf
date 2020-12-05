resource "random_string" "santawishlist" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_container_registry" "santawishlist" {
  name                = "${var.service_name}${random_string.santawishlist.result}"
  resource_group_name = azurerm_resource_group.santawishlist["westeurope"].name
  location            = azurerm_resource_group.santawishlist["westeurope"].location
  sku                 = "Basic"
  admin_enabled       = true
  //georeplication_locations = keys(var.app_locations)
}

resource "azurerm_app_service_plan" "santawishlist" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-asp"
  location            = azurerm_resource_group.santawishlist[each.key].location
  resource_group_name = azurerm_resource_group.santawishlist[each.key].name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "santawishlist" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-app"
  location            = azurerm_resource_group.santawishlist[each.key].location
  resource_group_name = azurerm_resource_group.santawishlist[each.key].name
  app_service_plan_id = azurerm_app_service_plan.santawishlist[each.key].id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "connectionString"                    = azurerm_storage_account.santawishlist[each.key].primary_connection_string
    "storageContainerName"                = "wishLists"
  }
}
