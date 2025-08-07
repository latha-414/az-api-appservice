output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.main.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.main.admin_password
  sensitive = true
}

output "app_service_name" {
  value = azurerm_linux_web_app.main.name
}

output "app_service_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}
