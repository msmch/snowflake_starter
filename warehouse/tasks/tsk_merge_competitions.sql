use database core_db;
use schema staging;


create or replace task tsk_merge_into_dim_competitions
warehouse = xs_backend
schedule = '1 minute'
when system$stream_has_data('stm_competitions')
as 
merge into transformed.dim_competitions as dest
using (
    select *
    from raw_competitions
    where add_timestamp::date = current_date() or edit_timestamp::date = current_date() -- focus only on data added today to reduce computation resource needed
    qualify 1 = row_number() over (partition by competition_id order by add_timestamp desc)
) as src
on dest.competition_id = src.competition_id
when matched then
    update set 
                    dest.competition_id = src.competition_id,
        dest.competition_code = src.competition_code,
        dest.name = src.name,
        dest.sub_type = src.sub_type,
        dest.type = src.type,
        dest.country_id = src.country_id,
        dest.country_name = src.country_name,
        dest.domestic_league_code = src.domestic_league_code,
        dest.confederation = src.confederation,
        dest.url = src.url,
        dest.add_timestamp = src.add_timestamp,
        dest.edit_timestamp = src.edit_timestamp
when not matched then
    insert (competition_id,competition_code,name,sub_type,type,country_id,country_name,domestic_league_code,confederation,url,add_timestamp,edit_timestamp)
    values (src.competition_id, src.competition_code, src.name, src.sub_type, src.type, src.country_id, src.country_name, src.domestic_league_code, src.confederation, src.url, src.add_timestamp, src.edit_timestamp);

create or replace task tsk_recreate_stm_competitions
warehouse = xs_backend
after tsk_merge_into_dim_competitions
as 
create or replace stream stm_competitions on table raw_competitions;

alter task tsk_recreate_stm_competitions resume;
alter task tsk_merge_into_dim_competitions resume;
