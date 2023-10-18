use database core_db;
use schema staging;


create pipe p_games
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_games (
    game_id,
    competition_id,
    season,
    round,
    date,
    home_club_id,
    away_club_id,
    home_club_goals,
    away_club_goals,
    home_club_position,
    away_club_position,
    home_club_manager_name,
    away_club_manager_name,
    stadium,
    attendance,
    referee,
    url,
    home_club_name,
    away_club_name,
    aggregate,
    competition_type
)
from (
    select
         stg.$1,     -- game_id
         stg.$2,     -- competition_id
         stg.$3,     -- season
         stg.$4,     -- round
         to_date(left(stg.$5, 10), 'YYYY-MM-DD'),     -- date
         stg.$6,     -- home_club_id
         stg.$7,     -- away_club_id
         stg.$8,     -- home_club_goals
         stg.$9,     -- away_club_goals
         stg.$10,     -- home_club_position
         stg.$11,     -- away_club_position
         stg.$12,     -- home_club_manager_name
         stg.$13,     -- away_club_manager_name
         stg.$14,     -- stadium
         stg.$15,     -- attendance
         stg.$16,     -- referee
         stg.$17,     -- url
         stg.$18,     -- home_club_name
         stg.$19,     -- away_club_name
         stg.$20,     -- aggregate
         stg.$21     -- competition_type
    from @stg_games stg
);