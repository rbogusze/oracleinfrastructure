prompt A-Script: Display active sessions grouped by &1....

select
    &1
  , count(*)
from
    v$session
where
    status='ACTIVE'
and type !='BACKGROUND'
and wait_class != 'Idle'
and sid != (select sid from v$mystat where rownum=1)
group by
    &1
order by
    count(*) desc
/

