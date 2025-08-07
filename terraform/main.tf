provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-policytest-dev"
  location = "Central India"
  
  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# Container Registry
resource "azurerm_container_registry" "main" {
  name                = "acrpolicytest${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
  
  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-policytest-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
  
  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-policytest-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  
  site_config {
    application_stack {
      docker_image     = "${azurerm_container_registry.main.login_server}/myapp"
      docker_image_tag = "latest"
    }
  }
  
  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.main.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.main.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.main.admin_password
  }
  
  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Simple Policy: Require Environment tag
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-environment-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Environment tag"
  
  policy_rule = jsonencode({
    if = {
      field  = "tags['Environment']"
      exists = "false"
    }
    then = {
      effect = "deny"
    }
  })
}

# Assign policy to resource group
resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-tags-assignment"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
}
