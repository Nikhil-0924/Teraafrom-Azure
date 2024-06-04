terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "myrg" {
  name     = "myrg-resources1"
  location = "EAST US"
}

resource "azurerm_virtual_network" "vntf" {
  name                = "TF-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "subnet-az" {
  name                 = "sub-net-1"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.vntf.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_public_ip" "pub-ip" {
  name                     = "pubip-ip"
  resource_group_name = azurerm_resource_group.myrg.name
  location                 = azurerm_resource_group.myrg.location
  allocation_method        = "Dynamic"
}

resource "azurerm_network_interface" "net-it" {
  name                = "nikhil-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-az.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pub-ip.id

  }
}

resource "azurerm_linux_virtual_machine" "VirMac" {
  name                = "Vm-machine"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.net-it.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
