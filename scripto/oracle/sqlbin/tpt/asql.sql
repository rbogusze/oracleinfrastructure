prompt Display active sessions current SQLs

select
    sql_id
  , sql_hash_value
  , sql_child_number
  , count(*)
from
    v$session
where
    status='ACTIVE'
and type !='BACKGROUND'
and sid != (select sid from v$mystat where rownum=1)
group by
    sql_id
  , sql_hash_value
  , sql_child_number
order by
    count(*) desc
/

