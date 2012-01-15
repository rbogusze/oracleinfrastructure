column event format a40
select event, count(*) from v$session_wait group by event order by count(*);
