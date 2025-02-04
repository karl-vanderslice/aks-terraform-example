provider "azurerm" {
  version         = "=1.44.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Uncomment backend block to use azurerm backend
terraform {
  required_version = "= 0.12.20"
}