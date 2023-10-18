use database core_db;
use schema staging;


create pipe p_club_games
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_club_games (
    game_id,
    club_id,
    own_goals,
    own_position,
    own_manager_name,
    opponent_id,
    opponent_goals,
    opponent_position,
    opponent_manager_name,
    hosting,
    is_win
)
from (
    select
         stg.$1,     -- game_id
         stg.$2,     -- club_id
         stg.$3,     -- own_goals
         stg.$4,     -- own_position
         stg.$5,     -- own_manager_name
         stg.$6,     -- opponent_id
         stg.$7,     -- opponent_goals
         stg.$8,     -- opponent_position
         stg.$9,     -- opponent_manager_name
         stg.$10,     -- hosting
         stg.$11     -- is_win
    from @stg_club_games stg
);