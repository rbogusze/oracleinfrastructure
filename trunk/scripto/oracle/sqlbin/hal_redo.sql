set pagesize 5000
set linesize 1500
column NAME format a12
column USERNAME format a18
column MODULE format a12



select * from (
select a.sid, a.value, b.NAME, c.serial#, c.username, c.process, c.MACHINE 
from v$sesstat a, V$SYSSTAT b, V$SESSION c
where a.statistic#=b.statistic#
and a.sid = c.sid
and b.name = 'redo size'
order by a.value desc)
where rownum < 10;
