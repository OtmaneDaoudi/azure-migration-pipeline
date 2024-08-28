variable "cluster_name" {}

variable "container_names" {
  default = ["bronze", "silver", "gold"]
}

variable "storage_account_name" {}

variable "workspace_url" {}

variable "sas_token" {}

variable "subscription_id" {}

variable "databricks_linked_service_name" {}

variable "data_factory_id" {}