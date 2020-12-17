resource "random_string" "main" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_container_registry" "main" {
  name                     = "${var.app_name}${random_string.main.result}"
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = azurerm_resource_group.shared.location
  sku                      = "Premium"
  admin_enabled            = true
  georeplication_locations = [for l in keys(var.app_locations) : l if l != azurerm_resource_group.shared.location] # Replicate to all regions except for the location of the ACR
}

resource "azurerm_app_service_plan" "main" {
  for_each            = var.app_locations
  name                = "${var.app_name}-${each.key}-asp"
  location            = azurerm_resource_group.main[each.key].location
  resource_group_name = azurerm_resource_group.main[each.key].name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "main" {
  for_each            = var.app_locations
  name                = "${var.app_name}-${each.key}-app"
  location            = azurerm_resource_group.main[each.key].location
  resource_group_name = azurerm_resource_group.main[each.key].name
  app_service_plan_id = azurerm_app_service_plan.main[each.key].id

  app_settings = {
    "DOCKER_ENABLE_CI"                    = "true"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.main.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "connectionString"                    = azurerm_storage_account.main[each.key].primary_connection_string
    "storageContainerName"                = "wishLists"
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.main.login_server}/${var.app_name}:latest"
  }
}

resource "azurerm_monitor_autoscale_setting" "main" {
  for_each            = azurerm_app_service_plan.main
  name                = "${each.value.name}-scale-setting"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  target_resource_id  = each.value.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = each.value.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = each.value.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 50
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
