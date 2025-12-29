
terraform {
  backend "azurerm" {
    resource_group_name  = "POC-Kapil"               # Replace with your RG name
    storage_account_name = "tspsa01567rytg"          # Your storage account name
    container_name       = "tfstate"                 # The blob container for state
    key                  = "infra/terraform.tfstate" # Path/key for the state file
  }
}
