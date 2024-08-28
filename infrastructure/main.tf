# Resource group for all the resources
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}


# Key vault setup
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions     = var.vault_key_permissions
    secret_permissions  = var.vault_secret_permissions
    storage_permissions = var.vault_secret_permissions
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.key_vault.id
  for_each     = var.secrets
}


# Azure data lake gen2
resource "azurerm_storage_account" "data_lake" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  account_kind             = "StorageV2"
  is_hns_enabled           = true # forces the creation of an Azure Data Lake Storage Gen 2
}

resource "azurerm_storage_container" "data_lake_containers" {
  name                  = var.container_names[count.index]
  storage_account_name  = azurerm_storage_account.data_lake.name
  container_access_type = "container"
  count                 = 3
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_fs" {
  name               = "datalakefs"
  storage_account_id = azurerm_storage_account.data_lake.id
}

data "azurerm_storage_account_sas" "sas_access" {
  connection_string = azurerm_storage_account.data_lake.primary_connection_string
  https_only        = false
  signed_version    = "2022-11-02"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = true
    table = true
    file  = true
  }

  start  = var.today
  expiry = var.tomorrow

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = true
  }
}


# Azure data factory pipeline
resource "azurerm_data_factory" "data_factory" {
  name                = var.adf_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_integration_runtime" {
  name            = var.SHIR_name
  description     = "A self hosted integration runtime to connect to on-prem MySQL server"
  data_factory_id = azurerm_data_factory.data_factory.id

  provisioner "local-exec" {
    # This command is found in the folder where MS integration runtime is installed under PowershellScript
    # Make sure to add it to your PATH
    # Increase the sleep duration to give the node a chance to connect using the new key!
    command = "powershell.exe RegisterIntegrationRuntime.ps1 -gatewayKey ${self.primary_authorization_key}; sleep 60"
  }
}

resource "azurerm_data_factory_linked_service_mysql" "mysql_source" {
  name                     = var.mysql_linked_service_name
  data_factory_id          = azurerm_data_factory.data_factory.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_self_hosted.self_hosted_integration_runtime.name
  connection_string        = "Server=${var.mysqlhost};Port=${var.mysqlport};Database=${var.mysqldatabase};User=${azurerm_key_vault_secret.secrets["mysqluser"].value};SSLMode=1;UseSystemTrustStore=0;Password=${azurerm_key_vault_secret.secrets["mysqlpassword"].value}"
}

resource "azurerm_data_factory_dataset_mysql" "mysql_dataset" {
  name                = var.mysql_dataset_name
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_mysql.mysql_source.name
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "data_lake_sink" {
  name                = var.data_lake_linked_service_name
  data_factory_id     = azurerm_data_factory.data_factory.id
  url                 = azurerm_storage_account.data_lake.primary_dfs_endpoint
  storage_account_key = azurerm_storage_account.data_lake.primary_access_key
}

resource "azurerm_data_factory_dataset_parquet" "parquet_dataset" {
  name                = var.data_lake_parquet_dataset_name
  data_factory_id     = azurerm_data_factory.data_factory.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.data_lake_sink.name
  compression_codec   = "gzip"

  azure_blob_fs_location {
    file_system = azurerm_storage_container.data_lake_containers[0].name
    # each table's data is stored in a separate file
    filename                 = "@concat(dataset().table_name, '.parquet')"
    dynamic_filename_enabled = true
  }

  parameters = {
    "table_name" = "" # default value for the parameter
  }
}

resource "azurerm_data_factory_pipeline" "ingestion_pipeline" {
  name            = "migration_pipeline"
  data_factory_id = azurerm_data_factory.data_factory.id
  activities_json = file("../adf/pipeline.json")

  # provisioner "local-exec" {
  #   command     = "./trigger_pipeline.sh"
  #   working_dir = "../adf"
  # }

  depends_on = [
    azurerm_data_factory_dataset_parquet.parquet_dataset,
    azurerm_data_factory_dataset_mysql.mysql_dataset,
    null_resource.init_databricks_infra
  ]
}


# Databricks setup
resource "azurerm_databricks_workspace" "databricks" {
  name                          = var.databricks_workspace_name
  resource_group_name           = azurerm_resource_group.resource_group.name
  location                      = var.location
  sku                           = var.databricks_sku
  public_network_access_enabled = true
}

resource "null_resource" "init_databricks_infra" {
  provisioner "local-exec" {
    command = <<-EOT
      sleep 10
      . ./env.sh
      cd ./databricks
      export TF_VAR_sas_token="${nonsensitive(data.azurerm_storage_account_sas.sas_access.sas)}"
      export TF_VAR_data_factory_id="${azurerm_data_factory.data_factory.id}"
      export TF_VAR_subscription_id="${data.azurerm_client_config.current.subscription_id}"
      export TF_VAR_workspace_url="${azurerm_databricks_workspace.databricks.workspace_url}"
      export TF_VAR_databricks_linked_service_name="${var.databricks_linked_service_name}"
      terraform init
      terraform apply -auto-approve
      sleep 10
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
    cd ./databricks
    ./destroy.sh
    EOT
  }

  depends_on = [azurerm_databricks_workspace.databricks]
}


# Azure synapse
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

resource "azurerm_synapse_firewall_rule" "allow_all" {
  name                 = "allow_all"
  synapse_workspace_id = azurerm_synapse_workspace.synapse_analytics.id
  start_ip_address     = "0.0.0.0"
  end_ip_address       = "255.255.255.255"
}

