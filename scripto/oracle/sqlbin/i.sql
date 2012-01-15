rem Show indexes based on provided table
column OWNER format a15
column INDEX_NAME format a30
column INDEX_TYPE format a10
rem select OWNER, INDEX_NAME, INDEX_TYPE from all_indexes where TABLE_NAME=upper('&1') 
rem order by INDEX_NAME;

column COLUMN_NAME format a30
set linesize 200
select index_name, table_name, column_name from all_ind_columns where table_name=upper('&1') order by table_name;
