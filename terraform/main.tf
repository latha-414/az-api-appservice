# Providers
provider "azurerm" {
  features {}
}

# Generate random suffix for unique names
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-policytest-dev"
  location = "East US"

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

# App Service Plan - Use B1 instead of F1 to avoid quota issues
resource "azurerm_service_plan" "main" {
  name                = "asp-policytest-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"  # Changed from F1 (Free) to B1 (Basic)

  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# Linux Web App - Fixed deprecated docker_image usage
resource "azurerm_linux_web_app" "main" {
  name                = "app-policytest-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    application_stack {
      docker_image = "${azurerm_container_registry.main.login_server}/myapp:latest"
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
  }

  tags = {
    Environment = "dev"
    Project     = "policytest"
  }
}

# Custom Policy Definition: Require Environment tag
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-environment-tag"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require Environment tag"

  policy_rule = jsonencode({
    if = {
      field = "tags['Environment']"
      exists = false
    }
    then = {
      effect = "deny"
    }
  })

  # Optional: description
  metadata = jsonencode({
    category = "Tags"
  })
}

# Assign policy to the resource group
resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-tags-assignment"
  resource_group_id    = azurerm_resource_group.main.id
  policy_definition_id = azurerm_policy_definition.require_tags.id

  # Optional: parameters or identity
}
