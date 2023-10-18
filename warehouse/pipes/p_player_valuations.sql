use database core_db;
use schema staging;


create pipe p_player_valuations
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_player_valuations (
    player_id,
    last_season,
    datetime,
    date,
    dateweek,
    market_value_in_eur,
    n,
    current_club_id,
    player_club_domestic_competition_id
)
from (
    select
         stg.$1,     -- player_id
         stg.$2,     -- last_season
         stg.$3,     -- datetime
         to_date(left(stg.$4, 10), 'YYYY-MM-DD'),     -- date
         to_date(left(stg.$5, 10), 'YYYY-MM-DD'),     -- dateweek
         stg.$6,     -- market_value_in_eur
         stg.$7,     -- n
         stg.$8,     -- current_club_id
         stg.$9     -- player_club_domestic_competition_id
    from @stg_player_valuations stg
);