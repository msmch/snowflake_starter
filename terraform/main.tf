# use snowfkale_starter_% pattern for all the resources
# rely on env variables to make it flexible and reusable
# make sure AZ CLI is installed and you log in using `az login --use-device-code` first

provider "azurerm" {
  features {}
  subscription_id = var.AZURE_SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "snowflake_starter_rg" {
  name     = var.SNOWFLAKE_STARTER_RG
  location = "West Europe"
}

resource "azurerm_storage_account" "snowflake_starter_storage" {
  name                     = var.SNOWFLAKE_STARTER_STORAGE_ACC
  resource_group_name      = azurerm_resource_group.snowflake_starter_rg.name
  location                 = azurerm_resource_group.snowflake_starter_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "snowflake_starter_container" {
  name                  = var.SNOWFLAKE_STARTER_STORAGE_ACC_CONT
  storage_account_id  = azurerm_storage_account.snowflake_starter_storage.id
  container_access_type = "private"
}

# Dynamically upload all the files
resource "azurerm_storage_blob" "snowflake_starter_blobs" {
  for_each = fileset(var.SNOWFLAKE_STARTER_LOCAL_FILES_PATH, "*")

  name                   = each.value # keep the same filename
  storage_account_name   = azurerm_storage_account.snowflake_starter_storage.name
  storage_container_name = azurerm_storage_container.snowflake_starter_container.name
  type                   = "Block"
  source                 = "${var.SNOWFLAKE_STARTER_LOCAL_FILES_PATH}/${each.value}"
}