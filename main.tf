resource "azurerm_windows_virtual_machine_scale_set" "windows_scale_set" {
  count                = lower(var.vm_type) == "windows-scale-set" ? 1 : 0
  name                 = var.vm_name
  resource_group_name  = var.vm_resource_group
  location             = var.vm_location
  sku                  = var.vm_sku
  instances            = var.vm_instances
  admin_username       = var.vm_admin_name
  admin_password       = var.vm_admin_password
  zones                = var.vm_availabilty_zones
  custom_data          = var.custom_data
  computer_name_prefix = var.computer_name_prefix
  upgrade_mode         = var.upgrade_mode

  tags = var.tags

  source_image_reference {
    publisher = var.vm_publisher_name
    offer     = var.vm_offer
    sku       = var.vm_image_sku
    version   = var.vm_version
  }

  os_disk {
    caching              = var.os_disk_type
    storage_account_type = var.os_disk_storage_account_type
  }

  dynamic "identity" {
    for_each = local.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "data_disk" {
    for_each = try(var.managed_disks, {})

    content {
      caching              = data_disk.value.disk_caching
      create_option        = try(data_disk.value.disk_create_option, null)
      disk_size_gb         = data_disk.value.disk_size_gb
      lun                  = data_disk.value.disk_lun
      storage_account_type = data_disk.value.storage_account_type

    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      name    = network_interface.value.name
      primary = network_interface.value.primary

      ip_configuration {
        name                                   = network_interface.value.ip_config_name
        primary                                = try(network_interface.value.primary, true)
        subnet_id                              = network_interface.value.subnet_id
        load_balancer_backend_address_pool_ids = network_interface.value.load_balancer_backend_address_pool_ids
        load_balancer_inbound_nat_rules_ids    = network_interface.value.load_balancer_inbound_nat_rules_ids
      }
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = try(var.automatic_os_upgrade_policy, {})
    content {
      disable_automatic_rollback  = automatic_os_upgrade_policy.value.disable_automatic_rollback
      enable_automatic_os_upgrade = automatic_os_upgrade_policy.value.enable_automatic_os_upgrade
    }
  }

  tags = var.tags
}


resource "azurerm_linux_virtual_machine_scale_set" "linux_scale_set" {
  count                = lower(var.vm_type) == "linux-scale-set" ? 1 : 0
  name                 = var.vm_name
  resource_group_name  = var.vm_resource_group
  location             = var.vm_location
  sku                  = var.vm_sku
  instances            = var.vm_instances
  admin_username       = var.vm_admin_name
  admin_password       = var.vm_admin_password
  zones                = var.vm_availabilty_zones
  custom_data          = var.custom_data
  computer_name_prefix = var.computer_name_prefix
  upgrade_mode         = var.upgrade_mode
  tags                 = var.tags
  source_image_reference {
    publisher = var.vm_publisher_name
    offer     = var.vm_offer
    sku       = var.vm_image_sku
    version   = var.vm_version
  }

  os_disk {
    caching              = var.os_disk_type
    storage_account_type = var.os_disk_storage_account_type
  }

  dynamic "identity" {
    for_each = local.identity
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }


  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      name    = network_interface.value.name
      primary = network_interface.value.primary

      ip_configuration {
        name                                   = network_interface.value.ip_config_name
        primary                                = try(network_interface.value.primary, true)
        subnet_id                              = network_interface.value.subnet_id
        load_balancer_backend_address_pool_ids = network_interface.value.load_balancer_backend_address_pool_ids
        load_balancer_inbound_nat_rules_ids    = network_interface.value.load_balancer_inbound_nat_rules_ids
      }
    }
  }

  dynamic "automatic_os_upgrade_policy" {
    for_each = try(var.automatic_os_upgrade_policy, {})
    content {
      disable_automatic_rollback  = automatic_os_upgrade_policy.value.disable_automatic_rollback
      enable_automatic_os_upgrade = automatic_os_upgrade_policy.value.enable_automatic_os_upgrade
    }
  }

  
}
