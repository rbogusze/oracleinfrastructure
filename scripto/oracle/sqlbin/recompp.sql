rem For paloka project, created from recomp.sql
column OWNER format a10
column OBJECT_NAME format a30
set pagesize 50
set linesize 200
set feedback off

select * from (
select owner, object_name, object_type, timestamp from dba_objects
where timestamp is not null
and owner not in ('SYS')
order by timestamp desc)
where rownum < 20;
