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
  subscription_id = var.environment == "prod" ? "8999dec3-0104-4a27-94ee-6588559729d1" : "1c4f0704-a29e-403d-b719-b90c34ef14c9"
}

provider "azurerm" {
  features {}
  alias                      = "soc"
  skip_provider_registration = "true"
  subscription_id            = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  features {}
  subscription_id = "bf308a5c-0624-4334-8ff8-8dca9fd43783"
}
