/* resource "azurerm_app_service_plan" "example" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-asp"
  location            = azurerm_resource_group.hackathon[each.key]location
  resource_group_name = azurerm_resource_group.hackathon[each.key].name

  sku {
    tier = "Standard"
    size = "S1"
  }
} */

/* resource "azurerm_app_service" "example" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-service"
  location            = azurerm_resource_group.hackathon.location
  resource_group_name = azurerm_resource_group.hackathon.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
} */