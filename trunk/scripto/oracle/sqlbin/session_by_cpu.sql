select * from (
select 	nvl(ss.USERNAME,'ORACLE PROC') username,
	se.SID,
	VALUE cpu_usage
from 	v$session ss, 
	v$sesstat se, 
	v$statname sn
where  	se.STATISTIC# = sn.STATISTIC#
and  	NAME = 'CPU used by this session'
and  	se.SID = ss.SID
-- and	ss.status='ACTIVE'
order  	by VALUE desc
) 
where ROWNUM <= 10
/


PROMPT SID THAT ARE IN DBS_JOBS_RUNNING
select /*+ RULE */ sid from dba_jobs_running;

exit
