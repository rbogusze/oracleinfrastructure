col kghluidx head SUB|POOL
col kghludur head SSUB|POOL
col kghlufsh head FLUSHED|CHUNKS
col kghluops head "LRU LIST|OPERATIONS"
col kghlurcr head RECURRENT|CHUNKS
col kghlutrn head TRANSIENT|CHUNKS
col kghlunfu head "FREE UNPIN|UNSUCCESS"
col kghlunfs head "LAST FRUNP|UNSUCC SIZE"
col kghlurcn head RESERVED|SCANS
col kghlurmi head RESERVED|MISSES
col kghlurmz head "RESERVED|MISS SIZE"
col kghlurmx head "RESERVED|MISS MAX SZ"


select
    kghluidx
  , kghludur
  , kghlufsh
  , kghluops
  , kghlurcr
  , kghlutrn
  , kghlunfu
  , kghlunfs
--  , kghlumxa
--  , kghlumes
--  , kghlumer
  , kghlurcn
  , kghlurmi
  , kghlurmz
  , kghlurmx
from
    x$kghlu
order by
    kghluidx
  , kghludur
/
