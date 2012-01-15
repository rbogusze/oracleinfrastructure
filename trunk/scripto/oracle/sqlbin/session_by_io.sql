set linesize 400
set pagesize 400
select * from (
select	nvl(ses.USERNAME,'ORACLE PROC') username,
	PROCESS pid,
	ses.SID sid,
	SERIAL#,
	PHYSICAL_READS,
	BLOCK_GETS,
	CONSISTENT_GETS,
	BLOCK_CHANGES,
	CONSISTENT_CHANGES
from	v$session ses, 
	v$sess_io sio
where 	ses.SID = sio.SID
order 	by PHYSICAL_READS desc
)
where ROWNUM < 10
/

PROMPT SID THAT ARE IN DBS_JOBS_RUNNING
select /*+ RULE */ sid from dba_jobs_running;

exit
