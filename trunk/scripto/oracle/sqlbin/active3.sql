prompt Active session with sql text, all sessions, no exceptions
column USERNAME format a14
select distinct ses.SID, ses.sql_hash_value, ses.USERNAME, pro.SPID "OS PID", substr(stx.sql_text,1,200)
from V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
where ses.paddr = pro.addr
and stx.hash_value = ses.sql_hash_value
;


prompt Active session with wait
set linesize 200
column EVENT format a30
column USERNAME format a14
select sw.event,sw.wait_time,s.username,s.sid,s.serial#,s.SQL_HASH_VALUE 
from v$session s, v$session_wait sw 
where s.sid=sw.sid 
;

prompt Prepare commands to tracing
SELECT 'execute dbms_system.set_ev('||SID||', '||SERIAL#||', 10046, 12, '''');' 
FROM V$SESSION 
;


