use database core_db;
use schema staging;


create stage stg_games
url = 'azure://msmch.blob.core.windows.net/snowflake-starter/games/'
storage_integration = azure_integration
file_format = csv_with_header;
