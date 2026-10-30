/* About 1:26 into the video, continue on soon, this is good stuff */

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
  tags     = local.common_tags
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

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-${var.env}-terraform-ltoa"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.region
  size                            = "Standard_B1s"
  disable_password_authentication = false
  admin_username                  = "adminuser"
  admin_password                  = data.azurerm_key_vault_secret.secret.value
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

data "azurerm_key_vault" "kv" {
  name                = "kv-prod-terraform-ltoa"
  resource_group_name = "rg-prod-terraform-ltoa"
}

data "azurerm_key_vault_secret" "secret" {
  name         = "vm-local-admin-default-pass"
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "firstaddressspace" {
  value = tolist(azurerm_virtual_network.vnet.address_space)[0]
}

output "vminfo" {
  value = {
    id                  = azurerm_linux_virtual_machine.vm.id
    name                = azurerm_linux_virtual_machine.vm.name
    location            = azurerm_linux_virtual_machine.vm.location
    resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
    ip                  = azurerm_network_interface.nic.private_ip_address
  }
}

output "vm_password" {
  value     = azurerm_linux_virtual_machine.vm.admin_password
  sensitive = true
}