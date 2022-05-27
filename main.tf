resource "azurerm_resource_group" "rg" {
	name = "bookRg"
	location = "West Europe"
	tags {
		environment = "Terraform Azure"
	}
}

resource "azurerm_virtual_network" "vnet" {
	name = "book-vnet"
	location = "West Europe"
	address_space = ["10.0.0.0/16"]
	resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet" {
	name = "book-subnet"
	virtual_network_name = azurerm_virtual_network.vnet.name 
	resource_group_name = azurerm_resource_group.rg.name
	address_prefix = "10.0.10.0/24"
}

resource "azure_network_interface" "nic" {
	name = "book-nic"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.rg.name
	ip_configuration {
		name = "bookipconfig"
		subnet_id = azurerm_subnet.subnet.id
		private_ip_address_allocation = "Dynamic"
		public_ip_address_id = azurerm_public_ip.pip.id
	}
}

resource "azure_public_ip" "pip" {
	name = "book-ip"
	location = "West Europe"
	resource_group_name = "${azurerm_resource_group.rg.name}"
	public_ip_address_allocation = "Dynamic"
	domain_name_label = "bookdevops"
}

resource "azure_storage_account" "stor" {
	name = "bookstor"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.rg.name
	account_tier = "Standard"
	account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "vm" {
	name = "bookvm"
	location = "West Europe"
	resource_group_name = azurerm_resource_group.rg.name 
	vm_size = "Standard_Ds1_v2"
	network_interface_ids = ["${azure_network_interface.nic.id}"]
	storage_image_reference {
		publisher = "Canonical"
		offer = "UbuntuServer"
		sku = "16.04-LTS"
		version = "latest"
	}
....
}
