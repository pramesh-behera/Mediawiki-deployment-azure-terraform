
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure" {
  name     = "Az-ResourceGroup"
  location = "East Us"
}

resource "azurerm_virtual_network" "azure" {
  name                = "Az-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
}

resource "azurerm_subnet" "azure" {
  name                 = "Az-Subnet"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.azure.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "azure" {
  name                = "Az-PublicIp"
  resource_group_name = azurerm_resource_group.azure.name
  location            = azurerm_resource_group.azure.location
  allocation_method   = "Dynamic"
}
resource "azurerm_network_security_group" "azure" {
  name                = "Az-NSG"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "azure" {
  network_interface_id      = azurerm_network_interface.azure.id
  network_security_group_id = azurerm_network_security_group.azure.id
}
resource "tls_private_key" "azure_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.azure_ssh.private_key_pem
  sensitive = true
}

resource "azurerm_network_interface" "azure" {
  name                = "Az-Nic"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azure.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azure.id
  }
}

resource "azurerm_linux_virtual_machine" "azure" {
  name                = "Az-Virtualmachine"
  resource_group_name = azurerm_resource_group.azure.name
  location            = azurerm_resource_group.azure.location
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.azure.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.azure_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "8.0.20210422"
  }

  connection {
    type        = "ssh"
    user        = "adminuser"
    private_key = tls_private_key.azure_ssh.private_key_pem #file("./azureuser.pem")
    host        = self.public_ip_address
    port        = 22
  }

  provisioner "file" {
    source      = "automate.sh"
    destination = "/tmp/automate.sh"
  }
  provisioner "file" {
    source      = "apache-config.conf"
    destination = "/tmp/apache-config.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/automate.sh"
    ]
  }
}
