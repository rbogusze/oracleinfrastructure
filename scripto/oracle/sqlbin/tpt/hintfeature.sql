select name,sql_feature,version,version_outline from v$sql_hint where lower(sql_feature) like lower('%&1%');
