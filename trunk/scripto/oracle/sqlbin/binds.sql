prompt Show bind values based on old sql hash value
SELECT name,      position ,      datatype_string ,      was_captured,      value_string  FROM   v$sql_bind_capture  WHERE  sql_id = (select SQL_ID from v$sql where OLD_HASH_VALUE=&1)
/
