terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
  backend "local" {}
}

provider "azurerm" {
  resource_provider_registrations = "core"
  features {}
}

provider "azurerm" {
  resource_provider_registrations = "core"
  subscription_id                 = "de9f1f20-5a41-466c-867f-9191f5316e46"
  features {}
  alias = "hub"
}

module "solution" {
  source         = "../module"
  environment_id = "de9f1f20-5a41-466c-867f-9191f5316e46"
  name           = "dir-prod"
}
