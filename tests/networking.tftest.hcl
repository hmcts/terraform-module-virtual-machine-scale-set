# Check names of VM NICs and IPConfig settings get computed and overridden properly

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
      name           = "test-nic-vmss-nonprod-uksouth-nic",
      primary        = true,
      ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
      subnet_id                              = "/subscriptions/64b1c6d6-1481-44ad-b620-d8fe26a2c768/resourceGroups/vm-module-scale-set-test-rg/providers/Microsoft.Network/virtualNetworks/vm-module-test-vnet/subnets/vm-module-test-subnet",
      load_balancer_backend_address_pool_ids = [],
      load_balancer_inbound_nat_rules_ids    = []
    }
  }
}

run "setup" {
  module {
    source = "./tests/modules/setup"
  }
}

run "calculated_nic_name" {

  command = plan

  variables {
    vm_resource_group = run.setup.resource_group
    subnet_id         = run.setup.subnet
    tags              = run.setup.common_tags
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].network_interface[0].name == "test-nic-vmss-nonprod-uksouth-nic"
    error_message = "NIC name does not match VM name"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].network_interface[0].ip_configuration[0].name == "test-nic-vmss-nonprod-uksouth-ipconfig"
    error_message = "IPConfig name does not match VM name"
  }
}


run "calculated_nic_linux_name" {

  command = plan


  variables {
    vm_type           = "linux-scale-set"
    vm_publisher_name = "MicrosoftWindowsServer"
    vm_offer          = "WindowsServer"
    vm_sku            = "Standard_D8ds_v5"
    vm_version        = "latest"
    vm_resource_group = run.setup.resource_group
    
    tags              = run.setup.common_tags
    network_interfaces = {
      nic0 = { name = "test-nic-vmss-nonprod-uksouth-nic",
        primary        = true,
        ip_config_name = "test-nic-vmss-nonprod-uksouth-ipconfig",
        subnet_id      = "/subscriptions/64b1c6d6-1481-44ad-b620-d8fe26a2c768/resourceGroups/vm-module-scale-set-test-rg/providers/Microsoft.Network/virtualNetworks/vm-module-test-vnet/subnets/vm-module-test-subnet",
        load_balancer_backend_address_pool_ids = [],
        load_balancer_inbound_nat_rules_ids    = []
      }
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_scale_set[0].network_interface[0].name == "test-nic-vmss-nonprod-uksouth-nic"
    error_message = "NIC name does not match VM name"
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.linux_scale_set[0].network_interface[0].ip_configuration[0].name == "test-nic-vmss-nonprod-uksouth-ipconfig"
    error_message = "IPConfig name does not match VM name"
  }
}

