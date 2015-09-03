select owner, segment_name, partition_name, tablespace_name, extent_id
from dba_extents
where file_id = &1
and &2 between block_id and block_id + blocks - 1;
