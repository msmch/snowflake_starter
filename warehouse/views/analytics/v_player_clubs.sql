-- View allowing to see player carreers in the clubs from top European leagues

use database core_db;


create view analytics.v_player_clubs 
as 
select 
    a.player_id, 
    a.player_club_id, 
    a.player_name,
    coalesce(c.name, 'uknown') as club_name,
    c.domestic_competition_id,
    case 
        when c.domestic_competition_id is null then 'unknown' 
        else initcap(replace(cpt.name, '-', ' '))
    end as domestic_league_name,
    min(date) as first_appearance_dt, 
    max(date) as last_appearance_dt, 
    count(*) as appearances
from transformed.dim_appearances a
left join transformed.dim_clubs c on a.player_club_id = c.club_id
left join transformed.dim_competitions cpt on c.domestic_competition_id = cpt.competition_id
group by 
    1, 2, 3, 4, 5, 6;