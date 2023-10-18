use database core_db;
use schema staging;


create pipe p_clubs
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_clubs (
    club_id,
    club_code,
    name,
    domestic_competition_id,
    total_market_value,
    squad_size,
    average_age,
    foreigners_number,
    foreigners_percentage,
    national_team_players,
    stadium_name,
    stadium_seats,
    net_transfer_record,
    coach_name,
    last_season,
    url
)
from (
    select
         stg.$1,     -- club_id
         stg.$2,     -- club_code
         stg.$3,     -- name
         stg.$4,     -- domestic_competition_id
         stg.$5,     -- total_market_value
         stg.$6,     -- squad_size
         stg.$7,     -- average_age
         stg.$8,     -- foreigners_number
         stg.$9,     -- foreigners_percentage
         stg.$10,     -- national_team_players
         stg.$11,     -- stadium_name
         stg.$12,     -- stadium_seats
         stg.$13,     -- net_transfer_record
         stg.$14,     -- coach_name
         stg.$15,     -- last_season
         stg.$16     -- url
    from @stg_clubs stg
);