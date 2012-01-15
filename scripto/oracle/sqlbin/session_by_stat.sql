var vStatName VARCHAR2(50);

PROMPT THIS SCRIPT TAKES ONE PARAMETER - It it the name of statistic, choose number of statistic
PROMPT 1 -redo size
PROMPT 2 - consistent gets
PROMPT 3 - physical reads
PROMPT 4 - sorts (disk)
PROMPT 5 - user commits

ACCEPT vStatNumber prompt "Put the stat number:"
begin
Select decode(&&vStatNumber,1,'redo size',2,'consistent gets',3,'sorts (disk)',4,'user commits') into :vStatName from dual;
end;
/
PRINT vStatName
set pagesize 5000
set linesize 1500
column NAME format a25
column USERNAME format a18

select * from (
select a.sid, a.value, b.NAME, c.serial#, c.username, c.process 
from v$sesstat a, V$STATNAME b, V$SESSION c
where a.statistic#=b.statistic#
and a.sid = c.sid
and b.name = :vStatName
and a.value != 0
order by a.value desc)
where rownum < 10;

PROMPT SID THAT ARE IN DBS_JOBS_RUNNING
select /*+ RULE */ sid from dba_jobs_running;
