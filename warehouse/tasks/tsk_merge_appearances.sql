use database core_db;
use schema staging;


create or replace task tsk_merge_into_dim_appearances
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_appearances')
as 
merge into transformed.dim_appearances as dest
using (
    select *
    from raw_appearances
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by appearance_id order by add_timestamp desc)
) as src
on dest.appearance_id = src.appearance_id
when matched then
    update set 
                    dest.appearance_id = src.appearance_id,
        dest.game_id = src.game_id,
        dest.player_id = src.player_id,
        dest.player_club_id = src.player_club_id,
        dest.player_current_club_id = src.player_current_club_id,
        dest.date = src.date,
        dest.player_name = src.player_name,
        dest.competition_id = src.competition_id,
        dest.yellow_cards = src.yellow_cards,
        dest.red_cards = src.red_cards,
        dest.goals = src.goals,
        dest.assists = src.assists,
        dest.minutes_played = src.minutes_played,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (appearance_id,game_id,player_id,player_club_id,player_current_club_id,date,player_name,competition_id,yellow_cards,red_cards,goals,assists,minutes_played,add_timestamp,edit_timestamp)
    values (src.appearance_id, src.game_id, src.player_id, src.player_club_id, src.player_current_club_id, src.date, src.player_name, src.competition_id, src.yellow_cards, src.red_cards, src.goals, src.assists, src.minutes_played, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_appearances
warehouse = xs_backend
after tsk_merge_into_dim_appearances
as 
create or replace stream stm_appearances on table raw_appearances;

alter task tsk_recreate_stm_appearances resume;
alter task tsk_merge_into_dim_appearances resume;
