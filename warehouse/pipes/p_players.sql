use database core_db;
use schema staging;


create pipe p_players
auto_ingest = true
integration = 'AZURE_NOTIFICATION'
as 
copy into raw_players (
    player_id,
    first_name,
    last_name,
    name,
    last_season,
    current_club_id,
    player_code,
    country_of_birth,
    city_of_birth,
    country_of_citizenship,
    date_of_birth,
    sub_position,
    position,
    foot,
    height_in_cm,
    market_value_in_eur,
    highest_market_value_in_eur,
    contract_expiration_date,
    agent_name,
    image_url,
    url,
    current_club_domestic_competition_id,
    current_club_name
)
from (
    select
         stg.$1,     -- player_id
         stg.$2,     -- first_name
         stg.$3,     -- last_name
         stg.$4,     -- name
         stg.$5,     -- last_season
         stg.$6,     -- current_club_id
         stg.$7,     -- player_code
         stg.$8,     -- country_of_birth
         stg.$9,     -- city_of_birth
         stg.$10,     -- country_of_citizenship
         to_date(left(stg.$11, 10), 'YYYY-MM-DD'),     -- date_of_birth
         stg.$12,     -- sub_position
         stg.$13,     -- position
         stg.$14,     -- foot
         stg.$15,     -- height_in_cm
         stg.$16,     -- market_value_in_eur
         stg.$17,     -- highest_market_value_in_eur
         to_date(left(stg.$18, 10), 'YYYY-MM-DD'),     -- contract_expiration_date
         stg.$19,     -- agent_name
         stg.$20,     -- image_url
         stg.$21,     -- url
         stg.$22,     -- current_club_domestic_competition_id
         stg.$23     -- current_club_name
    from @stg_players stg
);