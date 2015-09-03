select * from dba_sys_privs where upper(privilege) like upper('&1');
