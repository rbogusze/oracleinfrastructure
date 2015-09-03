select
    g.group_id
  , g.name group_name
  , n.metric_name
  , n.metric_unit
from
    v$metricname n
  , v$metricgroup g
where
    n.group_id = g.group_id
and
    lower(n.metric_name) like lower('%&1%')
/
