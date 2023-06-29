terraform {
  required_version = "1.5.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.62.1"
    }
  }

}

provider "azurerm" {
  features {}
  subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}
