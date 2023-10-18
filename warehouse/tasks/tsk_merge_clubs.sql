use database core_db;
use schema staging;


create or replace task tsk_merge_into_dim_clubs
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_clubs')
as 
merge into transformed.dim_clubs as dest
using (
    select *
    from raw_clubs
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by club_id order by add_timestamp desc)
) as src
on dest.club_id = src.club_id
when matched then
    update set 
                    dest.club_id = src.club_id,
        dest.club_code = src.club_code,
        dest.name = src.name,
        dest.domestic_competition_id = src.domestic_competition_id,
        dest.total_market_value = src.total_market_value,
        dest.squad_size = src.squad_size,
        dest.average_age = src.average_age,
        dest.foreigners_number = src.foreigners_number,
        dest.foreigners_percentage = src.foreigners_percentage,
        dest.national_team_players = src.national_team_players,
        dest.stadium_name = src.stadium_name,
        dest.stadium_seats = src.stadium_seats,
        dest.net_transfer_record = src.net_transfer_record,
        dest.coach_name = src.coach_name,
        dest.last_season = src.last_season,
        dest.url = src.url,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (club_id,club_code,name,domestic_competition_id,total_market_value,squad_size,average_age,foreigners_number,foreigners_percentage,national_team_players,stadium_name,stadium_seats,net_transfer_record,coach_name,last_season,url,add_timestamp,edit_timestamp)
    values (src.club_id, src.club_code, src.name, src.domestic_competition_id, src.total_market_value, src.squad_size, src.average_age, src.foreigners_number, src.foreigners_percentage, src.national_team_players, src.stadium_name, src.stadium_seats, src.net_transfer_record, src.coach_name, src.last_season, src.url, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_clubs
warehouse = xs_backend
after tsk_merge_into_dim_clubs
as 
create or replace stream stm_clubs on table raw_clubs;

alter task tsk_recreate_stm_clubs resume;
alter task tsk_merge_into_dim_clubs resume;
