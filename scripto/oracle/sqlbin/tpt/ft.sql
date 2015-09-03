select
  name
, type
from
  v$fixed_table
where
  lower(name) like lower('%&1%')
order by
  1
/

