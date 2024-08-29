# Project Overview
The goal of this project is to migrate an on-premise MySQL database to a cloud data warehouse to serve business' analytical needs, by creating an ELT pipeline that implements the medallion data architecture.

# Architecture
![Architecture](https://github.com/user-attachments/assets/ec917f02-896b-41e3-8c83-ecc6363b64ba)

## Data Ingestion & Loading
1. The on-premise host is connected to the cloud using Microsoft Runtime Integration.
![image](https://github.com/user-attachments/assets/e0c015e6-fbbf-400c-ac1d-8f867f4ff581)

2. An Azure Data Factory pipeline then connects to the host copies the data from all the tables, and loads them into a bronze container within Azure Data Lake in parquet format.
![image](https://github.com/user-attachments/assets/6df16eb5-8358-40a7-ac30-1a2bac5516f1)
![image](https://github.com/user-attachments/assets/7957946a-2982-4dd2-8739-67e1daf89fe7)

## Data Transformation
- A second step in the Azure Data factory (ADF) pipeline connects to a databricks cluster to invoke the first phase of transformation (Bronze to silver), by executing a notebook that filters and formats the data, which is then stored in Delta format, in the silver container within Azure Data Lake.
![image](https://github.com/user-attachments/assets/26fb9e8e-33a9-461f-947d-01bb90609196)
![image](https://github.com/user-attachments/assets/5bfbd9fa-6358-46ce-9e90-afe0c1cb092c)
- The last phase of transformations (Silver to Gold) is then performed in the same manner, placing the cleaned data in the gold container.
## Data Modelling
- Using an Azure Synapse serverless SQL database as an analytics engine to directly query the data in the gold container, I created different views to reflect the different facts and dimension tables.
![image](https://github.com/user-attachments/assets/d5e6595f-bd7a-474d-ab19-8976fd907d39)
![image](https://github.com/user-attachments/assets/9b7858fd-7e34-4a6e-82a8-5702671d95d2)
## Analytics & Reporting
Done using PowerBI, which connects to the Azure Synapse SQL server, and load the data using the views.

# Dashboard
![image](https://github.com/user-attachments/assets/357d7480-2d8c-4abb-b947-3793af2ac580)
# Final thoughts
- The soul goal of the project is to learn and get exposed to data engineering in Azure cloud, thus the use of some technologies and services is overkill for such low amount of data.
- Since the amount of transformations performed is light, sticking with Azure Data Factory is a more efficient and cost effective approach.
