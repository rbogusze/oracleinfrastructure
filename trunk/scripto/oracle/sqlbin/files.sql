prompt Where are my files?
select FILE_NAME from dba_temp_files;
select FILE_NAME from dba_data_files;
select member from v$logfile;
select value from v$parameter where name='control_files';
select value from v$parameter where name='spfile';
