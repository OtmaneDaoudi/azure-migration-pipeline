output "sas_url_query_string" {
  value     = data.azurerm_storage_account_sas.sas_access.sas
  sensitive = true
}