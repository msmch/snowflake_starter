use database core_db;
use schema staging;


create pipe p_competitions
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_competitions (
    competition_id,
    competition_code,
    name,
    sub_type,
    type,
    country_id,
    country_name,
    domestic_league_code,
    confederation,
    url
)
from (
    select
         stg.$1,     -- competition_id
         stg.$2,     -- competition_code
         stg.$3,     -- name
         stg.$4,     -- sub_type
         stg.$5,     -- type
         stg.$6,     -- country_id
         stg.$7,     -- country_name
         stg.$8,     -- domestic_league_code
         stg.$9,     -- confederation
         stg.$10     -- url
    from @stg_competitions stg
);