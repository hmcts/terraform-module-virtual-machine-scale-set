# Check the correct VM resource gets stood up for windows and linux machines

provider "azurerm" {
  features {}
  subscription_id = "64b1c6d6-1481-44ad-b620-d8fe26a2c768"
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
provider "azurerm" {
  features {}
  alias                      = "dcr"
  skip_provider_registration = "true"
  subscription_id            = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}
# Default variables for this test
variables {
  vm_name              = "example-vm"
  env                  = "nonprod"
  vm_admin_password    = "example-$uper-$EcUrE-password" # ideally from a secret store
  vm_size              = "D2ds_v5"
  vm_sku               = "Standard_D8ds_v5"
  vm_image_sku         = "2022-Datacenter"
  computer_name_prefix = "test-vm"
  vm_instances         = "2"
  vm_availabilty_zones = ["1"]
}


# The virtual machine Scale Set module depends on some external infrastructure that needs
# to be present before we can run a plan against it. The 'setup' run stands up
# a resource group, virtual network, subnet and common tags. I think setup
# needs to be applied in order to know the value of the outputs. This creates
# actual resources in azure, but they only last for the duration of the tests
# and are automatically destroyed at the end of the tests. This does mean that
# tests can't be run concurrently, so we will need to add some logic to the
# pipeline to prevent concurrent jobs.

run "setup" {
  module {
    source = "./tests/modules/setup"
  }
}

# The actual test infrastructure doesn't need to be applied. We can run
# assertions against the state created by a plan. The only exception is if we
# Need to test against values that are only known after an apply. This includes
# things like resource IDs, IP addresses and VM extensions.
run "linux_vm" {

  command = plan

  variables {
    vm_type           = "linux-scale-set"
    vm_publisher_name = "Canonical"
    vm_offer          = "UbuntuServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = run.setup.subnet,
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.linux_scale_set) == 1
    error_message = "Module did not stand up a linux virtual machine"
  }
  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.windows_scale_set) == 0
    error_message = "Module stood up a windows virtual machine"
  }
}

run "linux_vm_sensitivity" {

  command = plan

  variables {
    vm_type           = "Linux-scale-set"
    vm_publisher_name = "Canonical"
    vm_offer          = "UbuntuServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = run.setup.subnet,
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.linux_scale_set) == 1
    error_message = "Module did not stand up a linux virtual machine"
  }
  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.windows_scale_set) == 0
    error_message = "Module stood up a windows virtual machine"
  }
}

run "windows_vm" {

  command = plan

  variables {
    vm_type           = "windows-scale-set"
    vm_publisher_name = "MicrosoftWindowsServer"
    vm_offer          = "WindowsServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = run.setup.subnet,
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.linux_scale_set) == 0
    error_message = "Module stood up a linux virtual machine"
  }
  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.windows_scale_set) == 1
    error_message = "Module did not stand up a windows virtual machine"
  }
}

run "windows_vm_case_sensitivity" {

  command = plan

  variables {
    vm_type           = "Windows-scale-set"
    vm_publisher_name = "MicrosoftWindowsServer"
    vm_offer          = "WindowsServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = run.setup.subnet,
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }
  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.linux_scale_set) == 0
    error_message = "Module stood up a linux virtual machine"
  }
  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.windows_scale_set) == 1
    error_message = "Module did not stand up a windows virtual machine"
  }
}

run "unknown_vm" {

  command = plan

  variables {
    vm_type           = "Hannah Montanah Linux"
    vm_publisher_name = "MicrosoftWindowsServer"
    vm_offer          = "WindowsServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = run.setup.subnet,
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.linux_scale_set) == 0
    error_message = "Module stood up a linux virtual machine"
  }
  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.windows_scale_set) == 0
    error_message = "Module stood up a windows virtual machine"
  }

  expect_failures = [
    var.vm_type
  ]
}
