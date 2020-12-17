variable "app_name" {
  type        = string
  description = "Application name"
  default     = "santawishlist"
}

variable "primary_region" {
  type        = string
  description = "Azure region to act as a 'Primary' region for the shared resource group. This will contain the Traffic Manager and Azure Container Registry."
  default     = "westeurope"
}

variable "app_locations" {
  type        = map
  description = "Configuration map for each app deployment."
  default = {
    westeurope = {
      country_codes = ["NL"]
    },
    northeurope = {
      country_codes = ["IE"]
    },
    uksouth = {
      country_codes = ["GB"]
    }
  }
}
