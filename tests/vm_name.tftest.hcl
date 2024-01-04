# Check computer name of windows machines gets computed and overridden correctly

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
  vm_name              = "disk-test"
  vm_admin_password    = "example-$uper-$EcUrE-password"
  vm_type              = "windows-scale-set"
  vm_publisher_name    = "MicrosoftWindowsServer"
  vm_offer             = "WindowsServer"
  vm_sku               = "Standard_D8ds_v5"
  vm_version           = "latest"
  vm_size              = "D2ds_v5"
  vm_availabilty_zones = ["1"]
  vm_image_sku         = "2022-Datacenter"
  vm_instances         = "2"
  computer_name_prefix = "test-vm"

  network_interfaces = {
    nic0 = {
      name           = "test-nic-vmss-nonprod-uksouth-nic"
      primary        = true
      ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig"
    }
  }
}

run "setup" {
  module {
    source = "./tests/modules/setup"
  }
}

run "short_computer_name" {

  command = plan

  variables {
    vm_name           = "windows-scale-set"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name_prefix == "test-vm"
    error_message = "Computer name does not match var.vm_name"
  }
}

run "long_computer_name" {

  command = plan

  variables {
    vm_name           = "reallyreallylongvirtualmachinenamethatshouldgettruncated"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name_prefix == "reallyreallylon"
    error_message = "Computer name was not truncated to 15 characters"
  }
}

run "custom_computer_name" {

  command = plan

  variables {
    vm_name           = "example-vm"
    computer_name     = "actualname"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name_prefix == "test-vm"
    error_message = "Computer name was not overriden by var.computer_name"
  }
}
