alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from APPLSYS.AD_BUGS;
select * from dual;

-- find my session
SELECT SID, SERIAL#, OSUSER, USERNAME, MACHINE, PROCESS FROM V$SESSION WHERE audsid = userenv('SESSIONID');

-- Version
@version

-- Invalids
column owner format a15
column object_name format a32
column Object_TYPE format a20

select name from v$database;
select count(*) from dba_objects where status != 'VALID';                    
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
FROM   v$sql_bind_capture  WHERE  sql_id = '8t7gxquf6h1hw';

--FND_LOGIN
select count(*) from FND_LOGIN_RESP_FORMS;
select count(*) from FND_LOGIN_RESPONSIBILITIES;
select count(*) from FND_LOGINS;
select count(*) from FND_UNSUCCESSFUL_LOGINS;

-- AWR create snap
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;


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
select * from v$sql where sql_id = 'apq1zzdn99xv2';

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


@tpt/snapper ash 15 1 9245
@tpt/snapper stats 5 1 714


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
select * from V$TEMP_SPACE_HEADER;
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
ORDER BY b.tablespace, b.blocks;


/*
##############################################################
-- recently recompiled packages
##############################################################
*/
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from dba_objects;
select * from dba_objects where last_ddl_time is not null order by last_ddl_time desc;

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

-- Result cache
Statistics for Cached Results
https://docs.oracle.com/cd/E11882_01/server.112/e41573/memory.htm#BGBEEIHB
select * FROM V$RESULT_CACHE_OBJECTS;
select * from v$parameter where name like '%result_cache%';

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

select * from DBA_HIST_SEG_STAT;
select A.SPACE_ALLOCATED_TOTAL, A.SPACE_ALLOCATED_DELTA from DBA_HIST_SEG_STAT a;
select snap_id from DBA_HIST_SEG_STAT a where A.OBJ#='9846' order by snap_id ;

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

-- preparing a query to automatically purge the
select count(*) from v$sqlarea where executions = 1;
select count(*) from v$sql where executions = 1;
select address, hash_value, executions, loads, version_count, invalidations, parse_calls, sql_text from v$sqlarea where executions = 1 and sql_text not like '%dbms_shared_pool.purge%';
select address, hash_value from v$sqlarea where executions = 1;


       
-- check if query was is running in parallel
SELECT QCSID, SID, INST_ID "Inst", SERVER_GROUP "Group", SERVER_SET "Set",
  DEGREE "Degree", REQ_DEGREE "Req Degree"
FROM GV$PX_SESSION ORDER BY QCSID, QCINST_ID, SERVER_GROUP, SERVER_SET;

show parameter parallel
show parameter resour
select * from V$SYSSTAT where name like '%parallel%';
select * from V$MYSTAT;

   
-- AWR retention time
select dbid from v$database;
select * from dba_hist_wr_control;
   
-- tmp
select * from DBA_SCHEDULER_JOBS;
show parameter recovery


       
