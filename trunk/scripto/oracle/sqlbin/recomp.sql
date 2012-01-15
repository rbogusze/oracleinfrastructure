prompt Show the table/index that were recently experienced DDL
column OWNER format a10
column OBJECT_NAME format a30
set pagesize 50
set linesize 200
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from (
select owner, object_name, object_type, LAST_DDL_TIME from dba_objects
where LAST_DDL_TIME is not null
and owner not in ('SYS')
and OBJECT_TYPE in ('TABLE','INDEX')
order by LAST_DDL_TIME desc)
where rownum < 10;

prompt Show the objects that were recently generated
column OWNER format a10
column OBJECT_NAME format a30
set pagesize 50
set linesize 200
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from (
select owner, object_name, object_type, timestamp from dba_objects
where timestamp is not null
and owner not in ('SYS')
order by timestamp desc)
where rownum < 20;
