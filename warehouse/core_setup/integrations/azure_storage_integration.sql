/* The storage integration allows Snowflake to access data stored in Azure Blob Storage. 
Only the football-data container is exposed, so Snowflake has access strictly to that container 
and can't interact with anything else in the storage account. 
*/
use role accountadmin;

create storage integration azure_integration
type = external_stage
storage_provider = azure
enabled = true
azure_tenant_id = 'TENANT_ID_GOES_HERE' -- make sure to copy paste the tenant ID 
storage_allowed_locations = ('azure://msmchsnowflakestater.blob.core.windows.net/football-data');

desc storage integration azure_integration;  -- open AZURE_CONSENT_URL and approve access