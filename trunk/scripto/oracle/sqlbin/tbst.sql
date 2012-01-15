prompt Show objects that are in a certain tablespaces
prompt provide tablespace name
column SEGMENT_NAME format a30
column OWNER format a10
column SEGMENT_TYPE format a10
column TABLESPACE_NAME format a15
set linesize 150
SELECT owner,
segment_name,
segment_type,
tablespace_name,
round(bytes/1048576) MB,
initial_extent,
extents
FROM
DBA_SEGMENTS
WHERE
tablespace_name = '&1'
order by MB
/
