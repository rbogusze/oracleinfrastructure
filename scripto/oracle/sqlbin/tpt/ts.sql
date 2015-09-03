select  
	c.ts#
  , t.tablespace_name
  , t.block_size blksz
  , status
  , t.bigfile
  , contents
  , logging
  , force_logging forcelog 
  , extent_management
  , allocation_type
  , segment_space_management ASSM
  , min_extlen EXTSZ
  , compress_for
from 
	v$tablespace c, 
	dba_tablespaces t
where c.name = t.tablespace_name
and   upper(tablespace_name) like upper('%&1%');




