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
  subscription_id                 = "c813f663-9930-455f-9450-d0acf61942d9"
  features {}
  alias = "spoke1"
}

module "solution" {
  source         = "../module"
  environment_id = "c813f663-9930-455f-9450-d0acf61942d9"
  name           = "dir-dev"
}
