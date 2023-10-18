use database core_db;
use schema staging;


create stage stg_players
url = 'azure://msmch.blob.core.windows.net/snowflake-starter/players/'
storage_integration = azure_integration
file_format = csv_with_header;
