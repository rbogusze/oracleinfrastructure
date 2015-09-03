select 
    s.tablespace_name, 
    s.max_next_extent, 
    f.max_bytes
from
    (select tablespace_name, max(next_extent) max_next_extent from dba_segments group by tablespace_name) s,
    (select tablespace_name, max(bytes) max_bytes from dba_free_space group by tablespace_name) f
where
    s.tablespace_name = f.tablespace_name
and s.max_next_extent > f.max_bytes;

