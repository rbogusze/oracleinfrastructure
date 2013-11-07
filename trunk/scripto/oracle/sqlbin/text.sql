prompt Show sql text based on old hash_value
select sql_text from v$sqltext where sql_id = (select SQL_ID from v$sql where OLD_HASH_VALUE=&1) order by piece asc;
