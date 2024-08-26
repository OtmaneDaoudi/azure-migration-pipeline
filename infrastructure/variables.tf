variable "resource_group_name" {}

variable "location" {}

variable "subscription_id" {}

variable "adf_workspace_name" {}

variable "databricks_workspace_name" {}

variable "databricks_sku" {}

variable "storage_account_name" {}

variable "storage_account_tier" {}

variable "storage_account_replication_type" {}

variable "container_name" {}

variable "synapse_workspace_name" {}

variable "sql_administrator_login" {}

variable "sql_administrator_login_password" {}

variable "keyvault_name" {}

variable "vault_key_permissions" {
  type = list(string)
  default = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Purge"
  ]
}

variable "vault_secret_permissions" {
  type = list(string)
  default = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Purge"
  ]
}

variable "secrets" {
  type = map(string)
}

variable "SHIR_name" {}

variable "mysql_linked_service_name" {}

variable "mysqlhost" {}

variable "mysqlport" {}

variable "mysqldatabase" {}

variable "mysql_dataset_name" {}

variable "data_lake_linked_service_name" {}

variable "data_lake_parquet_dataset_name" {}

variable "table_name" {}