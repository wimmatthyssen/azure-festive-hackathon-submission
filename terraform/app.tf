resource "azurerm_container_registry" "hackathon" {
  name                     = "${var.service_name}acr"
  resource_group_name      = azurerm_resource_group.hackathon["westeurope"].name
  location                 = azurerm_resource_group.hackathon["westeurope"].location
  sku                      = "Basic"
  admin_enabled            = true
  //georeplication_locations = keys(var.app_locations)
}

/* resource "azurerm_container_registry_webhook" "hackathon" {
  name                = azurerm_container_registry.hackathon.name
  registry_name       = azurerm_container_registry.hackathon.name
  resource_group_name = azurerm_resource_group.hackathon["westeurope"].name
  location            = azurerm_resource_group.hackathon["westeurope"].location

  service_uri = "https://mywebhookreceiver.example/mytag"
  status      = "enabled"
  scope       = "mytag:*"
  actions     = ["push"]
  custom_headers = {
    "Content-Type" = "application/json"
  }
} */

resource "azurerm_app_service_plan" "hackathon" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-asp"
  location            = azurerm_resource_group.hackathon[each.key].location
  resource_group_name = azurerm_resource_group.hackathon[each.key].name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "hackathon" {
  for_each            = var.app_locations
  name                = "${var.service_name}-${each.key}-app"
  location            = azurerm_resource_group.hackathon[each.key].location
  resource_group_name = azurerm_resource_group.hackathon[each.key].name
  app_service_plan_id = azurerm_app_service_plan.hackathon[each.key].id

  app_settings = {
    "DOCKER_ENABLE_CI" = true
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.hackathon.admin_password
    "DOCKER_REGISTRY_SERVER_URL" = "https://${azurerm_container_registry.hackathon.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.hackathon.admin_username
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "connectionString" = azurerm_storage_account.hackathon[each.key].primary_connection_string
    "storageContainerName" = "wishLists"
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.hackathon.name}/edazhackathon-app:latest"
  }

  lifecycle {
    ignore_changes = [
      "site_config[0].linux_fx_version", # deployments are made outside of Terraform
    ]
  }
}