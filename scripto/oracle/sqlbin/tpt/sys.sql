COL sys_value HEAD "VALUE" FOR 9999999999999999999999999

select name, value sys_value from v$sysstat where lower(name) like lower('%&1%');
