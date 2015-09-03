select 
	session_id, 
	lock_Type, 
	mode_held, 
	mode_requested,
	lock_id1
from 
	dba_lock_internal 
where 
	session_id in (&1)
/

