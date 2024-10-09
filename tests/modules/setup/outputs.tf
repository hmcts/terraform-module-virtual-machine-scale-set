output "location" {
  value = azurerm_resource_group.test.location
}

output "resource_group" {
  value = azurerm_resource_group.test.name
}

output "subnet" {
  value = azurerm_subnet.test.id
}

output "common_tags" {
  value = module.common_tags.common_tags
}

