select * from v$version;
select name from v$database;
set pagesize 999
column status format a15
column version format a15
column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version from dba_registry order by modified;
column object_name format A30
column owner format A20
select object_name, owner, object_type from dba_objects where status != 'VALID' order by owner;
