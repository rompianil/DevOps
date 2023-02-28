terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
}

#RG

resource "azurerm_resource_group" "rg" {
  name     = var.azurerm_resource_group-name
  location = var.location
}

#VNET

resource "azurerm_virtual_network" "vnet" {
  name                = var.azurerm_virtual_network-name
  address_space       = var.address_space 
  location            = var.location
  resource_group_name = var.azurerm_resource_group-name
}

#subnet

resource "azurerm_subnet" "subnet" {
  name                 = var.azurerm_subnet-name
  resource_group_name  = var.azurerm_resource_group-name
  virtual_network_name = var.azurerm_virtual_network-name
  address_prefixes     = var.address_prefixes
}

#NIC CARD

resource "azurerm_network_interface" "nic" {
  name                = var.azurerm_network_interface-name
  location            = var.location
  resource_group_name = var.azurerm_resource_group-name

  ip_configuration {
    name                          = var.ip_configuration
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = var.private_ip_address_allocation
  }
}

resource "azurerm_windows_virtual_machine" "vm-1" {
  name                = "testvm"
  resource_group_name = var.azurerm_resource_group-name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "rompi"
  admin_password      = "rompi@123"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}