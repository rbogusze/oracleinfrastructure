column OWNER format a15
column OBJECT_NAME format a30
column OBJECT_TYPE format a10
select OWNER, OBJECT_NAME, OBJECT_TYPE from dba_objects where OBJECT_NAME=upper('&1');
