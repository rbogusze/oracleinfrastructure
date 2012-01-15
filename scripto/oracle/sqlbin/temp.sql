prompt Show who is using the temporary tablespace for sorting
column USERNAME format a15
column SIZE format a15
column SID_SERIAL format a15
column PROGRAM format a15
column TABLESPACE format a15
SELECT b.TABLESPACE,
  ROUND(((b.blocks *p.VALUE) / 1024 / 1024),   2) || 'M' "SIZE",
  a.sid || ',' || a.serial# sid_serial,
  a.username,
  a.PROGRAM
FROM sys.v_$session a,
  sys.v_$sort_usage b,
  sys.v_$parameter p
WHERE p.name = 'db_block_size'
 AND a.saddr = b.session_addr
ORDER BY b.TABLESPACE,
  b.blocks;
