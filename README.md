# Sample Data Warehouse using Snowflake

In this repository, you can find the complete setup of a Snowflake data warehouse. I use publicly available data to demonstrate how to create a cloud warehouse step by step. The process includes building an Azure and Snowflake integration, setting up ingestion pipelines, basic ELT processes, and an analytics layer for data visualizations. Additionally, i've provided Python automation scripts that help with data analysis and the creation of basic SQL scripts without manual effort.

Keep in mind, this is an example of a cloud warehouse built in Snowflake. The purpose of this project is to showcase the capabilities. If your use case is more complex, you may need to make some manual adjustments.

## Prerequisites

To use this code, you need to fulfill the following requirements:

- A Snowflake account
- A cloud account (Azure in this example, but other providers can be used)
- Optionally, Python, which allows you to run automation scripts. You can create a virtual environment using the requirements.txt file.

## Repository Structure

This repository is organized into several main directories:

- `warehouse/`: Contains all Snowflake objects.
- `automation_scripts/`: Python scripts for generating SQL code for table DDLs, pipes, and stages.
- `eda/`: Jupyter notebooks used for exploratory data analysis.
- `azure_connector/`: Code for automatically deploying data to Azure storage, from where it can be ingested into Snowflake.

## Data Set

This repository uses the "Football Data From Transfermarkt" dataset available on Kaggle. You can find the data using this URL: [Football Data From Transfermarkt](https://www.kaggle.com/datasets/mexwell/football-data-from-transfermarkt/).

The data relationship diagram, prepared by the dataset owner:

![Data Relationship Diagram](https://github.com/dcaribou/transfermarkt-datasets/blob/master/resources/diagram.svg?raw=true)

## Warehouse Naming Convention

To ensure consistency and clarity in the Snowflake warehouse, i've adopted the following naming conventions for various objects:

- **Staging Objects**:
  - Staging tables: `stg_<table_name>`

- **Raw Data Tables**:
  - Tables for raw data storage: `raw_<table_name>`

- **Transformed Data Tables**:
  - Tables for transformed data: `dim_<table_name>` (for dimensions) or `fact_<table_name>` (for facts)

- **Views**:
  - Views for analytics: `v_<view_name>`

- **Schemas**:
  - For organization, I use separate schemas for three logical areas: `staging`, `transformed`, and `analytics`. In real-life projects, you may need a more granular approach as you will likely have significantly more data inputs requiring cleanup and transformations before the data can be presented via the analytics layer. Keep in mind, this is only an example of the Snowflake warehouse.

## How to Use Automation Scripts with Your Own Data

1. **Setting up Snowflake and Cloud Account**:
   - Ensure you have a Snowflake account ready.
   - Set up your cloud account (e.g., Azure) and configure the integration with Snowflake. I strongly recommend following the steps from online tutorials, such as [official Snowflake guide](https://docs.snowflake.com/en/user-guide/data-load-azure-config) or [this guide from Medium](https://medium.com/contino-engineering/snowflake-integration-with-azure-6a86b3436fc8). Finally, run Azure integration scripts from `warehouse\global_objects\storage_integrations\azure.sql`. Remember you need to desc integration and approve connection after openning AZURE_CONSENT_URL. Azure will create the Snowflake user in approx and hour. You need to allow this user to access Blobs by granting `Storage Blob Data Reader` or `Storage Blob Data Contributor` if you want to unload data. 

   - If you plan to use auto-ingestion you need to create a queue and event grid in you Azure account. You can follow the steps from [this Medium guide](https://medium.com/beeranddiapers/snowflake-data-ingestion-from-azure-using-snowpipe-709bf7f0ae83). Once done you need to run `warehouse\global_objects\storage_integrations\azure_notification_integration.sql`.

2. **Create a Data Directory for Your Files**:
   - In our scripts, i use the `./data` directory. Note that it's included in `.gitignore`, so you won't find my files in the repo. To run the automation scripts with your files, you only need to create a directory and drop your files there.

3. **EDA Notebooks and Automation Scripts**:
   - Use the Python scripts from the `eda` directory to inspect the raw CSV files and generate SQL scripts for table DDLs, pipes, and stages. This will save you time and effort as you won't need to create each file manually. 
   - You will need to make the final touches to each file to ensure your data loads successfully. Make sure you use correct data types and add as much supplementary information as possible (primary keys, relationship indications using foreign keys). It will make your life easier when working with this data and help users better understand the data you provide to them. 

4. **Automation Scripts**:
   - Staging tables and stages are created by the Jupyter Notebooks when you run the high-level analysis. Make sure you inspect the tables' DDLs and ensure the files are ready for deployment. The primary keys and data types are used by other scripts, so if you want to run full automation, you need to have them set correctly.
   - If you want to have any `transformed` tables, you need to map the staging table and transformed table in `automation_scripts\mapping.py`. 
   - The automation scripts will create the following files for you:
     - Stage definitions
     - Snowpipe definitions
     - Stream definitions
     - Basic tasks

5. **Data Ingestion**:
   - Run the scripts in the `warehouse` directory to create file formats, stages, tables, streams, pipes and basic tasks. The full setup should be completed with the following steps (order matters):
      - run `warehouse\core_setup.sql`
      - run files from `warehouse\file_formats`
      - run files from `warehouse\stages`
      - run files from `warehouse\tables`
      - run files from `warehouse\streams`
      - run files from `warehouse\pipes`
      - run files from `warehouse\tasks`
   - After deploying all objects you are ready for data ingestion. The easiest way is to run `upload_files.py` from `automation_scripts` to automatically deploy data to Azure storage, from where it will be ingested into Snowflake.

6. **ELT Process**:
   - Transform the raw data into the desired schema using SQL scripts available in the `warehouse` directory.

7. **Analytics Layer**:
   - Create views and reports for data visualization in the `analytics` directory.

## Data Visualization

You can use your preferred BI tool to visualize the data stored in Snowflake, utilizing the views and reports created in the `analytics` layer.

## License

This repository is available under the MIT License. Please refer to the LICENSE file for details.

Feel free to explore and use this repository for your projects. All suggestions, improvements and bug reports are more than welcome.
