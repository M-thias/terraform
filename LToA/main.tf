terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.10.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "93d02abb-4791-4dae-a309-7d13fb489546"
  tenant_id       = "1c35a44e-5d03-4d18-953c-ba19e8d10bcf"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-ltoa"
  location = "East US"
  tags = {
    environment = "Development"
    mattymood = "good"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-ltoa"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16","10.1.0.0/16"]
  tags = {
    environment = "Development"
    mattymood = azurerm_resource_group.rg.tags.mattymood
  }
}

resource "azurerm_subnet" "sn" {
  name                 = "subnet-terraform-ltoa"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}