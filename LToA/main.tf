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
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-terraform-ltoa"
  location            = "East US"
  resource_group_name = "rg-terraform-ltoa"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}