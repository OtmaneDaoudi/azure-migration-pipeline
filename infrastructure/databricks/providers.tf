terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.51.0"
    }
  }
}


provider "databricks" {
  host = var.workspace_url
}