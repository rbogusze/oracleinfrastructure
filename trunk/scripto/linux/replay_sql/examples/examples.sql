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
show parameter spfile;
alter system set \"_B_TREE_BITMAP_PLANS\"=FALSE scope=spfile;
