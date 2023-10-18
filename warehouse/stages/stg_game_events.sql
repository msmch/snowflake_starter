use database core_db;
use schema staging;


create stage stg_game_events
url = 'azure://msmch.blob.core.windows.net/snowflake-starter/game_events/'
storage_integration = azure_integration
file_format = csv_with_header;
