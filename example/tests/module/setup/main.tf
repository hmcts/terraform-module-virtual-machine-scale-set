# only for use when building from ADO and as a quick example to get valid tags
# if you are building from Jenkins use `var.common_tags` provided by the pipeline
module "common_tags" {
  source = "github.com/hmcts/terraform-module-common-tags?ref=master"

  builtFrom   = "hmcts/terraform-module-virtual-machine"
  environment = "ptlsbox"
  product     = "sds-platform"
}

resource "azurerm_resource_group" "test" {
  name     = "vm-module-test-2-rg"
  location = "UK South"
}

resource "azurerm_virtual_network" "test" {
  name                = "vm-module-test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags                = module.common_tags.common_tags
}

resource "azurerm_subnet" "test" {
  name                 = "vm-module-test-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

provider "azurerm" {
  features {}
}
  
