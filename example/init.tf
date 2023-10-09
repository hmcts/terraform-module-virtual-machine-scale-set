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

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  alias = "cnp"
  features {}
  subscription_id = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}
