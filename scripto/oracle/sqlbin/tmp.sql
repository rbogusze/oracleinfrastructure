prompt Show size of temp tablespaces
set pagesize 50
select FILE_NAME, TABLESPACE_NAME, (BYTES/1024/1024) MB, AUTOEXTENSIBLE, (MAXBYTES/1024/1024) MAXMB from dba_temp_files;


prompt Prepare commands to extend temp size
set linesize 200
select 'alter database tempfile '''||FILE_NAME||''' AUTOEXTEND on next 100M maxsize 60G;'  from dba_temp_files;
