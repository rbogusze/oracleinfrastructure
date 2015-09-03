col lib_owner     head OWNER     for a25
col lib_file_spec head FILE_SPEC for a80

select
	owner		lib_owner,
	library_name,
	dynamic 	dyn,
	status,
	file_spec 	lib_file_spec
from
	dba_libraries
where
	lower(library_name) like lower ('&1')
or	lower(file_spec)    like lower ('&1')
/
