# terraform-module-virtual-machine-scale-set
This module will allow you to deploy Linux or Windows virtual machine Scale Set on Azure.


## Example
```terraform
module "windows-vm-ss" {
  source = "../"

  vm_type              = "windows-scale-set"
  vm_name              = "win-test-vmss"
  computer_name_prefix = "windatagw"
  vm_resource_group    = "update-management-center-test"
  vm_sku               = "Standard_D4ds_v5"
  vm_admin_password    = random_string.vm_password.result
  vm_availabilty_zones = ["1"]
  vm_publisher_name = "MicrosoftWindowsServer"
  vm_offer          = "WindowsServer"
  vm_image_sku      = "2022-Datacenter"
  vm_version        = "latest"
  vm_instances = 2
  network_interfaces = {
    nic0 = { name = "win-test-vmss-nic",
      primary        = true,
      ip_config_name = "win-test-vmss-ipconfig",
    subnet_id = data.azurerm_subnet.subnet.id }
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
  tags = merge(module.ctags.common_tags, { expiresAfter = "3000-05-30" })
}
```
An example can be found [here](https://github.com/hmcts/terraform-module-virtual-machine-scale-set/tree/main/example).
<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vm-bootstrap"></a> [vm-bootstrap](#module\_vm-bootstrap) | git::https://github.com/hmcts/terraform-module-vm-bootstrap.git | master |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_key.disk_enc_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_linux_virtual_machine_scale_set.linux_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_virtual_machine_scale_set_extension.vmextension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_scale_set_extension) | resource |
| [azurerm_windows_virtual_machine_scale_set.windows_scale_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set) | resource |
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_key_vault.enc_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accelerated_networking_enabled"></a> [accelerated\_networking\_enabled](#input\_accelerated\_networking\_enabled) | Enable accelerated networks on the NIC for the virtual machine. | `bool` | `false` | no |
| <a name="input_additional_script_name"></a> [additional\_script\_name](#input\_additional\_script\_name) | The path to a script to run against the virtual machine. | `string` | `null` | no |
| <a name="input_additional_script_uri"></a> [additional\_script\_uri](#input\_additional\_script\_uri) | URI of a publically accessible script to run against the virtual machine. | `string` | `null` | no |
| <a name="input_automatic_os_upgrade_policy"></a> [automatic\_os\_upgrade\_policy](#input\_automatic\_os\_upgrade\_policy) | A map of automatic\_os\_upgrade\_policy policy | <pre>map(<br>    object(<br>      {<br>        disable_automatic_rollback  = bool,<br>        enable_automatic_os_upgrade = bool<br>      }<br>    )<br>  )</pre> | `{}` | no |
| <a name="input_boot_diagnostics_enabled"></a> [boot\_diagnostics\_enabled](#input\_boot\_diagnostics\_enabled) | Whether to enable boot diagnostics. | `bool` | `true` | no |
| <a name="input_boot_storage_uri"></a> [boot\_storage\_uri](#input\_boot\_storage\_uri) | The URI of the storage to use for boot diagnostics. | `string` | `null` | no |
| <a name="input_computer_name_prefix"></a> [computer\_name\_prefix](#input\_computer\_name\_prefix) | Enter Computer name prefix, it should be not more than 9 characters | `string` | n/a | yes |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Custom data to pass to the virtual machine. | `string` | `null` | no |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | The ID of a custom image to use. | `string` | `""` | no |
| <a name="input_custom_script_extension_name"></a> [custom\_script\_extension\_name](#input\_custom\_script\_extension\_name) | Overwrite custom script extension name label in bootstrap module. | `string` | `"HMCTSVMBootstrap"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS servers to use, will override DNS servers set at the VNET level | `list(string)` | `null` | no |
| <a name="input_dynatrace_hostgroup"></a> [dynatrace\_hostgroup](#input\_dynatrace\_hostgroup) | The hostgroup to place the virtual machine in within DynaTrace | `string` | `""` | no |
| <a name="input_dynatrace_server"></a> [dynatrace\_server](#input\_dynatrace\_server) | The Dynatrace ActiveGate server URL. | `string` | `""` | no |
| <a name="input_dynatrace_tenant_id"></a> [dynatrace\_tenant\_id](#input\_dynatrace\_tenant\_id) | The Dynatrace tenant ID. | `string` | `""` | no |
| <a name="input_dynatrace_token"></a> [dynatrace\_token](#input\_dynatrace\_token) | The token to use when communicating with the Dynatrace ActiveGate. | `string` | `""` | no |
| <a name="input_encrypt_ADE"></a> [encrypt\_ADE](#input\_encrypt\_ADE) | Encrypt the disks using Azure Disk Encryption. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"ENTER_ENVIRONMENT"` | no |
| <a name="input_install_azure_monitor"></a> [install\_azure\_monitor](#input\_install\_azure\_monitor) | Install Azure Monitor on the virtual machine. | `bool` | `false` | no |
| <a name="input_install_dynatrace_oneagent"></a> [install\_dynatrace\_oneagent](#input\_install\_dynatrace\_oneagent) | Install dynatrace oneagent on the virtual machine. | `bool` | `false` | no |
| <a name="input_install_splunk_uf"></a> [install\_splunk\_uf](#input\_install\_splunk\_uf) | Insall splunk uniforwarder on the virtual machine. | `bool` | `false` | no |
| <a name="input_ipconfig_name"></a> [ipconfig\_name](#input\_ipconfig\_name) | The name of the IPConfig to asssoicate with the NIC. | `string` | `null` | no |
| <a name="input_kv_name"></a> [kv\_name](#input\_kv\_name) | The name ofthe KeyVault used to store the customer-managed key. | `string` | `null` | no |
| <a name="input_kv_rg_name"></a> [kv\_rg\_name](#input\_kv\_rg\_name) | The name of the resource group, containing the KeyVault used to store the customer-managed key. | `string` | `null` | no |
| <a name="input_managed_disks"></a> [managed\_disks](#input\_managed\_disks) | A map of managed disks to create & attach to the virtual machine. | <pre>map(<br>    object(<br>      {<br>        storage_account_type = string,<br>        disk_create_option   = string,<br>        disk_size_gb         = string,<br>        disk_lun             = string,<br>        disk_caching         = string<br>      }<br>    )<br>  )</pre> | `{}` | no |
| <a name="input_nessus_groups"></a> [nessus\_groups](#input\_nessus\_groups) | The Tenable Nessus groups. | `string` | `""` | no |
| <a name="input_nessus_install"></a> [nessus\_install](#input\_nessus\_install) | Install Tenable Nessus on the virtual machine. | `string` | `false` | no |
| <a name="input_nessus_key"></a> [nessus\_key](#input\_nessus\_key) | The key to use when communicating with Tenable Nessus. | `string` | `""` | no |
| <a name="input_nessus_server"></a> [nessus\_server](#input\_nessus\_server) | The Tenable Nessus server URL. | `string` | `""` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | One or more network\_interface can be set here, at least one of the network\_interface have to be primary | `any` | n/a | yes |
| <a name="input_nic_name"></a> [nic\_name](#input\_nic\_name) | The name of the NIC to create & associate with the virtual machine. | `string` | `null` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | The operating system disk storack account type. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | The operating system disk type. | `string` | `"ReadWrite"` | no |
| <a name="input_privateip_allocation"></a> [privateip\_allocation](#input\_privateip\_allocation) | The type of private IP allocation, either Static or Dynamic. | `string` | `"Static"` | no |
| <a name="input_rc_os_sku"></a> [rc\_os\_sku](#input\_rc\_os\_sku) | The SKU of run command to use. | `string` | `null` | no |
| <a name="input_rc_script_file"></a> [rc\_script\_file](#input\_rc\_script\_file) | The path to the script file to run against the virtual machine. | `string` | `null` | no |
| <a name="input_run_command"></a> [run\_command](#input\_run\_command) | Run a custom command/script against the virtual machine using a run command extension. | `bool` | `false` | no |
| <a name="input_splunk_group"></a> [splunk\_group](#input\_splunk\_group) | The group to use when communicating with splunk. | `string` | `"hmcts_forwarders"` | no |
| <a name="input_splunk_pass4symmkey"></a> [splunk\_pass4symmkey](#input\_splunk\_pass4symmkey) | The pass4symmkey to use when communicating with splunk. | `string` | `""` | no |
| <a name="input_splunk_password"></a> [splunk\_password](#input\_splunk\_password) | The password to use when communicating with splunk. | `string` | `""` | no |
| <a name="input_splunk_username"></a> [splunk\_username](#input\_splunk\_username) | The username to use when communicating with splunk. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the VMSS going to deploy | `string` | `"default_subnet_id_value"` | no |
| <a name="input_systemassigned_identity"></a> [systemassigned\_identity](#input\_systemassigned\_identity) | Enable System Assigned managed identity for the virtual machine. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the virtual Machine Scale Set and associated resources. | `map(string)` | n/a | yes |
| <a name="input_upgrade_mode"></a> [upgrade\_mode](#input\_upgrade\_mode) | Specifies how Upgrades should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling | `string` | `"Manual"` | no |
| <a name="input_userassigned_identity_ids"></a> [userassigned\_identity\_ids](#input\_userassigned\_identity\_ids) | List of User Manager Identity IDs to associate with the virtual machine. | `list(string)` | `[]` | no |
| <a name="input_vm_admin_name"></a> [vm\_admin\_name](#input\_vm\_admin\_name) | The name of the admin user. | `string` | `"VMAdmin"` | no |
| <a name="input_vm_admin_password"></a> [vm\_admin\_password](#input\_vm\_admin\_password) | The Admin password for the virtual Machine Scale Set. | `string` | n/a | yes |
| <a name="input_vm_availabilty_zones"></a> [vm\_availabilty\_zones](#input\_vm\_availabilty\_zones) | The availability zones to deploy the VM in | `list(any)` | n/a | yes |
| <a name="input_vm_image_sku"></a> [vm\_image\_sku](#input\_vm\_image\_sku) | The SKU of the image to use. | `string` | n/a | yes |
| <a name="input_vm_instances"></a> [vm\_instances](#input\_vm\_instances) | Number of VM instances required | `number` | n/a | yes |
| <a name="input_vm_location"></a> [vm\_location](#input\_vm\_location) | The Azure Region to deploy the virtual machine in. | `string` | `"uksouth"` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | The name of the Virtual Machine Scale Set | `string` | n/a | yes |
| <a name="input_vm_offer"></a> [vm\_offer](#input\_vm\_offer) | The offer of the marketplace image to use. | `string` | n/a | yes |
| <a name="input_vm_private_ip"></a> [vm\_private\_ip](#input\_vm\_private\_ip) | The private IP to assign to the virtual machine. | `string` | `null` | no |
| <a name="input_vm_public_ip_address"></a> [vm\_public\_ip\_address](#input\_vm\_public\_ip\_address) | The public IP address to assign to the virtual machine. | `string` | `null` | no |
| <a name="input_vm_publisher_name"></a> [vm\_publisher\_name](#input\_vm\_publisher\_name) | The publiser of the marketplace image to use. | `string` | n/a | yes |
| <a name="input_vm_resource_group"></a> [vm\_resource\_group](#input\_vm\_resource\_group) | The name of the resource group to deploy the virtual Machine Scale Set in. | `string` | n/a | yes |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | The Virtual Machine Scale Set SKU for the Scale Set, check allowed sku here https://tools.hmcts.net/confluence/display/DACS/D.1k+Azure+SKU+Standards+-+In+progress | `string` | n/a | yes |
| <a name="input_vm_type"></a> [vm\_type](#input\_vm\_type) | The type of the vm scale set, either windows-scale-set or linux-scale-set | `string` | n/a | yes |
| <a name="input_vm_version"></a> [vm\_version](#input\_vm\_version) | The version of the image to use. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | n/a |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | n/a |
<!-- END_TF_DOCS -->

## Contributing

We use pre-commit hooks for validating the terraform format and maintaining the documentation automatically.
Install it with:

```shell
$ brew install pre-commit terraform-docs
$ pre-commit install
```

If you add a new hook make sure to run it against all files:
```shell
$ pre-commit run --all-files
```
