data "databricks_spark_version" "v11-3-scala-2-12" {
  latest            = false
  long_term_support = true
  spark_version     = "3.3.0"
  scala             = "2.12"
}

data "databricks_node_type" "smallest" {
  category = "General Purpose"
}

resource "databricks_cluster" "driver_node" {
  cluster_name            = var.cluster_name
  spark_version           = data.databricks_spark_version.v11-3-scala-2-12.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 10
  num_workers             = 0 # Single node cluster (driver only)
  # data_security_mode = "SINGLE_USER"
  single_user_name = "odaoudi@valhko.com"

  spark_conf = {
    # Single-node
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
    "spark.databricks.passthrough.enabled" : "true"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }

  spark_env_vars = {
    "sas_token"            = var.sas_token
    "container_names"      = join(",", var.container_names)
    "storage_account_name" = var.storage_account_name
  }
}

resource "databricks_notebook" "bronze_to_silver_notebok" {
  source   = "../../databricks/bronze to silver.ipynb"
  path     = "/Shared/bronze to silver.ipynb"
  language = "PYTHON"
  format   = "JUPYTER"

  depends_on = [databricks_cluster.driver_node]
}

resource "databricks_notebook" "silver_to_gold_notebok" {
  source   = "../../databricks/silver to gold.ipynb"
  path     = "/Shared/silver to gold.ipynb"
  language = "PYTHON"
  format   = "JUPYTER"

  depends_on = [databricks_cluster.driver_node, databricks_notebook.bronze_to_silver_notebok]
}

resource "databricks_token" "pat" {
  comment  = "Azure databricks linked service"
  // 100 day token
  lifetime_seconds = 8640000
}

# Azure linked service for databricks
resource "azurerm_data_factory_linked_service_azure_databricks" "databricks_linked_service" {
  name                = var.databricks_linked_service_name
  data_factory_id     = var.data_factory_id
  existing_cluster_id = databricks_cluster.driver_node.id

  access_token = databricks_token.pat.token_value
  adb_domain   = "https://${var.workspace_url}"
}