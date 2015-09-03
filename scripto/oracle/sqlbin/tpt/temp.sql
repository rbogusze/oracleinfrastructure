SELECT 
    u.inst_id
  , u.username
  , s.sid
  , u.session_num serial#
  , u.sql_id
  , u.tablespace
  , u.contents
  , u.segtype
  , ROUND( u.blocks * t.block_size / (1024*1024) ) MB
  , u.extents
  , u.blocks
FROM 
    gv$tempseg_usage u
  , gv$session s
  , dba_tablespaces t
WHERE
    u.session_addr = s.saddr
AND u.inst_id = s.inst_id
AND t.tablespace_name = u.tablespace
ORDER BY
    mb DESC
/

