select 
	* 
from 
	dba_audit_object
where
	upper(owner) like upper('&1')
and 	upper(obj_name) like upper('&2')
order by
	timestamp desc
/
