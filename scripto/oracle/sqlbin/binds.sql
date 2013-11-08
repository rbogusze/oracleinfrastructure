prompt Show bind values based on old sql hash value
set linesize 200
column NAME format a10
column value_string format a20
SELECT name, value_string, position, datatype_string, was_captured FROM   v$sql_bind_capture  WHERE  sql_id = (select distinct SQL_ID from v$sql where OLD_HASH_VALUE=&1)
/
