use database core_db;
use schema staging;


create or replace task tsk_merge_into_dim_players
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_players')
as 
merge into transformed.dim_players as dest
using (
    select *
    from raw_players
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by player_id order by add_timestamp desc)
) as src
on dest.player_id = src.player_id
when matched then
    update set 
                    dest.player_id = src.player_id,
        dest.first_name = src.first_name,
        dest.last_name = src.last_name,
        dest.name = src.name,
        dest.last_season = src.last_season,
        dest.current_club_id = src.current_club_id,
        dest.player_code = src.player_code,
        dest.country_of_birth = src.country_of_birth,
        dest.city_of_birth = src.city_of_birth,
        dest.country_of_citizenship = src.country_of_citizenship,
        dest.date_of_birth = src.date_of_birth,
        dest.sub_position = src.sub_position,
        dest.position = src.position,
        dest.foot = src.foot,
        dest.height_in_cm = src.height_in_cm,
        dest.market_value_in_eur = src.market_value_in_eur,
        dest.highest_market_value_in_eur = src.highest_market_value_in_eur,
        dest.contract_expiration_date = src.contract_expiration_date,
        dest.agent_name = src.agent_name,
        dest.image_url = src.image_url,
        dest.url = src.url,
        dest.current_club_domestic_competition_id = src.current_club_domestic_competition_id,
        dest.current_club_name = src.current_club_name,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (player_id,first_name,last_name,name,last_season,current_club_id,player_code,country_of_birth,city_of_birth,country_of_citizenship,date_of_birth,sub_position,position,foot,height_in_cm,market_value_in_eur,highest_market_value_in_eur,contract_expiration_date,agent_name,image_url,url,current_club_domestic_competition_id,current_club_name,add_timestamp,edit_timestamp)
    values (src.player_id, src.first_name, src.last_name, src.name, src.last_season, src.current_club_id, src.player_code, src.country_of_birth, src.city_of_birth, src.country_of_citizenship, src.date_of_birth, src.sub_position, src.position, src.foot, src.height_in_cm, src.market_value_in_eur, src.highest_market_value_in_eur, src.contract_expiration_date, src.agent_name, src.image_url, src.url, src.current_club_domestic_competition_id, src.current_club_name, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_players
warehouse = xs_backend
after tsk_merge_into_dim_players
as 
create or replace stream stm_players on table raw_players;

alter task tsk_recreate_stm_players resume;
alter task tsk_merge_into_dim_players resume;
