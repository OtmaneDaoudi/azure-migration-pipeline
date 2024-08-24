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
