terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.cnp, azurerm.soc]
      version               = ">= 3.75.0"
    }
  }
  required_version = ">= 0.13"
}
provider "azurerm" {
  features {}
  alias           = "cnp"
  subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}

provider "azurerm" {
  features {}
  subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}
