provider "azurerm" {
  version = "2.39"
  features {}
}

provider "azuread" {
  version = "1.1.1"
}

provider "github" {
  version = "4.1.0"
  token   = var.github_access_token
}
