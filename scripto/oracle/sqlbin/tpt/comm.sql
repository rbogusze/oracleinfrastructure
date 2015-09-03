prompt Not listing tables without comments...

column comm_comments heading COMMENTS format a90

select 
	owner, 
	table_name, 
	comments comm_comments
from 
	all_tab_comments 
where 
	lower(table_name) like lower('%&1%')
and	comments is not null
/

