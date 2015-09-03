select 
	lock_id1,
	session_id, 
	lock_Type, 
	mode_held, 
	mode_requested
from 
	dba_lock_internal 
where 
	lower(lock_id1) like lower('&1')
/
