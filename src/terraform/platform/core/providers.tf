terraform {
  required_version = "~> 1.11.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117.1"
    }
  }

  backend "azurerm" {
    environment          = "<provided-via-config>"
    use_azuread_auth     = true
    subscription_id      = "<provided-via-config>"
    resource_group_name  = "<provided-via-config>"
    storage_account_name = "<provided-via-config>"
    container_name       = "<provided-via-config>"
    key                  = "<provided-via-config>"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}