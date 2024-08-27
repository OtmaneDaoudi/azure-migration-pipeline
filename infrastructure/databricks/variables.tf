variable "cluster_name" {}

variable "container_names" {
  default = ["bronze", "silver", "gold"]
}

variable "storage_account_name" {}

variable "workspace_url" {}

variable "sas_token" {}