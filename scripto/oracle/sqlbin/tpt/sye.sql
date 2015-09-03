select * from v$system_event where lower(event) like lower('%&1%');
