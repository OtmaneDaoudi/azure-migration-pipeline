# terraform configs
# export TF_LOG=INFO

# Provider configs
export TF_VAR_location=francecentral
export TF_VAR_subscription_id=


# Resource group configs
export TF_VAR_resource_group_name=articles_scraping


# Azure data factory
export TF_VAR_adf_workspace_name="ingestion-ws"
# Self hosted integration runtime name
export TF_VAR_SHIR_name=SHIR    
export TF_VAR_mysql_linked_service_name=mysqlls
export TF_VAR_mysql_dataset_name=mysql_dataset_source
export TF_VAR_data_lake_linked_service_name=datalakels
export TF_VAR_data_lake_parquet_dataset_name=datalake_sink
export TF_VAR_databricks_linked_service_name=databricksls
# on-prem connection details
export TF_VAR_mysqlhost=localhost
export TF_VAR_mysqlport=3306
export TF_VAR_mysqldatabase=adventureworkslt2017


# Key vault configs
export TF_VAR_keyvault_name=scrapingkeyvault
# on-prem db config
export TF_VAR_secrets='{"mysqluser":"", "mysqlpassword":""}'


# Databricks configs
export TF_VAR_databricks_workspace_name="transformation-ws"
# Pricing tier for azure databricks
export TF_VAR_databricks_sku=trial
export TF_VAR_user_name=
export TF_VAR_display_name=
export TF_VAR_cluster_name="scraping-articles"


# Azure storage account configs
export TF_VAR_storage_account_name="datastorage69"
export TF_VAR_storage_account_tier=Standard
export TF_VAR_storage_account_replication_type=LRS
export TF_VAR_today=`date +"%Y-%m-%dT%H:%M:%SZ"`
export TF_VAR_tomorrow=`date -d "tomorrow" +"%Y-%m-%dT%H:%M:%SZ"`


# Azure synapse configs
export TF_VAR_synapse_workspace_name=synapse-ws29072001
export TF_VAR_sql_administrator_login=
export TF_VAR_sql_administrator_login_password=