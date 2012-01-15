prompt Show files that make up a tablespaces
set pagesize 50
set linesize 150
column TABLESPACE_NAME format a20
column FILE_NAME format a50
select TABLESPACE_NAME, FILE_NAME, BYTES/1024/1024 MB, AUTOEXTENSIBLE, MAXBYTES/1024/1024 MAXMB from dba_data_files where TABLESPACE_NAME='&1' order by FILE_NAME
/
prompt Prepare sample resize commands
column "Resize command" format a100
select 'alter database datafile '''||FILE_NAME||''' resize 8192M;' "Resize command" from dba_data_files where TABLESPACE_NAME='&1' order by FILE_NAME
/
