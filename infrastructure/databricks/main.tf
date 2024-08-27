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
    "sas_token" = var.sas_token
    "container_names"      = join(",", var.container_names)
    "storage_account_name" = var.storage_account_name
  }
}

resource "databricks_notebook" "notebook" {
  source = "../../databricks/transformations.ipynb"
  path   = "/Shared/transformations.ipynb"

  depends_on = [databricks_cluster.driver_node]
}