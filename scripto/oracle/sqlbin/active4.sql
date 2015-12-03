prompt Different from active.sql
prompt - no trace commands
prompt - filter out: Streams AQ: waiting for messages in the queue, pipe get

prompt Active session with sql text
column USERNAME format a14
column EVENT format a30
column USERNAME format a14
set linesize 200
select distinct ses.SID, ses.sql_hash_value, stx.old_hash_value, ses.USERNAME, pro.SPID "OS PID", substr(stx.sql_text,1,200), sw.event,sw.wait_time,ses.serial#, stx.sql_id
from V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
    ,v$session_wait sw
where ses.paddr = pro.addr
and ses.sid=sw.sid
and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and ses.USERNAME not in ('SYS', 'SYSTEM','DBSNMP','SYSMAN')
and sw.event not in ('pipe get','Streams AQ: waiting for messages in the queue')
;

