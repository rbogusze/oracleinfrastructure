select /*+ ordered use_hash(s) */
    b.name
  , b.description
  , s.sid
  , p.pid opid
  , p.spid
  , b.paddr
  , s.saddr
from 
    v$bgprocess b
  , v$process p
  , v$session s
where 
    b.paddr = p.addr
and b.paddr = s.paddr
and p.addr  = s.paddr
and (lower(b.name) like lower('&1') or lower(b.description) like lower('&1'))
/
