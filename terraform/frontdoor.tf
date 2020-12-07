resource "azurerm_frontdoor" "santawishlist" {
  name                                         = "${var.service_name}${random_string.santawishlist.result}"
  resource_group_name                          = azurerm_resource_group.shared.name
  enforce_backend_pools_certificate_name_check = false

  frontend_endpoint {
    name                              = "frontend1"
    host_name                         = "${var.service_name}${random_string.santawishlist.result}.azurefd.net"
    custom_https_provisioning_enabled = false
  }

  backend_pool_load_balancing {
    name = "lbSetting1"
  }

  backend_pool_health_probe {
    name = "probeSetting1"
  }

  dynamic "backend_pool" {
    for_each = azurerm_app_service.santawishlist
    content {
      name                = backend_pool.value.location
      load_balancing_name = "lbSetting1"
      health_probe_name   = "probeSetting1"
      backend {
        host_header = backend_pool.value.default_site_hostname
        address     = backend_pool.value.default_site_hostname
        http_port   = 80
        https_port  = 443
      }
    }
  }

  # Default routing rule for the primary region
  routing_rule {
    name               = "DefaultPrimary"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["frontend1"]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = azurerm_app_service.santawishlist[var.primary_region].location
    }
  }

  dynamic "routing_rule" {
    for_each = azurerm_app_service.santawishlist
    content {
      name               = routing_rule.value.location
      accepted_protocols = ["Http", "Https"]
      patterns_to_match = [
        "/${routing_rule.value.location}",
        "/${routing_rule.value.location}/*"
      ]
      frontend_endpoints = ["frontend1"]
      # Using redirection since forwarding the request won't work due to lack of websocket 
      # support via FrontDoor. The app does switch to LongPolling (HTTP) after 60s of 
      # loading the app, but this is not user friendly, or immediately obvious.
      redirect_configuration {
        custom_host       = routing_rule.value.default_site_hostname
        custom_path       = "/"
        redirect_protocol = "MatchRequest"
        redirect_type     = "Moved"
      }
    }
  }
}
