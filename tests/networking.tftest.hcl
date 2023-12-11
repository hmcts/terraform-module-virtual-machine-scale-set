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
