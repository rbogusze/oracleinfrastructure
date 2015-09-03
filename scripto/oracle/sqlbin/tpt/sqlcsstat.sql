select
 * 
from 
    v$sql_cs_statistics 
where
    sql_id = '&1'
and child_number like '&2'
order by
    sql_id
  , child_number
/

