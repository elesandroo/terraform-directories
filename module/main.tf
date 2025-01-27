terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.config.environment_id
}
provider "azurerm" {
  features {}
  alias           = "secnet"
  subscription_id = "27f42ee3-dc20-4595-9449-a8b3f88c47" # Used to retrieve data from other subscription
}

module "rg" {
  source = "git@github.com:Seyfor-CSC/mit.resource-group.git?ref=v2.0.0"
  config = [
    {
      name     = "mit-${var.config.name}-rg01"
      location = "westeurope"
    },
    {
      name     = "mit-${var.config.name}-rg02"
      location = "westeurope"
    }
  ]
}

module "vnet" {
  source          = "git@github.com:Seyfor-CSC/mit.virtual-network.git?ref=v2.0.0"
  subscription_id = var.config.environment_id
  config = [
    {
      name                = "mit-${var.config.name}-vnet01"
      address_space       = ["10.0.0.0/24"]
      resource_group_name = module.rg.outputs["mit-${var.config.name}-rg01"].name
      location            = "westeurope"
      subnets = [
        {
          name             = "mit-${var.config.name}-subnet01"
          address_prefixes = ["10.0.0.0/25"]
        }
      ]
    }
  ]
}

module "vm" {
  source = "git@github.com:Seyfor-CSC/mit.virtual-machine.git?ref=v2.0.0"
  config = [
    {
      os_type                         = "Windows"
      name                            = "mit${var.config.vm.name}vm01"
      location                        = "westeurope"
      resource_group_name             = module.rg.outputs["mit-${var.config.name}-rg01"].name
      size                            = var.config.vm.size
      admin_username                  = "adminuser"
      admin_password                  = "Password1234"
      disable_password_authentication = false
      computer_name                   = "mit${var.config.vm.name}vm01"
      os_disk = {
        name                 = "mit${var.config.vm.name}vm01-osdisk"
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }
      source_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-Datacenter"
        version   = "latest"
      }

      network_interfaces = [
        {
          name = "mit${var.config.vm.name}vm01-nic0"
          ip_configuration = [
            {
              name                          = "internal"
              subnet_id                     = module.vnet.outputs["mit-${var.config.name}-vnet01"].subnets["mit-${var.config.name}-subnet01"].id
              private_ip_address_allocation = "Dynamic"
            }
          ]
        }
      ]

      tags = {}
    }
  ]
}
