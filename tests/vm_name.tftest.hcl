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

run "short_computer_name" {

  command = plan

  variables {
    vm_name              = "shortname"
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name == "shortname"
    error_message = "Computer name does not match var.vm_name"
  }
}

run "long_computer_name" {

  command = plan

  variables {
    vm_name              = "reallyreallylongvirtualmachinenamethatshouldgettruncated"
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name == "reallyreallylon"
    error_message = "Computer name was not truncated to 15 characters"
  }
}

run "custom_computer_name" {

  command = plan

  variables {
    vm_name              = "exampls-vm"
    computer_name        = "actualname"
    vm_resource_group    = run.setup.resource_group
    subnet_id            = run.setup.subnet
    vm_image_sku         = run.setup.vm_image
    network_interfaces   = run.setup.network_interfaces
    vm_instances         = run.setup.vm_instances
    computer_name_prefix = run.setup.computer_name_prefix
    tags                 = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].computer_name == "actualname"
    error_message = "Computer name was not overriden by var.computer_name"
  }
}
