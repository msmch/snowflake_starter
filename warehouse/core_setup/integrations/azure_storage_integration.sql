/* 
The storage integration allowing snowflake to access data that is stored in the Azure Cloud. All blobs are allowed 
in my dedicated container football-data. This way we give Snowflake control on one container only and it's not 
able to interact with other objects in the storage account.
*/
use role accountadmin;


create storage integration azure_integration
type = external_stage
storage_provider = azure
enabled = true
azure_tenant_id = 'TENANT_ID_GOES_HERE' -- make sure to copy paste the tenant ID 
storage_allowed_locations = ('azure://msmchsnowflakestater.blob.core.windows.net/football-data');

-- then run the below and open AZURE_CONSENT_URL to authorize connection
desc storage integration azure_integration;