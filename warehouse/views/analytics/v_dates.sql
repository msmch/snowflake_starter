use database core_db;
use schema analytics;

/* 
The view that allow use to select dates in specific period. It's helpfull when you want to create a time series 
from multiple observations but not covering every single day during the period. It's crucial for time series modelling to avoid gaps.
*/

-- Create a view based on the recursive CTE
create or replace view v_dates as
with recursive dates_range as (
    select dateadd(year, -10, current_date()) as date
    union all
    select dateadd(day, 1, date)
    from dates_range
    where date < dateadd(year, 10, current_date())
)
select date
from dates_range;