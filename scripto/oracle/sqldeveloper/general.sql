alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from APPLSYS.AD_BUGS;
select * from dual;

select * from DBA_HIST_SNAPSHOT;

-- find my session
SELECT SID, SERIAL#, OSUSER, USERNAME, MACHINE, PROCESS 
FROM V$SESSION WHERE audsid = userenv('SESSIONID');

-- Version
@version

-- Invalids
column owner format a15
column object_name format a32
column Object_TYPE format a20

select name from v$database;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate, count(*) from dba_objects where status != 'VALID';                    
Select owner, object_name,Object_TYPE  from dba_objects where status != 'VALID';

-- do we have dictionary statistics
select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows from dba_tables where owner='SYS' and table_name like '%$' order by last_analyzed desc; 
select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows from dba_tables where owner='SYS' and table_name = 'SYN$';
-- SYS	SYN$	2015/12/28 11:31:44	76954
select count(*) from SYS.SYN$;

-- do we have fixed objects statistics
select OWNER, TABLE_NAME, LAST_ANALYZED from dba_tab_statistics where table_name='X$KGLDP'; 
--OWNER	TABLE_NAME	LAST_ANALYZED
--SYS	X$KGLDP	2015/09/04 19:37:58
select * from sys.aux_stats$; 


-- Largest objects in DB
select owner, segment_name, segment_type, round(bytes/1024/1024/1024) SIZE_GB from dba_segments order by 4 desc;

-- Where is the app tier If I can access DB
select * from FND_NODES;
select machine, count(*) from v$session group by machine order by 2 desc;

-- PSU, but has to be run as SYS
select ACTION,VERSION,ID,COMMENTS,BUNDLE_SERIES from registry$history;

select * from v$log;
select * from v$logfile;
select BYTES/1024/1024 AS SIZE_MB from v$log; 

select group#,thread#,status from v$log;

SELECT C_LOG.ROWID FROM FND_LOGINS C_LOG WHERE C_LOG.SPID = :B1;

select table_name, last_analyzed, sample_size, num_rows, blocks from dba_tables where num_rows is not null order by num_rows desc;

alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from APPS.FND_LOG_MESSAGES order by timestamp desc;

select * from dba_jobs;
select * from dba_jobs where job in (34048429, 34049915, 34048427, 34048405);

select /*+ RULE */ sid,job from dba_jobs_running;
select /*+ RULE */ * from dba_jobs_running;

select * from dba_jobs order by total_time desc;
select JOB,broken, schema_user from dba_jobs where schema_user='ECOMEX';


select * from dba_jobs where what like '%dbms_refresh%XX_%';
select job,interval, what from dba_jobs where what like '%dbms_refresh%XX_%';


select * from all_mviews where mview_name='XX_PO_LINE_LOCATIONS_ALL_MV';

select * from all_mviews where mview_name like 'XX_%_MV';

select * from all_mviews where staleness = 'NEEDS_COMPILE';

select count(*) from XX_PO_LINE_LOCATIONS_ALL_MV;

select count(*) from "PO"."PO_LINE_LOCATIONS_ALL";


-- Size of the objects
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'PO_LINE_LOCATIONS_ALL';
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'FND_LOGINS';
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'FND_UNSUCCESSFUL_LOGINS';
select * from v$datafile_header;

-- initrans, pctfree
select * from dba_tables;
select owner, table_name, pct_free, ini_trans, max_trans, last_analyzed from dba_tables where ini_trans is not null order by ini_trans desc;
select owner, index_name, table_name, pct_free, ini_trans, max_trans, last_analyzed from dba_indexes where ini_trans is not null order by ini_trans desc;

-- bind variables
SELECT name,      position ,      datatype_string ,      was_captured,      value_string  
FROM   v$sql_bind_capture  WHERE  sql_id = '9y3atws32v91s';

--FND_LOGIN
select count(*) from FND_LOGIN_RESP_FORMS;
select count(*) from FND_LOGIN_RESPONSIBILITIES;
select count(*) from FND_LOGINS;
select count(*) from FND_UNSUCCESSFUL_LOGINS;

-- AWR create snap
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

-- AWR retention time
select dbid from v$database;
select * from dba_hist_wr_control;


-- Finding OS PID from session with status KILLED
select p.spid from v$process p, v$session s 
where p.addr = s.paddr and s.status = 'KILLED';

-- snapper
@tpt/snapper ash 15 1 all
@tpt/snapper ash 15 1 1189
@tpt/snapper stats 5 1 1189
@tpt/sqlid gnm9yr4rp7pad

-- latches and mutex general
select * from v$latch where name ='cache buffers chains';
select name, gets, wait_time from v$latch order by wait_time desc;
select * from v$mutex_sleep order by sleeps desc;

select * from v$mutex_sleep_history order by sleep_timestamp desc;

set linesize 200
set verify off
@tpt/latchprof name % % 20000
@tpt/latchprof name,sid,sqlid % % 10000
@tpt/latchprof sid,name % "cache buffers chains" 100
@tpt/latchprof sid,name % "KWQS pqueue ctx latch" 200
@tpt/latchprof name,sqlid % "cache buffers chains" 100


-- general
@longops
@active4
@users

-- tmp
-- cool, different angels
@/tpt/snapper ash=sid+event+wait_class,ash1=plsql_object_id+plsql_subprogram_id+sql_id,ash2=program+module+action 5 1 all

-- shows which session is blocking us
@tpt/snapper ash=sql_id+event+wait_class+blocking_session+p2+p3 5 1 all

set linesize 200
@tpt/a
??@tpt/snapper ash,gather=n 5 1 32
@tpt/snapper ash 15 1 all
??@tpt/sqlid g17jcjd9wm84b

@tpt/sqlid 1hd24sg3bjhjh

@tpt/sqlt g17jcjd9wm84b

@tpt/snapper ash,stats,gather=s 30 1 

@tpt/snapper ash=event+wait_class,stats,gather=ts,tinclude=CPU,sinclude=parse 5 1 all


@tpt/snapper ash=sql_id+event+wait_class+blocking_session+p2+p3 5 1 1275
@tpt/sqlt apq1zzdn99xv2
select * from v$sql where sql_id = '2rda1m6x0jjbt';

@tpt/snapper ash 15 1 1587
---------------------------------------------------------------------------------------------------------------
  ActSes   %Thread | INST | SQL_ID          | SQL_CHILD | EVENT                               | WAIT_CLASS     
---------------------------------------------------------------------------------------------------------------
    1.00    (100%) |    2 | apq1zzdn99xv2   | 0         | ON CPU                              | ON CPU         
 
@tpt/snapper stats 5 1 1587
 
select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name=upper('inv_total_tax_null');
select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name in ('MTL_SERIAL_NUMBERS_INTERFACE','RCV_SERIALS_INTERFACE','RCV_SERIAL_TRANSACTIONS');
-- MTL_SERIAL_NUMBERS_INTERFACE	2016/01/22 03:42:27	71044	142088	3022
select count(*) from APPS.MTL_SERIAL_NUMBERS_INTERFACE;
-- 143109

select owner, table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where owner like 'ZX%' and sample_size is null;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";

show parameter undo
set linesize 200
@tbs


@tpt/snapper ash 15 1 1393
@tpt/snapper stats 5 1 1393


@tpt/snapper ash 15 1 50
@tpt/sqlt f3g2hz7dpfy1t
select * from v$sql where sql_id = 'f3g2hz7dpfy1t';

-- Monitoring space
@tbs
-- UNDOTS01  UNDOTS02 UNDOTS03
-- 1. To check the current size of the Undo tablespace:
select sum(a.bytes) as undo_size from v$datafile a, v$tablespace b, dba_tablespaces c where c.contents = 'UNDO' and c.status = 'ONLINE' and b.name = c.tablespace_name and a.ts# = b.ts#;

-- 2. To check the free space (unallocated) space within Undo tablespace:
select tablespace_name, round(sum(bytes)/1024/1024/1024) "GB" from dba_free_space where tablespace_name in ('UNDOTS01','UNDOTS02','UNDOTS03') group by tablespace_name order by tablespace_name;

-- 3.To Check the space available within the allocated Undo tablespace:
select tablespace_name , round(sum(blocks)*8/(1024)/1024)  reusable_space_GB from dba_undo_extents where status='EXPIRED'  group by  tablespace_name order by tablespace_name;
select tablespace_name , sum(blocks)  reusable_blocks from dba_undo_extents where status='EXPIRED'  group by  tablespace_name order by tablespace_name;
/*
14:18
UNDOTS01	1389616
UNDOTS02	133168
UNDOTS03	790216


*/

-- 4. To Check the space allocated in the Undo tablespace:
select tablespace_name , round(sum(blocks)*8/(1024)/1024)  space_in_use_GB from dba_undo_extents where status IN ('ACTIVE','UNEXPIRED') group by  tablespace_name order by tablespace_name;
select tablespace_name , round(sum(blocks)*8/(1024)/1024)  space_in_use_GB from dba_undo_extents where status IN ('ACTIVE') group by  tablespace_name order by tablespace_name;
select tablespace_name , round(sum(blocks)*8/(1024)/1024)  space_in_use_GB from dba_undo_extents where status IN ('UNEXPIRED') group by  tablespace_name order by tablespace_name;
/*
3 14:24
TABLESPACE_NAME	SPACE_IN_USE_GB
UNDOTS01	8
UNDOTS02	91
UNDOTS03	21
*/


show parameter optim
select flashback_on from v$database;
select oldest_flashback_scn,oldest_flashback_time from v$flashback_database_log;


-- undo stats combo
SELECT A.TABLESPACE_NAME,round(SUM(A.TOTS)/1024/1024/1024) "Tot size GB",
 round(SUM(A.SUMB)/1024/1024/1024) "Tot Free GB",
 round(SUM(A.SUMB)*100/SUM(A.TOTS)) "%FREE",
 100-round(SUM(A.SUMB)*100/SUM(A.TOTS)) "%USED",
 round(SUM(A.LARGEST)/1024/1024/1024) MAX_FREE_GB,SUM(A.CHUNKS) CHUNKS_FREE
 FROM (
 SELECT TABLESPACE_NAME,0 TOTS,SUM(BYTES) SUMB,
 MAX(BYTES) LARGEST,COUNT(*) CHUNKS
 FROM SYS.DBA_FREE_SPACE A
 GROUP BY TABLESPACE_NAME
 UNION
 SELECT TABLESPACE_NAME,SUM(BYTES) TOTS,0,0,0
 FROM SYS.DBA_DATA_FILES
 GROUP BY TABLESPACE_NAME) A, V$INSTANCE B
 where A.TABLESPACE_NAME in ('UNDOTS01','UNDOTS02','UNDOTS03')
 GROUP BY UPPER(B.INSTANCE_NAME),A.TABLESPACE_NAME
 order by 1
/

show parameter undo
show parameter cpu

/*
##############################################################
                temporary tablespace stats
##############################################################
How Can Temporary Segment Usage Be Monitored Over Time? [ID 364417.1]
NOTE:1069041.6 - How to Find Creator of a SORT or TEMPORARY SEGMENT or Users Performing Sorts
NOTE:317441.1 - How Do You Find Who And What SQL Is Using Temp Segments
How Can Temporary Segment Usage Be Monitored Over Time? (Doc ID 364417.1)
*/

-- http://download.oracle.com/docs/cd/B19306_01/server.102/b14237/dynviews_2161.htm
-- V$TEMP_SPACE_HEADER shows total free bytes (allocated but available for reuse are not shown here)
-- this can show nothing is free, but that means only that it was once allocated and probably can be used again now - see below queries for more accurate info
select * from V$TEMP_SPACE_HEADER order by blocks_used desc;
select TABLESPACE_NAME, round(BYTES_USED/1024/1024) MB_USED, round(BYTES_FREE/1024/1024) MB_FREE from V$TEMP_SPACE_HEADER;
select file#, name, round(bytes/(1024*1024),2) "SIZE IN MB's" from v$tempfile;
select TABLESPACE_NAME, FILE_NAME, BYTES, AUTOEXTENSIBLE, MAXBYTES from dba_temp_files order by TABLESPACE_NAME;


-- http://download.oracle.com/docs/cd/B28359_01/server.111/b28320/statviews_5056.htm
-- DBA_TEMP_FREE_SPACE shows bytes which are free and also which are allocated but are available for reuse
-- This is what is really free
SELECT * FROM dba_temp_free_space;

-- percantage used, 0 means all is free, this is correct value
select round((s.tot_used_blocks/f.total_blocks)*100) as "percent used"
from (select sum(used_blocks) tot_used_blocks from v$sort_segment where tablespace_name='TEMPX') s, 
(select sum(blocks) total_blocks from dba_temp_files where tablespace_name='TEMPX') f;

-- who is using temp
SELECT a.username, a.sid, a.serial#, a.osuser, b.tablespace, b.blocks, c.sql_text
FROM v$session a, v$tempseg_usage b, v$sqlarea c
WHERE a.saddr = b.session_addr
AND c.address= a.sql_address
AND c.hash_value = a.sql_hash_value
ORDER BY b.blocks desc;


/*
##############################################################
-- recently recompiled packages
##############################################################
*/
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from dba_objects;
select * from dba_objects where last_ddl_time is not null order by last_ddl_time desc;
select owner, object_name,object_type, last_ddl_time from dba_objects where last_ddl_time is not null order by last_ddl_time desc;

/*
##############################################################
-- shared pool monitoring
##############################################################
*/

select * from v$sgainfo;
select * from V$LIBRARY_CACHE_MEMORY ;
select pool, name, round(bytes/(1024 * 1024)) size_mb from v$sgastat where pool='shared pool' and bytes > (1024 * 1024) order by size_mb desc;

-- SHARED_POOL_SIZE is too small if REQUEST_FAILURES is greater than zero and increasing.
select * from V$SHARED_POOL_RESERVED;

/*
##############################################################
-- Result cache
##############################################################
*/
-- Troubleshooting Performance Issues when Result Cache is Full (Doc ID 2143739.1)
-- Statistics for Cached Results
https://docs.oracle.com/cd/E11882_01/server.112/e41573/memory.htm#BGBEEIHB
select * from V$RESULT_CACHE_OBJECTS;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from V$RESULT_CACHE_OBJECTS order by creation_timestamp desc;
SELECT name, value FROM V$RESULT_CACHE_STATISTICS;
select * from v$parameter where name like '%result_cache%';
select * from v$sql where SQL_TEXT like '%result_cache%' order by last_load_time desc;
EXECUTE DBMS_RESULT_CACHE.MEMORY_REPORT;
-- Show the largest objects occupying RC (running that locks the RC for short time)
select namespace, status, name,
count(*) number_of_results,
round(avg(scan_count)) avg_scan_cnt,
round(max(scan_count)) max_scan_cnt,
round(sum(block_count)) tot_blk_cnt
from v$result_cache_objects
where type = 'Result'
group by namespace, name, status
--order by namespace, tot_blk_cnt;
order by number_of_results desc;




/*
##############################################################
-- other
##############################################################
*/

-- IO stats
select * from V$IOSTAT_FUNCTION;

-- network stats
select * from V$IOSTAT_NETWORK;

-- ADOP status
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from ad_adop_sessions order by apply_start_date desc;
select * from ad_adop_session_patches order by end_date desc;



--TEMP

SELECT object_name, object_type FROM dba_objects a WHERE STATUS = 'INVALID' AND a.object_name NOT IN ( 'GEMS_EU_CM_BY_MOD_CENTER_V' ,'GEMS_EU_PL_REP_COMP_V','GEMS_EU_PL_REP_LITEMS_COMP_V','GEMS_EU_SER_BY_MS_CENTER_V', 'GEMSEU_REMIT_ADV_OPT') AND a.object_name NOT IN ('GEMS_FAD_GL_BALANCES_EUROPE_V','GEMS_SL_REDIST_AX_AR_FIX_TEMP','FIND_ORDERS','GEMS_IIP_OP_RECAST_PKG','GEMS_IIP_DC_BACKLOG_PKG','GEMS_IIP_CSS_ORDER_IMPORT_PKG') AND a.owner IN ('GEMS_FIN');

alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name='MTL_PARAMETERS';
select count(*) from MTL_PARAMETERS;

select count(*) from FND_LOGINS;
select trunc(start_time, 'YEAR'), count(*) from FND_LOGINS group by trunc(start_time, 'YEAR');

select * from fnd_nodes;
select machine, count(*) from v$session group by machine order by 2 desc;

alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate, executions from V$SQLSTATS where sql_id = '49aq3qw2ffskh';


-- Growth trend
/*
https://docs.oracle.com/cd/B28359_01/server.111/b28320/statviews_4029.htm
http://remigium.blogspot.com/2014/04/calculating-segment-growth-in-oracle.html
*/

select NAME,RTIME,TABLESPACE_SIZE/1024/1024,TABLESPACE_MAXSIZE/1024/1024,TABLESPACE_USEDSIZE/1024/1024 
from dba_hist_tbspc_space_usage,v$tablespace where TABLESPACE_ID=TS# order by 1,2;

select * from DBA_HIST_SEG_STAT;
select A.SPACE_ALLOCATED_TOTAL, A.SPACE_ALLOCATED_DELTA from DBA_HIST_SEG_STAT a;
select snap_id from DBA_HIST_SEG_STAT a where A.OBJ#='9846' order by snap_id ;


SELECT
    TO_CHAR(creation_time, 'RRRR-MM') month
  , SUM(bytes)/1024/1024/1024                        growth_GB
FROM     sys.v_$datafile
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');

SELECT name,
    TO_CHAR(creation_time, 'RRRR-MM') month
  , SUM(bytes)/1024/1024/1024                        growth
FROM     sys.v_$datafile
GROUP BY TO_CHAR(creation_time, 'RRRR-MM')
ORDER BY TO_CHAR(creation_time, 'RRRR-MM');

select * from sys.v_$datafile;

select a.TABLESPACE_NAME,
     a.BYTES bytes_used,
     b.BYTES bytes_free,
     b.largest,
     round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used
     from
     (select TABLESPACE_NAME,
     sum(BYTES) BYTES
     from dba_data_files
     group by TABLESPACE_NAME)
     a,
     (select TABLESPACE_NAME,
     sum(BYTES) BYTES ,
     max(BYTES) largest
     from dba_free_space
     group by TABLESPACE_NAME)
     b
     where a.TABLESPACE_NAME=b.TABLESPACE_NAME
     order by ((a.BYTES-b.BYTES)/a.BYTES) desc;


select sum(space_used_delta) / 1024 / 1024 “Space used (M)”, sum(c.bytes) / 1024 / 1024 “Total Schema Size (M)”,
round(sum(space_used_delta) / sum(c.bytes) * 100, 2) || ‘%’ “Percent of Total Disk Usage”
from
dba_hist_snapshot sn,
dba_hist_seg_stat a,
dba_objects b,
dba_segments c
see code depot for full script
where end_interval_time > trunc(sysdate) – &days_back
and sn.snap_id = a.snap_id
and b.object_id = a.obj#
and b.owner = c.owner
and b.object_name = c.segment_name
and c.owner = ‘&schema_name’
and space_used_delta > 0;
title “Total Disk Used by Object Type”
select c.segment_type, sum(space_used_delta) / 1024 / 1024 “Space used (M)”, sum(c.bytes) / 1024 / 1024 “Total Space (M)”,
round(sum(space_used_delta) / sum(c.bytes) * 100, 2) || ‘%’ “Percent of Total Disk Usage”
from
dba_hist_snapshot sn,
dba_hist_seg_stat a,
dba_objects b,
dba_segments c
see code depot for full script
where end_interval_time > trunc(sysdate) – &days_back
and sn.snap_id = a.snap_id
and b.object_id = a.obj#
and b.owner = c.owner
and b.object_name = c.segment_name
and space_used_delta > 0
--and c.owner = ‘&schema_name’
group by rollup(segment_type);


select to_char(creation_time, 'MM-RRRR') "Month",
sum(bytes)/1024/1024 "Growth in Meg"
from sys.v_$datafile
group by to_char(creation_time, 'MM-RRRR');

-- figure out snap timestamps
select * from dba_tables where table_name like 'DBA_HIST%';
select min(snap_id), max(snap_id) from DBA_HIST_SEG_STAT a where A.OBJ#='9846'  ;
select * from dba_hist_snapshot where instance_number = 1 order by begin_interval_time desc;

select beg.dataobj#, fin.SPACE_ALLOCATED_TOTAL - beg.SPACE_ALLOCATED_TOTAL delta
from (select * from DBA_HIST_SEG_STAT where snap_id = 59507) beg, (select * from DBA_HIST_SEG_STAT where snap_id = 60750) fin
where beg.dataobj# = fin.dataobj#
order by delta desc
;

select * from dba_objects;
select * from dba_objects where object_id=9740;

-- figure out object name
select obj.owner, obj.object_name, beg.dataobj#, fin.SPACE_ALLOCATED_TOTAL - beg.SPACE_ALLOCATED_TOTAL delta
from (select * from DBA_HIST_SEG_STAT where snap_id = 59507) beg, 
(select * from DBA_HIST_SEG_STAT where snap_id = 60750) fin,
DBA_OBJECTS obj
where beg.dataobj# = fin.dataobj#
and obj.object_id = beg.obj#
order by delta desc
;

select table_owner,table_name,inserts,updates,deletes from dba_tab_modifications where table_owner IN ('A','B','C') order by inserts,updates,deletes; 

select * from dba_free_space ;
select tablespace_name, round(sum(bytes)/1024/1024 ,2) as free_space
       from dba_free_space
       group by tablespace_name
       order by tablespace_name ;
       
       
-- check how many SQLs reuse the plan, how many are hard parsed for no subsequent use which suggests literals usage
select * from v$sql;
select executions, count(*) from v$sql group by executions order by 2 desc;
select count(*) from v$sql;
select executions from v$sql order by executions desc;
select executions,sql_text from v$sql order by executions desc;
-- what is new and probably hard-parsed
select * from v$sql order by last_load_time desc;
select sql_id, plan_hash_value, executions, module, action, last_load_time, sql_text  from v$sql order by last_load_time desc;
select count(*) from v$sql where PLAN_HASH_VALUE = 1108335062;



-- preparing a query to automatically purge the
select count(*) from v$sqlarea where executions = 1;
select count(*) from v$sql where executions = 1;
select address, hash_value, executions, loads, version_count, invalidations, parse_calls, sql_text from v$sqlarea where executions = 1 and sql_text not like '%dbms_shared_pool.purge%';
select address, hash_value from v$sqlarea where executions = 1;

-- checking how many temporary tables 'LCMT_*' are in shared pool
select * from v$sql where sql_text like '%LCMT_%';


       
/* ########################################################
   parallel execution
   ########################################################
Nice links:   
https://docs.oracle.com/cd/E18283_01/server.112/e16541/parallel006.htm   
http://searchitchannel.techtarget.com/feature/Parallel-processing-Using-parallel-SQL-effectively
*/
-- check if query was is running in parallel
SELECT QCSID, SID, INST_ID "Inst", SERVER_GROUP "Group", SERVER_SET "Set",
  DEGREE "Degree", REQ_DEGREE "Req Degree"
FROM GV$PX_SESSION ORDER BY QCSID, QCINST_ID, SERVER_GROUP, SERVER_SET;

SELECT NAME, VALUE FROM GV$SYSSTAT
WHERE UPPER (NAME) LIKE '%PARALLEL OPERATIONS%'
OR UPPER (NAME) LIKE '%PARALLELIZED%' OR UPPER (NAME) LIKE '%PX%' order by value desc;

select sql_id, sql_text, px_servers_requested, px_servers_allocated
from v$sql_monitor where px_servers_requested is not null;

-- although it looks promising, it does not explain why I still see the parallel stats rising
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$sql_monitor where px_servers_requested is not null order by sql_exec_start desc;

select * from v$sql_monitor;
select * from v$sql_monitor order by sql_exec_start desc;

show parameter parallel
show parameter adaptive
show parameter dynamic
show parameter result
select * from V$SYSSTAT where name like '%parallel%';
select * from V$SYSSTAT where name like '%parallel%';
select * from V$MYSTAT;
SELECT * FROM V$PX_PROCESS;

-- check degree set on table
select * from dba_tables;
select * from dba_tables where degree not in ('         1');

-- check if shared server is used
select server, count(*) from v$session group by server;
select * from v$session where server = 'SHARED';
select * from v$session;
select username, count(*) from v$session group by username;
select machine, count(*) from v$session group by machine order by 2 desc;
select program, count(*) from v$session group by program order by 2 desc;
select status, count(*) from v$session where program ='JDBC Thin Client' group by status order by 2 desc ;
select min(first_connect), count(*) from icx.icx_sessions;


-- show hidden parameter value
select a.ksppinm  "Parameter", b.ksppstvl "Session Vale", c.ksppstvl "Instance Value"
  from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
   and substr(ksppinm,1,1)='_'
order by a.ksppinm;

select a.ksppinm  "Parameter", b.ksppstvl "Session Vale", c.ksppstvl "Instance Value"
  from sys.x$ksppi a, sys.x$ksppcv b, sys.x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
   and ksppinm in ('_result_cache_global','_optimizer_reduce_groupby_key')
order by a.ksppinm;


-- ASH
select * from V$ACTIVE_SESSION_HISTORY;
select * from V$ACTIVE_SESSION_HISTORY where session_id=4943 order by sample_time desc;
select sample_time, sql_id, sql_plan_operation, session_state, event from V$ACTIVE_SESSION_HISTORY 
where session_id=2722 order by sample_time desc;

-- scheduler jobs
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
SELECT * FROM DBA_SCHEDULER_JOBS;
SELECT * FROM DBA_SCHEDULER_JOB_RUN_DETAILS order by actual_start_date desc;
SELECT * FROM dba_jobs_running;
SELECT * FROM dba_scheduler_running_jobs;

select client_name, status
from dba_autotask_client
where client_name = 'auto space advisor';

/* ########################################################
                  TMP
   ######################################################## */

XXDNVGL.XXDNVGL_PA_PRJ_TASKS_STG_TBL

@o XXDNVGL_PA_PRJ_TASKS_STG_TBL

select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows from dba_tables where table_name in ('XXDNVGL_PA_PRJ_TASKS_STG_TBL','PA_TASKS') order by last_analyzed desc;    
-- OWNER	TABLE_NAME	LAST_ANALYZED	NUM_ROWS
-- XXDNVGL	XXDNVGL_PA_PRJ_TASKS_STG_TBL	2017-03-06 06:09:10	35058
select count(*) from XXDNVGL.XXDNVGL_PA_PRJ_TASKS_STG_TBL;
-- 21736


select result_cache, count(*) from dba_tables group by result_cache;
select * from V$RESULT_CACHE_OBJECTS;
select sysdate, value from v$parameter where name = 'db_name';
   
-- redo
select * from v$log;
select * from v$standby_log;
select * from v$logfile;
alter database add logfile group 4 ('/u01/data/REMIK/redo04a.log') size 100M;
alter database drop logfile group 2;
alter database add standby logfile group 10 '/u01/data/REMIK/stb_redo05.log' size 100M;

alter database drop logfile group 10;

alter database drop standby logfile group 4;

select * from dba_tablespaces;
select * from dba_data_files;
select * from dba_segments where tablespace_name = 'REMI';


-- are there any bitmap indexes?
select * from dba_indexes where 
owner not in ('SYS','SYSTEM','OUTLN','WMSYS','DBSNMP','EXFSYS','CTXSYS','XDB','ORDSYS','ORDDATA','MDSYS','OLAPSYS','SYSMAN','FLOWS_FILES','APEX_030200');
select * from dba_indexes where index_type = 'BITMAP';


alter tablespace REMI read only;

alter database datafile '/u01/data/REMIK/remi01.dbf' autoextend on maxsize 6G;

@tbs
@tbsa

--what Nagios is monitoring
select sum(blocks), sum(maxblocks), round(sum(blocks)*100/sum(maxblocks)) rate from dba_data_files 
where tablespace_name = 'REMI' group by tablespace_name;

--what Nagios is monitoring, taking under account
select tablespace_name, round(sum(blocks*8192/1024/1024)) UsedMB, round(sum(maxblocks*8192/1024/1024)) MaxMB, round(sum(blocks)*100/sum(maxblocks)) rate from dba_data_files 
group by tablespace_name order by rate;

select * from dba_tablespaces;

alter tablespace REMI read write;


select * from dba_data_files;
select file_name, tablespace_name, blocks*8192/1024/1024 blocksMB, round(maxblocks*8192/1024/1024) maxblocksMB, round(increment_by*8192/1024/1024) incrementMB from dba_data_files;

-- how many queries are run every minute
select /*+ FULL(a) parallel(a,8) */ trunc(enq_time, 'YEAR') year, count(*) from WF_QUEUE_TEMP_EVT_TABLE a 
group by trunc(enq_time, 'YEAR') order by trunc(enq_time, 'YEAR') desc;

select count(sql_id) from v$active_session_history 
where sql_exec_start > to_date('2018-04-26:12:35:19','YYYY-MM-DD:HH24:MI:SS') 
and sql_exec_start < to_date('2018-04-26:13:36:21','YYYY-MM-DD:HH24:MI:SS');

select * from v$active_session_history;
select count(*) from v$active_session_history;

alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select trunc(sql_exec_start, 'MI'),count(*) from v$active_session_history group by trunc(sql_exec_start, 'MI') order by trunc(sql_exec_start, 'MI') desc;





