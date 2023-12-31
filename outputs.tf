output "vm_id" {
  value = var.vm_type == "windows-scale-set" ? azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].id : var.vm_type == "linux-scale-set" ? azurerm_linux_virtual_machine_scale_set.linux_scale_set[0].id : null
}

output "principal_id" {
  value = var.vm_type == "windows-scale-set" ? try(azurerm_windows_virtual_machine_scale_set.windows_scale_set[0].identity.0.principal_id, null) : var.vm_type == "linux-scale-set" ? try(azurerm_linux_virtual_machine_scale_set.linux_scale_set[0].identity.0.principal_id, null) : null
}
