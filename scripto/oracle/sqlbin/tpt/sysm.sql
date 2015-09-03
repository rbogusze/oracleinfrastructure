prompt Display SYSTEM metrics from V$METRIC

select
   group_id
 , metric_name
 , value
 , metric_unit
from
   v$metric
where
   1=1
and group_id in (select group_id from v$metricgroup where name like 'System Metrics % Duration')
and lower(metric_name) like lower('%&1%')
/

