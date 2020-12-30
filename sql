# how to find what percent of people selected 'other' in a residence type field and then changed their answer from 'other' within 30 minutes of the first time they completed a funnel experience

with urm_data as(
select 
id, column:drivers[0]:residence_ownership owner --pull from json blob
from event_pipeline
where timestamp >'12/01/2020'
and owner='other'
),

funnel_end as(
select id, min(timestamp) funnel_end_timestamp 
from event_pipeline
where timestamp >'12/01/2020'
group by 1
),

edit_data as(
select i.id,
i.interaction_key,
i.timestamp,
datediff(minute,min_edit_time,f.timestamp) date_diff
from funnel_answer i
where i.timestamp >'12/01/2020'
and i.interaction_key = 'residence_ownership'
and i.is_edit = 'true'
having date_diff <30
),

edit_after_funnel_end as (
select e.tzacid
from edit_data e
left join funnel_end f on f.id=e.id
where e.timestamp> f.timestamp
)

select count (distinct e.id) count_edited_residence, count (distinct u.id) count_answered_residence_other,
100.0*(count_edited_residence/count_answered_residence_other) as "percent other edited vs other total"
from urm_data u
left join edit_after_funnel_end e on e.id = u.id
