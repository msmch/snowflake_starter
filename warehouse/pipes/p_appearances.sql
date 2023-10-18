use database core_db;
use schema staging;


create pipe p_appearances
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_appearances (
    appearance_id,
    game_id,
    player_id,
    player_club_id,
    player_current_club_id,
    date,
    player_name,
    competition_id,
    yellow_cards,
    red_cards,
    goals,
    assists,
    minutes_played
)
from (
    select
         stg.$1,     -- appearance_id
         stg.$2,     -- game_id
         stg.$3,     -- player_id
         stg.$4,     -- player_club_id
         stg.$5,     -- player_current_club_id
         to_date(left(stg.$6, 10), 'YYYY-MM-DD'),     -- date
         stg.$7,     -- player_name
         stg.$8,     -- competition_id
         stg.$9,     -- yellow_cards
         stg.$10,     -- red_cards
         stg.$11,     -- goals
         stg.$12,     -- assists
         stg.$13     -- minutes_played
    from @stg_appearances stg
);