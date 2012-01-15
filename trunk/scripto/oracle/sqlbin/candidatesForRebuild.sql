set linesize 300
set pagesize 0

PROMPT INDEKSY DO PRZEBUDOWANIA

select owner,index_name from dba_indexes where status='UNUSABLE' order by owner;


PROMPT KOMENDY DO WYKONANIA  

select 'ALTER INDEX ' || owner || '.' || index_name || ' rebuild;'  "COMMAND" from dba_indexes where status='UNUSABLE' order by owner;

PROMPT PARTYCJE INDEKSOW DO PRZEBUDOWANIA

select index_owner,index_name,partition_name from dba_ind_partitions where status='UNUSABLE';

PROMPT KOMENDY DO WYKONANIA

select 'ALTER INDEX ' || index_owner || '.' || index_name || ' rebuild partition ' || partition_name || ';' "COMMAND" from dba_ind_partitions
where status='UNUSABLE' order by index_owner;






