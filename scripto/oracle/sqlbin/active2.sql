prompt Active session with sql text
select distinct ses.SID, ses.sql_hash_value, ses.USERNAME, ses.PROCESS, substr(stx.sql_text,1,200)
from V$SESSION ses
    ,V$SQL stx
where ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and USERNAME not in ('SYS', 'SYSTEM')
;

prompt Prepare commands to tracing
SELECT 'execute dbms_system.set_ev('||SID||', '||SERIAL#||', 10046, 12, '''');' 
FROM V$SESSION 
WHERE audsid = userenv('SESSIONID')
and status = 'ACTIVE'
and USERNAME not in ('SYS', 'SYSTEM')
;


