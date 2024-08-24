resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_data_factory" "data_factory" {
  name                = var.adf_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_databricks_workspace" "databricks" {
  name                          = var.databricks_workspace_name
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = var.location
  sku                           = var.databricks_sku
  public_network_access_enabled = true
}

resource "azurerm_storage_account" "data_lake" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind = "StorageV2"
  is_hns_enabled=true # forces the created of Azure Data Lake Storage Gen 2
}

resource "azurerm_storage_container" "data_lake_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "private"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_fs" {
  name               = "datalakefs"
  storage_account_id = azurerm_storage_account.data_lake.id
}

resource "azurerm_synapse_workspace" "synapse_analytics" {
  name                                 = var.synapse_workspace_name
  resource_group_name                  = azurerm_resource_group.resource_group.name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.data_lake_fs.id
  sql_administrator_login              = var.sql_administrator_login
  sql_administrator_login_password     = var.sql_administrator_login_password

  identity {
    type = "SystemAssigned"
  }
 
}