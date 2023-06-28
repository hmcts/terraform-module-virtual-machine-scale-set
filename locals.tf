locals {

  identity = var.systemassigned_identity == true || length(var.userassigned_identity_ids) > 0 ? { identity = { type = (var.systemassigned_identity && length(var.userassigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : !var.systemassigned_identity && length(var.userassigned_identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"), identity_ids = var.userassigned_identity_ids } } : {}
}
