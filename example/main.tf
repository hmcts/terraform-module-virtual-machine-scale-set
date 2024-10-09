module "windows-vm-ss" {

  source = "../"

  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }

  vm_type              = "windows-scale-set"
  vm_name              = "win-test-vmss"
  computer_name_prefix = "windatagw"
  vm_resource_group    = "update-management-center-test"
  vm_sku               = "Standard_D4ds_v5"
  vm_admin_password    = random_string.vm_password.result
  vm_availabilty_zones = ["1"]
  vm_publisher_name    = "MicrosoftWindowsServer"
  vm_offer             = "WindowsServer"
  vm_image_sku         = "2022-Datacenter"
  vm_version           = "latest"
  vm_instances         = 2
  subnet_id            = data.azurerm_subnet.subnet.id
  network_interfaces = {
    nic0 = { name = "win-test-vmss-nic",
      primary        = true,
      ip_config_name = "win-test-vmss-ipconfig",
    }
  }
  kv_name     = azurerm_key_vault.example-kv.name
  kv_rg_name  = azurerm_key_vault.example-kv.resource_group_name
  encrypt_ADE = true
  managed_disks = {
    datadisk1 = {
      storage_account_type = "Standard_LRS"
      disk_create_option   = "Empty"
      disk_size_gb         = "128"
      disk_lun             = "10"
      disk_caching         = "ReadWrite"
    }
  }

  upgrade_mode = "Automatic"
  automatic_os_upgrade_policy = {
    policy = {
      disable_automatic_rollback  = true,
      enable_automatic_os_upgrade = true
    }
  }
  tags = merge(module.ctags.common_tags, { expiresAfter = "3000-05-30" })
}


module "ctags" {
  source      = "git@github.com:hmcts/terraform-module-common-tags?ref=master"
  builtFrom   = "github.com/hmcts/testtest"
  environment = "sbox"
  product     = "mgmt"
}

resource "random_string" "vm_password" {
  length           = 16
  special          = true
  override_special = "#$%&@()_[]{}<>:?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

data "azurerm_subnet" "subnet" {
  name                 = "vm-subnet"
  resource_group_name  = "rdo-vnet-temp"
  virtual_network_name = "rdo-vnet-temp-vnet"
}


# just adding Keyvault here for testing purpose, its not needed by module
data "azurerm_subscription" "current" {
}

resource "azurerm_key_vault" "example-kv" {
  name                        = "example-kv-test-vmss"
  location                    = "uksouth"
  resource_group_name         = "update-management-center-test"
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_subscription.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

}
