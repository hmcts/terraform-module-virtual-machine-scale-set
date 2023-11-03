
data "azurerm_key_vault" "enc_kv" {
  count               = var.encrypt_ADE ? 1 : 0
  name                = var.kv_name
  resource_group_name = var.kv_rg_name
}

resource "azurerm_key_vault_key" "disk_enc_key" {
  count        = var.encrypt_ADE ? 1 : 0
  name         = "disk-encrypt-${var.vm_name}"
  key_vault_id = var.encrypt_ADE ? data.azurerm_key_vault.enc_kv[0].id : null
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "random_string" "password" {
  length  = 4
  special = false
}


resource "azurerm_virtual_machine_scale_set_extension" "vmextension" {
  count                        = var.encrypt_ADE ? 1 : 0
  name                         = "azure-disk-encrypt-${random_string.password.result}"
  virtual_machine_scale_set_id = var.vm_type == "linux-scale-set" ? azurerm_linux_virtual_machine_scale_set.linux_scale_set[0].id : azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].id
  publisher                    = "Microsoft.Azure.Security"
  type                         = var.vm_type == "linux-scale-set" ? "AzureDiskEncryptionForLinux" : "AzureDiskEncryption"
  type_handler_version         = var.vm_type == "linux-scale-set" ? "1.1" : "2.2"
  auto_upgrade_minor_version   = true

  settings = jsonencode({
    "EncryptionOperation"    = "EnableEncryption"
    "KeyEncryptionAlgorithm" = "RSA-OAEP"
    "KeyVaultURL"            = data.azurerm_key_vault.enc_kv[0].vault_uri
    "KeyVaultResourceId"     = data.azurerm_key_vault.enc_kv[0].id
    "KeyEncryptionKeyURL"    = azurerm_key_vault_key.disk_enc_key[0].id
    "KekVaultResourceId"     = data.azurerm_key_vault.enc_kv[0].id
    "VolumeType"             = "All"
  })

  #depends_on = [module.vm-bootstrap]
}

