select * from (
	select timestamp, username, os_username, userhost, terminal, action_name 
	from dba_audit_session
	order by timestamp desc
)
where rownum <= 20;
