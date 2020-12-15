provider "azurerm" {
  version = "2.39"
  features {}
}

provider "github" {
  version = "4.1.0"
  token   = var.github_access_token
}
