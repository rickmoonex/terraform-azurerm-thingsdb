terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.12.0"
    }

    assert = {
      source  = "hashicorp/assert"
      version = "0.14.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }

  required_version = ">= 1.10"
}

provider "azurerm" {
  features {

  }
  subscription_id = "4e9af5b9-bd96-4a39-8835-11c6d4defa45"
}
