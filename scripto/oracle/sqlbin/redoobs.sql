prompt Show who is generating the most redo entries (OBS)
set pagesize 5000
set linesize 1500
column NAME format a12
column USERNAME format a18
column MODULE format a12

select * from (
select sta.sid, sta.value, sya.NAME, ses.serial#, ses.username, ses.process, substr(stx.module,1,11), substr(stx.sql_text,1,100)
from v$sesstat sta
     ,V$SYSSTAT sya
     ,V$SESSION ses
     ,V$SQL stx
where sta.statistic#=sya.statistic#
and sta.sid = ses.sid
and stx.hash_value = ses.sql_hash_value
and sya.name = 'redo size'
order by sta.value desc)
where rownum < 10;


prompt Show who is generating the most redo with request_id (OBS)
set pagesize 5000
set linesize 1500
column NAME format a12
column USERNAME format a18
column MODULE format a12
column user_concurrent_program_name format a30
column os_process_id format a10
column request_id format a10

select * from (
select a.sid, a.value, b.NAME
--       ,c.serial#
       ,c.username
       ,c.process 
       ,trim(fnd.request_id)
       ,fnd.user_concurrent_program_name
from v$sesstat a
    ,V$SYSSTAT b
    ,V$SESSION c
    ,apps.FND_CONCURRENT_WORKER_REQUESTS fnd
where a.statistic#=b.statistic#
and a.sid = c.sid
and b.name = 'redo size'
and a.value != 0
and fnd.os_process_id = c.process
order by a.value desc
)
where rownum < 10;
