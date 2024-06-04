terraform {
  backend "azurerm" {
    storage_account_name = "azurebackendstroagenik"
    container_name = "backend"
    key = "terraform.tfstate"
    access_key = ""
    
  }
}
