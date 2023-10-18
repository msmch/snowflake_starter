use database core_db;
use schema staging;


create or replace task tsk_merge_into_fact_club_games
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_club_games')
as 
merge into transformed.fact_club_games as dest
using (
    select *
    from raw_club_games
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by club_game_id order by add_timestamp desc)
) as src
on dest.club_game_id = src.club_game_id
when matched then
    update set 
                    dest.game_id = src.game_id,
        dest.club_id = src.club_id,
        dest.club_game_id = src.club_game_id,
        dest.own_goals = src.own_goals,
        dest.own_position = src.own_position,
        dest.own_manager_name = src.own_manager_name,
        dest.opponent_id = src.opponent_id,
        dest.opponent_goals = src.opponent_goals,
        dest.opponent_position = src.opponent_position,
        dest.opponent_manager_name = src.opponent_manager_name,
        dest.hosting = src.hosting,
        dest.is_win = src.is_win,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (game_id,club_id,club_game_id,own_goals,own_position,own_manager_name,opponent_id,opponent_goals,opponent_position,opponent_manager_name,hosting,is_win,add_timestamp,edit_timestamp)
    values (src.game_id, src.club_id, src.club_game_id, src.own_goals, src.own_position, src.own_manager_name, src.opponent_id, src.opponent_goals, src.opponent_position, src.opponent_manager_name, src.hosting, src.is_win, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_club_games
warehouse = xs_backend
after tsk_merge_into_fact_club_games
as 
create or replace stream stm_club_games on table raw_club_games;

alter task tsk_recreate_stm_club_games resume;
alter task tsk_merge_into_fact_club_games resume;
