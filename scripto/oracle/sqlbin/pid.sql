select s.sid, s.username,
       to_char(s.logon_time,'DD-MON HH24:MI:SS') logon_time,        
       s.module, s.machine, s.osuser,
       s.status, s.sql_hash_value, stx.OLD_HASH_VALUE, substr(stx.sql_text,1,200)
from  v$session s, v$process p, V$SQL stx
where p.spid=nvl('&unix_process',' ')
and s.paddr=p.addr
and stx.hash_value = s.sql_hash_value
order by s.sid
/ 
