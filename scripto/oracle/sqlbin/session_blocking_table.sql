/* script shows which sessions keep lock on given table */
PROMPT THIS SCRIPT TAKES 2 PARAMETERS OWNER AND TABLE_NAME

ACCEPT vTabOwner prompt "GIVE TABLE OWNER: "
ACCEPT vTabName prompt "GIVE TABLE NAME: "

set linesize 400
set pagesize 500
col SQL_TEXT_PART format a70
col USERNAME format a15


select
lo.oracle_username, s.sql_id,l.sid, l.type,l.lmode, l.BLOCK "IS_BLOCKING",substr(trim(both ' ' from sa.sql_text),1,70) "SQL_TEXT_PART"
from
v$locked_object lo,v$lock l, v$session s, v$sqlarea sa
where
lo.object_id in (Select object_id from dba_objects where owner='&vTabOwner' and object_name='&vTabName' and object_type='TABLE') and
lo.session_id=l.sid and
l.sid = s.sid and
s.sql_id = sa.sql_id (+)
/

exit;



