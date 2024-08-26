az extension add --name datafactory

az datafactory pipeline create-run \
  --resource-group "articles_scraping" \
  --factory-name "ingestion-ws" \
  --pipeline-name "ingestion_pipeline"