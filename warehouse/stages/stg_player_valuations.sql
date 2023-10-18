use database core_db;
use schema staging;


create stage stg_player_valuations
url = 'azure://msmch.blob.core.windows.net/snowflake-starter/player_valuations/'
storage_integration = azure_integration
file_format = csv_with_header;
