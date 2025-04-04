use role accountadmin;

/* 
create 3 warehouses, let's use XS only with all the default values like:
- auto-scale, 
- standard scaling policy, 
- auto-resume mode

Reduce auto_suspend time to one minute to avoid idle warehouse cost.
*/
create warehouse xs_backend
with 
warehouse_size = 'XSMALL'
auto_suspend = 60;

create warehouse xs_analytics
with 
warehouse_size = 'XSMALL'
auto_suspend = 60;

create warehouse xs_dev
with 
warehouse_size = 'XSMALL'
auto_suspend = 60;


/* 
Database and schemas 
*/
create database core_db;

use database core_db;
create schema staging;
create schema transformed;
create schema analytics;


/* Create 3 roles:
- developer with access to all schemas, he can create, read and modify everything 
  (in ideal world we should be having a PROD database where DEV is not allowed to change anything but it's out of scope of this repo)
- analyst with usage access to transformed and full access to analytics schema
- reports_reader with select access to analytics only
*/
create role developer;
create role analyst;
create role reports_reader;


-- grants to the roles - MAKE SURE THE INTEGRATIONS ARE ALREADY CREATED AT THIS STEP

-- Developer - simple ownership role to the entire DB
grant ownership on database core_db to role developer;
grant ownership on all schemas in database core_db to role developer;
grant usage on integration azure_integration to developer;
grant usage on integration azure_notification to developer;
grant execute task on account to role developer;


-- Analyst - usage on ANALYTICS and TRANSFORMED schema with full control on ANALYTICS
grant usage on database core_db to role analyst;
grant usage, create table, modify on schema core_db.analytics to role analyst;
grant usage on schema core_db.transformed to role analyst;
grant select, insert, delete, update on future tables in schema core_db.transformed to role analyst;
grant select on future tables in schema core_db.transformed to role analyst;
grant select, insert, delete, update on future tables in schema core_db.analytics to role analyst;
grant select on future tables in schema core_db.analytics to role analyst;

-- reports_reader - with usage and select on analytics only
grant usage on database core_db to role reports_reader;
grant usage on schema core_db.analytics to role reports_reader;
grant select on future tables in schema core_db.analytics to role reports_reader;


/*  
Grant usage on warehouses the users. This way we can better control their warehouse performance and the cost they create.
XS_BACKEND should be used for all tasks and etl processes only.
*/
grant usage on warehouse xs_backend to role developer;
grant usage on warehouse xs_dev to role developer;
grant usage on warehouse xs_analytics to role analyst;
grant usage on warehouse xs_analytics to role reports_reader;


/*For testing purposes you can run following commands. Uncomment them before run.*/

-- show grants to role developer;
-- show grants to role analyst;
-- show grants to role reports_reader;

-- select current_user() --> it returns my user MSMCH

-- -- grant all the roles to my user and see if the given access rights is correct
-- grant role developer to user MSMCH;
-- grant role analyst to user MSMCH;
-- grant role reports_reader to user MSMCH;