/* resource "github_actions_secret" "acr_server" {
  repository      = var.github_repository
  secret_name     = "SANTAWISHLIST_ACR"
  plaintext_value = azurerm_container_registry.santawishlist.admin_username
}

resource "github_actions_secret" "acr_passowrd" {
  repository      = var.github_repository
  secret_name     = "SANTAWISHLIST_ACR_PASSWORD"
  plaintext_value = azurerm_container_registry.santawishlist.admin_password
}
 */
