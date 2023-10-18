use database core_db;
use schema staging;


create pipe p_game_events
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_game_events (
    game_id,
    minute,
    type,
    club_id,
    player_id,
    description,
    player_in_id
)
from (
    select
         stg.$1,     -- game_id
         stg.$2,     -- minute
         stg.$3,     -- type
         stg.$4,     -- club_id
         stg.$5,     -- player_id
         stg.$6,     -- description
         stg.$7     -- player_in_id
    from @stg_game_events stg
);