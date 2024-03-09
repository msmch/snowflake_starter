use schema analytics; 


create view v_player_daily_valuations 
as
with dates as (
    select date
    from v_dates
    where 
        date <= current_date() 
        and date >= (
            select min(date) from transformed.fact_player_valuations
        )
)
, full_time_series as (
    select
        date,
        player_id
    from transformed.dim_players 
    cross join dates
)
, min_appearance_dates as (
    select 
        player_id, 
        min(first_appearance_dt) as first_appearance
    from v_player_clubs
    group by 1
)
, player_valuations as (
    select 
        t.player_id,
        t.date as date,
        v.date as valuation_date,
        lag(v.market_value_in_eur) ignore nulls over (partition by t.player_id order by t.date asc) as market_value_lag,
        v.market_value_in_eur as mv_raw,
        coalesce(v.market_value_in_eur, market_value_lag) as market_value_in_eur
    from full_time_series t
    left join transformed.fact_player_valuations v 
        on t.player_id = v.player_id
        and t.date = v.date
)
select 
    v.player_id,
    v.date,
    v.valuation_date is not null as valuation_updated,
    v.market_value_in_eur
from player_valuations v
left join min_appearance_dates ad on v.player_id = ad.player_id
where v.date >= ad.first_appearance;