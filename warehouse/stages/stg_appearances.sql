use database core_db;
use schema staging;


create stage stg_appearances
url = 'azure://msmch.blob.core.windows.net/snowflake-starter/appearances/'
storage_integration = azure_integration
file_format = csv_with_header;
