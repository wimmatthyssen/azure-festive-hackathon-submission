terraform {
  backend "azurerm" {
    resource_group_name  = "santawishlist-tf-state-rg"
    storage_account_name = "santawishlisttstate31094"
    container_name       = "tfstate"
    key                  = "santawishlist.terraform.tfstate"
  }
}
