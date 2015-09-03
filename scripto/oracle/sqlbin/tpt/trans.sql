col 0xFLAG just right


select
    s.sid
  , s.serial#
  , s.username
  , t.addr taddr
  , s.saddr ses_addr
  , t.used_ublk
  , t.used_urec
--  , t.start_time
  , to_char(t.flag, 'XXXXXXXX') "0xFLAG"
  , t.status||CASE WHEN BITAND(t.flag,128) = 128 THEN ' ROLLING BACK' END status
  , t.start_date
  , XIDUSN 
  , XIDSLOT
  , XIDSQN
  , t.xid
  , t.prv_xid
  , t.ptx_xid
from
    v$session s
  , v$transaction t
where
    s.saddr = t.ses_addr
/


