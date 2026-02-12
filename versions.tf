# Terraform version
terraform {
  required_version = ">= 1.14.5"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.108.0"
    }
  }
}
