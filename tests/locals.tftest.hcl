# Tests the evil, evil nested ternary operator in the interpolated-defaults.tf file.

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

run "no_identity" {

  command = plan

  variables {
    vm_resource_group = run.setup.resource_group
    vm_subnet_id      = run.setup.subnet
    tags              = run.setup.common_tags

    systemassigned_identity   = false
    userassigned_identity_ids = []
  }

  assert {
    condition     = length(local.identity) == 0
    error_message = "Identity block is not empty when no identities were specified"
  }
}

run "system_identity" {

  command = plan

  variables {
    vm_resource_group = run.setup.resource_group
    vm_subnet_id      = run.setup.subnet
    tags              = run.setup.common_tags

    systemassigned_identity   = true
    userassigned_identity_ids = []
  }

  assert {
    condition     = length(local.identity) == 1
    error_message = "Identity block is empty when a system assigned identity was specified"
  }
  assert {
    condition     = local.identity.identity.type == "SystemAssigned"
    error_message = "Wrong type of identities were specified"
  }
  assert {
    condition     = length(local.identity.identity.identity_ids) == 0
    error_message = "Identity IDs were specified when using only system assigned identity"
  }
}

run "user_identity" {

  command = plan

  variables {
    vm_resource_group = run.setup.resource_group
    vm_subnet_id      = run.setup.subnet
    tags              = run.setup.common_tags

    systemassigned_identity = false
    userassigned_identity_ids = [
      "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userAssignedIdentityValue1",
      "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userAssignedIdentityValue2"
    ]
  }

  assert {
    condition     = length(local.identity) == 1
    error_message = "Identity block is empty when user assigned identities were specified"
  }
  assert {
    condition     = local.identity.identity.type == "UserAssigned"
    error_message = "Wrong type of identities were specified"
  }
  assert {
    condition     = length(local.identity.identity.identity_ids) == 2
    error_message = "Wrong number of Identity IDs were specified when using user assigned identity"
  }
}

run "both_identities" {

  command = plan

  variables {
    vm_resource_group = run.setup.resource_group
    vm_subnet_id      = run.setup.subnet
    tags              = run.setup.common_tags

    systemassigned_identity = true
    userassigned_identity_ids = [
      "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userAssignedIdentityValue3",
      "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userAssignedIdentityValue4",
      "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/example-resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/userAssignedIdentityValue5"
    ]
  }

  assert {
    condition     = length(local.identity) == 1
    error_message = "Identity block is empty when system and user assigned identities were specified"
  }
  assert {
    condition     = local.identity.identity.type == "SystemAssigned, UserAssigned"
    error_message = "Wrong type of identities were specified"
  }
  assert {
    condition     = length(local.identity.identity.identity_ids) == 3
    error_message = "Wrong number of Identity IDs were specified when using system and user assigned identities"
  }
}
