prompt Active session with sql text
set linesize 130
select distinct ses.SID, ses.sql_hash_value, ses.prev_hash_value, ses.USERNAME, ses.PROCESS, substr(stx.sql_text,1,200)
from V$SESSION ses
    ,V$SQL stx
where ((stx.hash_value = ses.sql_hash_value) or (stx.hash_value = ses.prev_hash_value))
and USERNAME not in ('SYS', 'SYSTEM')
;



