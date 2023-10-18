use database core_db;
use schema staging;


create or replace task tsk_merge_into_fact_player_valuations
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_player_valuations')
as 
merge into transformed.fact_player_valuations as dest
using (
    select *
    from raw_player_valuations
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by valuation_id order by add_timestamp desc)
) as src
on dest.valuation_id = src.valuation_id
when matched then
    update set 
                    dest.player_id = src.player_id,
        dest.last_season = src.last_season,
        dest.datetime = src.datetime,
        dest.date = src.date,
        dest.dateweek = src.dateweek,
        dest.market_value_in_eur = src.market_value_in_eur,
        dest.n = src.n,
        dest.current_club_id = src.current_club_id,
        dest.player_club_domestic_competition_id = src.player_club_domestic_competition_id,
        dest.valuation_id = src.valuation_id,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (player_id,last_season,datetime,date,dateweek,market_value_in_eur,n,current_club_id,player_club_domestic_competition_id,valuation_id,add_timestamp,edit_timestamp)
    values (src.player_id, src.last_season, src.datetime, src.date, src.dateweek, src.market_value_in_eur, src.n, src.current_club_id, src.player_club_domestic_competition_id, src.valuation_id, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_player_valuations
warehouse = xs_backend
after tsk_merge_into_fact_player_valuations
as 
create or replace stream stm_player_valuations on table raw_player_valuations;

alter task tsk_recreate_stm_player_valuations resume;
alter task tsk_merge_into_fact_player_valuations resume;
