col grantee for a25

select grantee, owner, table_name, privilege from dba_tab_privs where upper(table_name) like upper('&1');
