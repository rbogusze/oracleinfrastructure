prompt Show who is generating the most redo entries ( redo size )
set pagesize 5000
set linesize 1500
--column NAME     format       a12
column USERNAME format       a25
column MODULE   format       a12
column SIZEMIB  format 999999.99
column machine  format       a40
--   b.NAME,
select * from (
select a.sid,c.serial#,round (a.value/1024/1024,2) sizeMiB, c.username, c.process, c.MACHINE 
from v$sesstat a, V$SYSSTAT b, V$SESSION c
where a.statistic#=b.statistic#
and a.sid = c.sid
and b.name = 'redo size'
order by a.value desc)
where rownum < 10;
