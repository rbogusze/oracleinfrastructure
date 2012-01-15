
set linesize 400
set pagesize 300
col file_name format a60
col tablespace_name format a30
col fsize format 999999


select d.status,
  db.name dbname,
  d.tablespace_name tsname,
  d.extent_management,
  d.allocation_type,
  'NOAUTOEXTENSIBLE' "AUTOEXTEND",
  d.contents "Type",
  to_char(ts.SizeMB,'99G999G990D90','NLS_NUMERIC_CHARACTERS = ''.,'' ') as "Size (M)",
  to_char(ts.SizeMB - fs.FreeMB,
  '99G999G990D90', 'NLS_NUMERIC_CHARACTERS = '',.'' ')
  "Used (M)",
  to_char((ts.SizeMB - fs.FreeMB) / ts.SizeMB * 100,
  '990D90', 'NLS_NUMERIC_CHARACTERS = '',.'' ')
  "Used_PER",
  NULL "MaxSizeOfTB"
from
  v$database db, 
  dba_tablespaces d,
  (Select tablespace_name, sum(bytes)/1024/1024 SizeMB from dba_data_files where AUTOEXTENSIBLE = 'NO'  group by tablespace_name ) ts,
  (Select tablespace_name,sum(bytes)/1024/1024 FreeMB from dba_free_space group by tablespace_name) fs
where
  d.tablespace_name=ts.tablespace_name and
  ts.tablespace_name=fs.tablespace_name and
  d.CONTENTS!='TEMPORARY'
union
select d.status,
  db.name dbname,
  d.tablespace_name tsname,
  d.extent_management,
  d.allocation_type,
  'AUTOEXTENSIBLE' "AUTOEXTEND",
  d.contents "Type",
  to_char(ts.SizeMB,'99G999G990D90','NLS_NUMERIC_CHARACTERS = ''.,'' ') as "Size (M)",
  to_char(ts.SizeMB - fs.FreeMB,
  '99G999G990D90', 'NLS_NUMERIC_CHARACTERS = '',.'' ')
  "Used (M)",
  to_char((ts.SizeMB - fs.FreeMB) / ts.SizeMB * 100,
  '990D90', 'NLS_NUMERIC_CHARACTERS = '',.'' ')
  "Used_PER",
  to_char(ts.MaxSizeMB,'99G999G990D90','NLS_NUMERIC_CHARACTERS = ''.,'' ') "MaxSizeOfTB"
from
  v$database db,
  dba_tablespaces d,
  (Select tablespace_name, sum(bytes)/1024/1024 SizeMB,sum(maxbytes)/1024/1024 MaxSizeMB from dba_data_files where AUTOEXTENSIBLE = 'YES'  group by tablespace_name ) ts,
  (Select tablespace_name,sum(bytes)/1024/1024 FreeMB from dba_free_space group by tablespace_name) fs
where
  d.tablespace_name=ts.tablespace_name and
  ts.tablespace_name=fs.tablespace_name and
  d.CONTENTS!='TEMPORARY'
order by 6 desc , 10 desc;



Select tabs_to_resize.tablespace_name, tabs_to_resize.PerUsed as "Tablespace Space Used Per", fn.file_name, round((fn.bytes/1024/1024),0) sizeMB from
(Select
  total.tablespace_name,round((total.total_size - free.total_free)/total.total_size * 100) PerUsed
from
(select a.tablespace_name, round(sum(a.Bytes)/1024/1024) total_size from dba_data_files a, dba_tablespaces b  where b.contents='PERMANENT' and a.tablespace_name=b.tablespace_name group by a.tablespace_name) total,
(select a.tablespace_name, round(sum(a.Bytes)/1024/1024) total_free from dba_free_space a, dba_tablespaces b where
b.contents='PERMANENT' and a.tablespace_name=b.tablespace_name group by a.tablespace_name) free
where
total.tablespace_name=free.tablespace_name and
((total.total_size - free.total_free)/total.total_size) * 100 > 85) tabs_to_resize,
dba_data_files fn
where
fn.tablespace_name=tabs_to_resize.tablespace_name
order by 2 desc,4 asc ;




