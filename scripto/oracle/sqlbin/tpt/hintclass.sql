select name,class,version,version_outline from v$sql_hint where lower(class) like lower('%&1%');
