# Check names of VM NICs and IPConfig settings get computed and overridden properly

provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id            = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
  skip_provider_registration = true
}

provider "azurerm" {
  alias = "cnp"
  features {}
  subscription_id            = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  skip_provider_registration = true
}

# Default variables for this test
variables {
  env                  = "nonprod"
  vm_name              = "net-test"
  vm_admin_password    = "example-$uper-$EcUrE-password" # ideally from a secret store
  vm_type              = "windows"
  vm_publisher_name    = "MicrosoftWindowsServer"
  vm_offer             = "WindowsServer"
  vm_sku               = "2022-Datacenter"
  vm_version           = "latest"
  vm_size              = "D2ds_v5"
  vm_availabilty_zones = "1"
}

run "setup" {
  module {
    source = "./tests/modules/setup"
  }
}

run "calculated_nic_name" {

  command = plan

  variables {
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_network_interface.vm_nic.name == "net-test-nic"
    error_message = "NIC name does not match VM name"
  }
}

run "custom_nic_name" {

  command = plan

  variables {
    nic_name             = "my-nic-name"
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_network_interface.vm_nic.name == "my-nic-name"
    error_message = "NIC name was not overridden by var.nic_name"
  }
}

run "calculated_ipconfig_name" {

  command = plan

  variables {
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_network_interface.vm_nic.ip_configuration[0].name == "net-test-ipconfig"
    error_message = "IPConfig name does not match VM name"
  }
}

run "custom_ipconfig_name" {

  command = plan

  variables {
    ipconfig_name        = "my-ipconfig-name"
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_network_interface.vm_nic.ip_configuration[0].name == "my-ipconfig-name"
    error_message = "IPConfig name was not overridden by var.ipconfig_name"
  }
}
