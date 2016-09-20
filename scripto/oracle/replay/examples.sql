select FILE#, BLOCK#, BLOCKS, CORRUPTION_CHANGE#, CORRUPTION_TYPE from v\$database_block_corruption;

# Prepare for autotrace
create role plustrace; 
grant select on v_\$sesstat to plustrace;
grant select on v_\$statname to plustrace;
grant select on v_\$mystat to plustrace;
grant plustrace to dba with admin option;
grant plustrace to juni;
grant select on V_\$SESSION to juni;

# Czy sga_max_size jest ustawiony recznie
select ISDEFAULT from V\$PARAMETER where NAME = 'sga_max_size';

exec dbms_stats.create_stat_table(ownname => 'SYSTEM', stattab => 'STAT_AT_20090509auto',  tblspace => 'USERS');
exec dbms_stats.export_schema_stats(ownname => 'JUNI', stattab => 'STAT_AT_20090509auto', statid => 'A20090509auto', statown => 'SYSTEM');
exec dbms_stats.gather_table_stats(ownname=>'JUNI' ,tabname=>'HAL_DOKUMENTY_ZLECEN' ,method_opt=>'for all indexed columns size 200' ,cascade=>TRUE);
show parameter _b_tree_bitmap_plans;
show parameter spfile;
alter system set \"_B_TREE_BITMAP_PLANS\"=FALSE scope=spfile;

# check replication jobs
select JOB, WHAT, NEXT_DATE, BROKEN from user_jobs
where BROKEN = 'Y';
select OWNER, INDEX_NAME from dba_indexes where INDEX_NAME=upper('DKZL_DATA_SPRZEDAZY');
alter system set \"_b_tree_bitmap_plans\"=FALSE scope=spfile sid='*';
select FLASHBACK_ON from v\$database;
column KOD format a6
column PARAMETR format a16
column WARTOSC format a36
select KOD, PARAMETR, WARTOSC from hal_parametry_systemu where TYP_PARAMETRU ='FRMHINT';
select OWNER, INDEX_NAME from dba_indexes where INDEX_NAME in ('DKZL_DATA_SPRZEDAZY');
select OWNER, TABLE_NAME, CACHE from dba_tables where CACHE='    Y';
select OWNER, TABLE_NAME, CACHE from dba_tables where CACHE='    Y';
select dbms_stats.get_param('ESTIMATE_PERCENT') from dual; 
exec DBMS_STATS.SET_PARAM('ESTIMATE_PERCENT','100');
select SEQUENCE_OWNER, SEQUENCE_NAME, CACHE_SIZE, LAST_NUMBER  from dba_sequences where SEQUENCE_OWNER not in ('SYS') and CACHE_SIZE < 20 and LAST_NUMBER > 219610 order by LAST_NUMBER;

