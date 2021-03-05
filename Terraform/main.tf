# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.48"
    }
  } 
}

provider "azurerm" {
  features {}

}

#######data query###############
data "azurerm_image" "search" {
  name                = "myPackerImage"
  resource_group_name = "Nano-degree"
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resource-group"
  location            = var.location

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )

}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )



}

resource "azurerm_public_ip" "pubip" {
  name                = "${var.prefix}-pubip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"


tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}

resource "azurerm_lb" "lb" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.pubip.id
  }


tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}

resource "azurerm_lb_backend_address_pool" "back_address_pool" {
  name                = "${var.prefix}-backend-address-pool"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )



}

resource "azurerm_network_interface_backend_address_pool_association" "nic_address_pool" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "${var.prefix}-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.back_address_pool.id

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}


resource "azurerm_network_security_group" "security_group" {
  name                = "${var.prefix}-SecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "${var.prefix}-security_rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    

  }

  security_rule {
    name                       = "${var.prefix}-security_rule_vnet_only"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix       = "Internet"
    destination_address_prefix  = "VirtualNetwork"
    
  }

      security_rule {
      name                        = "${var.prefix}-allow_internal_vnet_access"
      priority                    = 102
      direction                   = "Inbound"
      access                      = "Allow"
      protocol                    = "*"
      source_port_range           = "*"
      destination_port_range      = "*"
      source_address_prefix       = "VirtualNetwork"
      destination_address_prefix  = "VirtualNetwork"

      }

tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}  

resource "azurerm_availability_set" "avset" {
  name                = "${var.prefix}-availset"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name


tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}

resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "${var.prefix}scaleset"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_F2"
  instances           = "${var.scalenum}"
  admin_username      = "${var.username}"
  admin_password      = "${var.password}"
  disable_password_authentication = false


  source_image_id = data.azurerm_image.search.id
  

network_interface {
    name    = "${var.prefix}-nic"

    primary = true

    ip_configuration {
      name      = "${var.prefix}-internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet.id

    }
  
}


  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }



tags = merge (
    local.common_tags,
    map(
      "owner", var.owner
    )
  )


}
