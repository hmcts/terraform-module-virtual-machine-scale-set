variable "vm_type" {
  type        = string
  description = "The type of the vm scale set, either windows-scale-set or linux-scale-set"
}

variable "vm_name" {
  type        = string
  description = "The name of the Virtual Machine Scale Set"
}

variable "vm_resource_group" {
  type        = string
  description = "The name of the resource group to deploy the virtual Machine Scale Set in."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the VMSS going to deploy"
}

variable "vm_admin_password" {
  type        = string
  sensitive   = true
  description = "The Admin password for the virtual Machine Scale Set."
}
variable "env" {
  description = "Environment name"
  type        = string
}
variable "vm_publisher_name" {
  type        = string
  description = "The publiser of the marketplace image to use."
}

variable "vm_offer" {
  type        = string
  description = "The offer of the marketplace image to use."
}

variable "vm_sku" {
  type        = string
  description = "The Virtual Machine Scale Set SKU for the Scale Set, check allowed sku here https://tools.hmcts.net/confluence/display/DACS/D.1k+Azure+SKU+Standards+-+In+progress "

  validation {
    condition     = strcontains(var.vm_sku, "D2ds_v5") || strcontains(var.vm_sku, "D4ds_v5") || strcontains(var.vm_sku, "D8ds_v5") || strcontains(var.vm_sku, "D16ds_v5") || strcontains(var.vm_sku, "D32ds_v5") || strcontains(var.vm_sku, "E2ds_v5") || strcontains(var.vm_sku, "E4ds_v5") || strcontains(var.vm_sku, "E8ds_v5") || strcontains(var.vm_sku, "E16ds_v5") || strcontains(var.vm_sku, "E32ds_v5")
    error_message = "The vm_sku value must be a valid sku, check allowed sku here https://tools.hmcts.net/confluence/display/DACS/D.1k+Azure+SKU+Standards+-+In+progress "
  }
}

variable "vm_image_sku" {
  type        = string
  description = "The SKU of the image to use."
}


variable "vm_version" {
  type        = string
  description = "The version of the image to use."
}

variable "vm_availabilty_zones" {
  type        = list(any)
  description = "The availability zones to deploy the VM in"
}

variable "network_interfaces" {
  description = "One or more network_interface can be set here, at least one of the network_interface have to be primary"
}
variable "vm_instances" {
  type        = number
  description = "Number of VM instances required"
}


variable "computer_name_prefix" {
  type        = string
  description = "Enter Computer name prefix, it should be not more than 9 characters"
}
variable "tags" {
  type        = map(string)
  description = "The tags to apply to the virtual Machine Scale Set and associated resources."
}

