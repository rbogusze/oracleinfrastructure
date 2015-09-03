select 
    addr
  , set_id
  , dbwr_num       dbwr#
  , flag
  , blk_size
  , proc_group
  , CNUM_SET
  , CNUM_REPL
  , ANUM_REPL
  , CKPT_LATCH
  , CKPT_LATCH1
  , SET_LATCH
  , COLD_HD
  , HBMAX
  , HBUFS 
from 
    X$KCBWDS
/


