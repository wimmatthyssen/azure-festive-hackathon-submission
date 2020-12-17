resource "random_string" "santawishlist" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_container_registry" "santawishlist" {
  name                     = "${var.service_name}${random_string.santawishlist.result}"
  resource_group_name      = azurerm_resource_group.shared.name
  location                 = azurerm_resource_group.shared.location
  sku                      = "Premium"
  admin_enabled            = true
  georeplication_locations = keys(var.app_locations)
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
    "DOCKER_ENABLE_CI"                    = "true"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${azurerm_container_registry.santawishlist.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = azurerm_container_registry.santawishlist.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = azurerm_container_registry.santawishlist.admin_password
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "connectionString"                    = azurerm_storage_account.santawishlist[each.key].primary_connection_string
    "storageContainerName"                = "wishLists"
  }

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.santawishlist.login_server}/santawishlist:latest"
  }
}

resource "azurerm_monitor_autoscale_setting" "santawishlist" {
  for_each            = azurerm_app_service_plan.santawishlist
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
