use role accountadmin;

create notification integration azure_notification
enabled = true
type = queue
notification_provider = azure_storage_queue
azure_storage_queue_primary_uri = 'azure://msmchsnowflakestater.blob.core.windows.net/football-data'
azure_tenant_id = 'TENANT_ID_GOES_HERE'; -- you need to add your TENANT_ID manually before running the script

desc integration azure_notification; -- open AZURE_CONSENT_URL and approve access