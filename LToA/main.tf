/* About one hour into the video, continue on soon, this is good stuff */

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

variable "env" {
  description = "Set Environment"
}

variable "region" {
  description = "Set Region"
  validation {
    condition     = contains(["eastus", "westus", "centralus"], replace(lower(var.region), " ", ""))
    error_message = "Region must be one of: East US, West US, Central US"
  }
}

locals {
  common_tags = {
    environment  = "Development"
    mattymood    = "good"
    owner        = "mrysse@outlook.com"
    costcenter   = "12345"
    creationtime = "2026-01-01T00:00:00Z"
    creator      = "mrysse@outlook.com"
    creatortype  = "user"
    region       = var.region
  }
  network_address = ["10.0.0.0/16", "10.1.0.0/16"]
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.env}-terraform-ltoa"
  location = var.region
  tags = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.env}-terraform-ltoa"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = local.network_address
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_subnet" "sn" {
  name                 = "subnet-${var.env}-terraform-ltoa"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}