prompt Active session with sql text
column USERNAME format a14
select distinct ses.SID, ses.sql_hash_value, ses.USERNAME, pro.SPID "OS PID", substr(stx.sql_text,1,200)
from V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
where ses.paddr = pro.addr
and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and ses.USERNAME not in ('SYS', 'SYSTEM')
;


prompt Active session with wait
set linesize 200
column EVENT format a30
column USERNAME format a14
select sw.event,sw.wait_time,s.username,s.sid,s.serial#,s.SQL_HASH_VALUE 
from v$session s, v$session_wait sw 
where s.sid=sw.sid 
and s.USERNAME is not null
and s.USERNAME not in ('SYS', 'SYSTEM','DBSNMP','SYSMAN')
and s.status = 'ACTIVE';

prompt Prepare commands to kill
select 'ALTER SYSTEM KILL SESSION ''' || SID || ',' || SERIAL# || ''';' "Command to kill the session"
FROM V$SESSION 
WHERE status = 'ACTIVE'
and USERNAME is not null
and USERNAME not in ('SYS', 'SYSTEM','DBSNMP','SYSMAN')
;

prompt Prepare OS command to kill the stubborn session with KILLED status from OS level
select 'kill -9 '||p.spid from v$process p, v$session s 
where p.addr = s.paddr and s.status = 'KILLED';
