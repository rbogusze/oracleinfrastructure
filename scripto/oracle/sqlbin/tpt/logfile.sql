col logfile_member head MEMBER for a100

select 
	l.sequence#, 
	l.group#, 
	l.thread#, 
	lf.member	logfile_member
from   
	v$log l, 
	v$logfile lf
where  
	l.group# = lf.group#
order by
	l.group#
/
