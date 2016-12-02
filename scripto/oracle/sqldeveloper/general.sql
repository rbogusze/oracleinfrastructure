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
select * from v$sql where SQL_TEXT like '%result_cache%' order by last_load_time desc;

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
   and ksppinm in ('_optimizer_aggr_groupby_elim','_optimizer_reduce_groupby_key')
order by a.ksppinm;



/* ########################################################
                  TMP
   ######################################################## */



   
-- AWR retention time
select dbid from v$database;
select * from dba_hist_wr_control;
   
-- tmp
select * from DBA_SCHEDULER_JOBS;
show parameter recovery
select * from v$sql where sql_id ='6ghzns6q0vj5j';
@o XXDNVGL_ZX_TAX_RATES
show parameter recycle
show parameter optimizer_adaptive_features
show parameter _optimizer_autostats_job
SELECT a.ksppinm "Parameter",
       b.ksppstvl "Session Value",
       c.ksppstvl "Instance Value",
       decode(bitand(a.ksppiflg/256,1),1,'TRUE','FALSE') IS_SESSION_MODIFIABLE, 
       decode(bitand(a.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') IS_SYSTEM_MODIFIABLE
FROM   sys.x$ksppi a,
       sys.x$ksppcv b,
       sys.x$ksppsv c
WHERE  a.indx = b.indx
AND    a.indx = c.indx
AND    a.ksppinm LIKE '/_%' escape '/'
;

select  * from    apps.ad_bugs where   bug_number = 23703137;

show parameter nls

select value from NLS_DATABASE_PARAMETERS where parameter='NLS_CHARACTERSET';
select * from NLS_SESSION_PARAMETERS;
select * from NLS_INSTANCE_PARAMETERS;

select username from dba_users;

select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows, sample_size from dba_tables where owner='HXT';
select count(*) from HXC.HXC_RETRIEVAL_RANGE_BLKS;

@o pa_online_projects_v

APPS            PA_ONLINE_TASKS_V              VIEW     
APPS            PA_ONLINE_PROJECTS_V           VIEW   

show parameter shared


select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows, sample_size from dba_tables where table_name  = upper('gl_code_combinations') or table_name = upper('gl_temporary_combinations');
select count(*) from GL.GL_TEMPORARY_COMBINATIONS;

APPS.XXDNVGL_YEAR_WEEK

SELECT v$access.sid, v$session.serial#
FROM v$session,v$access
WHERE v$access.sid = v$session.sid and v$access.object = 'FND_CP_FNDSM'
GROUP BY v$access.sid, v$session.serial#;


21087115
select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows from dba_tables where table_name = 'GL_JE_HEADERS';

select * from APPS.GL_JE_HEADERS;
select * from APPS.GL_JE_HEADERS AS OF TIMESTAMP to_timestamp('19-10-16 05:47:00','DD-MM-YY HH24:MI:SS');

select * from APPS.GL_JE_HEADERS AS OF TIMESTAMP to_timestamp('19-10-16 04:11:18','DD-MM-YY HH24:MI:SS') WHERE JE_HEADER_ID=4255866;  

select * from APPS.GL_JE_HEADERS AS OF TIMESTAMP to_timestamp('19-10-16 01:00:00','DD-MM-YY HH24:MI:SS') WHERE JE_HEADER_ID=4255866;  

select a.*
from APPS.GL_JE_HEADERS AS OF TIMESTAMP to_timestamp('20-10-16 01:00:00','DD-MM-YY HH24:MI:SS') a
where a.JE_HEADER_ID=427031;

select a.*
from APPS.GL_IMPORT_REFERENCES AS OF TIMESTAMP to_timestamp('20-10-16 04:06:00','DD-MM-YY HH24:MI:SS') a
where a.JE_HEADER_ID=4274031;

select a.*
from APPS.GL_JE_BATCHES AS OF TIMESTAMP to_timestamp('20-10-16 07:00:00','DD-MM-YY HH24:MI:SS') a
where a.JE_BATCH_ID=228639;

select a.*
from APPS.GL_LEDGERS AS OF TIMESTAMP to_timestamp('15-10-16 01:00:00','DD-MM-YY HH24:MI:SS') a
where a.ledger_id=2022;

select 
a.*
from apps.GL_PERIODS AS OF TIMESTAMP to_timestamp('20-10-16 01:00:00','DD-MM-YY HH24:MI:SS') a
where a.period_set_name='DNVGL'
and a.PERIOD_NAME='OCT-16';

select	
	TO_CHAR(SQ_GL_JE_HDR.JE_BATCH_ID)||'~'||TO_CHAR(SQ_GL_JE_HDR.JE_HEADER_ID)||'~'||TO_CHAR(SQ_GL_JE_HDR.JE_LINE_NUM)||'~'||TO_CHAR(SQ_GL_JE_HDR.GL_SL_LINK_ID)||'~'||SQ_GL_JE_HDR.GL_SL_LINK_TABLE	   C13_INTEGRATION_ID,
	SQ_GL_JE_HDR.BATCH_NAME	   C1_BATCH_NAME,
	SQ_GL_JE_HDR.HEADER_NAME	   C2_HEADER_NAME,
	SQ_GL_JE_HDR.STATUS	   C3_STATUS,
	SQ_GL_JE_HDR.JE_HEADER_ID	   C4_JE_HEADER_ID,
	SQ_GL_JE_HDR.JE_LINE_NUM	   C5_JE_LINE_NUM,
	SQ_GL_JE_HDR.JE_SOURCE	   C6_JE_SOURCE,
	SQ_GL_JE_HDR.JE_CATEGORY	   C7_JE_CATEGORY,
	SQ_GL_JE_HDR.GL_SL_LINK_ID	   C8_GL_SL_LINK_ID,
	SQ_GL_JE_HDR.GL_SL_LINK_TABLE	   C9_GL_SL_LINK_TABLE,
	SQ_GL_JE_HDR.LEDGER_ID	   C10_GL_LEDGER_ID,
	SQ_GL_JE_HDR.LEDGER_CATEGORY_CODE	   C11_GL_LEDGER_CATEGORY_CODE,
	SQ_GL_JE_HDR.END_DATE	   C12_GL_PER_END_DT,
	SQ_GL_JE_HDR.LAST_UPDATE_DATE	   C14_LAST_UPDATE_DATE
from	
( /* Subselect from SDE_ORA_PersistedStage_GLLinkageInformation_GLExtract.W_ORA_GL_LINKAGE_GL_JRNL_PS_SQ_GL_JE_HDR
*/
select 
	   T.LEDGER_ID LEDGER_ID,
	T.LEDGER_CATEGORY_CODE LEDGER_CATEGORY_CODE,
	PER.END_DATE END_DATE,
	GLIMPREF.JE_LINE_NUM JE_LINE_NUM,
	GLIMPREF.JE_HEADER_ID JE_HEADER_ID,
	GLIMPREF.GL_SL_LINK_TABLE GL_SL_LINK_TABLE,
	GLIMPREF.GL_SL_LINK_ID GL_SL_LINK_ID,
	JHEADER.NAME HEADER_NAME,
	JHEADER.STATUS STATUS,
	JBATCH.NAME BATCH_NAME,
	JHEADER.JE_SOURCE JE_SOURCE,
	JHEADER.JE_CATEGORY JE_CATEGORY,
	JHEADER.LAST_UPDATE_DATE LAST_UPDATE_DATE,
	JBATCH.JE_BATCH_ID JE_BATCH_ID
from	APPS.GL_JE_BATCHES AS OF TIMESTAMP to_timestamp('24-10-16 05:15:33','DD-MM-YY HH24:MI:SS')   JBATCH,
APPS.GL_JE_HEADERS AS OF TIMESTAMP to_timestamp('24-10-16 05:15:33','DD-MM-YY HH24:MI:SS')   JHEADER,
APPS.GL_IMPORT_REFERENCES AS OF TIMESTAMP to_timestamp('24-10-16 05:15:33','DD-MM-YY HH24:MI:SS')   GLIMPREF,
APPS.GL_LEDGERS AS OF TIMESTAMP to_timestamp('24-10-16 05:15:33','DD-MM-YY HH24:MI:SS')   T, 
APPS.GL_PERIODS AS OF TIMESTAMP to_timestamp('24-10-16 05:15:33','DD-MM-YY HH24:MI:SS')   PER 
where	(1=1)
 And (JHEADER.LEDGER_ID=T.LEDGER_ID)
AND (JHEADER.JE_HEADER_ID=GLIMPREF.JE_HEADER_ID)
AND (JBATCH.JE_BATCH_ID=JHEADER.JE_BATCH_ID)
AND (T.PERIOD_SET_NAME=PER.PERIOD_SET_NAME)
AND (JHEADER.PERIOD_NAME=PER.PERIOD_NAME)
And (('NULL' IN ('2022,2061,2070,2072,2074,2076,2094,2096,2098,2120,2146,2248')
       OR ( 'NULL' NOT IN ('2022,2061,2070,2072,2074,2076,2094,2096,2098,2120,2146,2248')
           AND T.LEDGER_ID IN (2022,2061,2070,2072,2074,2076,2094,2096,2098,2120,2146,2248)
          )
)
AND
('__NONE__'  IN ('PRIMARY','SECONDARY','ALC_TRANSACTION','ALC_BALANCE','ALC','NONE')
       OR (   '__NONE__' NOT IN ('PRIMARY','SECONDARY','ALC_TRANSACTION','ALC_BALANCE','ALC','NONE')
           AND T.LEDGER_CATEGORY_CODE IN ('PRIMARY','SECONDARY','ALC_TRANSACTION','ALC_BALANCE','ALC','NONE')
          )
))
 And (GLIMPREF.GL_SL_LINK_ID IS NOT NULL)
 And (
 JHEADER.LAST_UPDATE_DATE>=TO_DATE(SUBSTR('2016-10-17 04:00:01',0,19),'YYYY-MM-DD HH24:MI:SS')
)
)   SQ_GL_JE_HDR
where	(1=1)
--and TO_CHAR(SQ_GL_JE_HDR.JE_HEADER_ID) = '4303929'
and TO_CHAR(SQ_GL_JE_HDR.JE_BATCH_ID)='232246'
--||'~'||TO_CHAR(SQ_GL_JE_HDR.JE_HEADER_ID)||'~'||TO_CHAR(SQ_GL_JE_HDR.JE_LINE_NUM)||'~'||TO_CHAR(SQ_GL_JE_HDR.GL_SL_LINK_ID)||'~'||SQ_GL_JE_HDR.GL_SL_LINK_TABLE in 
--('228639~4274031~4~15284079~XLAJEL'
--'228639~4274031~3~15284081~XLAJEL',
--'228639~4274031~1~15284082~XLAJEL',
--'228639~4274031~2~15284080~XLAJEL')
;

SELECT *
FROM apps.GL_IMPORT_REFERENCES AS OF TIMESTAMP to_timestamp('2016-10-25 04:05:00','YYYY-MM-DD HH24:MI:SS')
WHERE JE_HEADER_ID = 4306280
  AND je_line_num = 39; 
  
select 'OLD',
a.integration_id,
substr(a.integration_id, 1, instr(a.integration_id, '~', 1)-1) batch_id,
a.batch_name,
a.header_name, 
a.je_header_id,
to_number(a.je_line_num), 
a.GL_LEDGER_ID,
a.GL_PER_END_DT,
a.je_source,
a.je_category,
a.LAST_UPDATE_DATE
from PROD_DW.I$_834591661_2 AS OF TIMESTAMP to_timestamp('2016-10-25 13:02:35','YYYY-MM-DD HH24:MI:SS') a
--from BCKP_20161020_GL_LINK_PS_OK a
where 1=1
AND a.JE_HEADER_ID in 4324594
order by 1 desc, 7 
;


desc APPS.GL_LEDGERS

select * from APPS.GL_LEDGERS order by LAST_UPDATE_DATE desc;

@tbs

-- why reftest slow
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
select OWNER, TABLE_NAME, LAST_ANALYZED, num_rows from dba_tables where table_name in ('PA_TASKS','PA_TASK_TYPES','PA_PROJ_ELEMENT_VERSIONS','PA_PROJ_ELEMENTS','PA_PROJECT_STATUSES','PA_PROJ_ELEM_VER_STRUCTURE','PA_PROJECTS_ALL','PA_PROJECT_TYPES_ALL','PA_PROJ_ELEM_VER_SCHEDULE') order by table_name;
/*
OWNER	TABLE_NAME	LAST_ANALYZED	NUM_ROWS
PA	PA_TASK_TYPES	2016-10-31 02	1
PA	PA_PROJ_ELEM_VER_SCHEDULE	2016-10-31 02	0
PA	PA_PROJ_ELEM_VER_STRUCTURE	2016-10-31 02	29770
PA	PA_PROJ_ELEMENTS	2016-10-31 02	182430
PA	PA_PROJ_ELEMENT_VERSIONS	2016-10-31 02	183315
PA	PA_PROJECT_TYPES_ALL	2016-10-31 02	746
PA	PA_PROJECT_STATUSES	2016-10-31 02	74
PA	PA_TASKS	2016-10-31 02	153168
PA	PA_PROJECTS_ALL	2016-10-31 02	29685
*/

select BUG_ID, BUG_NUMBER, LAST_UPDATE_DATE from APPLSYS.AD_BUGS where BUG_NUMBER = '21845816';

alter session set NLS_DATE_FORMAT = "YYYY-MM-DD HH24:MI:SS";
select OWNER, TABLE_NAME, LAST_ANALYZED, sample_size, num_rows from dba_tables where table_name in ('PA_AGREEMENTS_ALL','GL_LEDGERS','PA_CUST_EVENT_RDL_ALL','PA_DRAFT_REVENUES_ALL','PA_EVENTS','PA_PROJECTS_ALL') order by table_name;
select OWNER, TABLE_NAME, LAST_ANALYZED, sample_size, num_rows from dba_tables where last_analyzed is not null order by last_analyzed desc;
select count(*) from dba_tables where trunc(last_analyzed) = trunc(sysdate);
select count(*) from dba_tables;
select count(*) from dba_tables where table_name like 'XLA_GLT_%';
select TABLE_NAME, STATS_UPDATE_TIME from dba_tab_stats_history where table_name ='PA_AGREEMENTS_ALL' order by STATS_UPDATE_TIME desc;

@i PA_DRAFT_REVENUES_ALL
select OWNER, index_name, TABLE_NAME, LAST_ANALYZED, sample_size, num_rows from dba_indexes where table_name in ('PA_AGREEMENTS_ALL','GL_LEDGERS','PA_CUST_EVENT_RDL_ALL','PA_DRAFT_REVENUES_ALL','PA_EVENTS','PA_PROJECTS_ALL') order by table_name, index_name;

-- histograms
select table_name,column_name,num_buckets from dba_tab_columns where table_name in ('PA_AGREEMENTS_ALL','GL_LEDGERS','PA_CUST_EVENT_RDL_ALL','PA_DRAFT_REVENUES_ALL','PA_EVENTS','PA_PROJECTS_ALL') order by table_name;
select num_buckets, count(*) from dba_tab_columns where table_name in ('PA_AGREEMENTS_ALL','GL_LEDGERS','PA_CUST_EVENT_RDL_ALL','PA_DRAFT_REVENUES_ALL','PA_EVENTS','PA_PROJECTS_ALL') group by num_buckets ;
select table_name,column_name,num_buckets from dba_tab_columns where table_name in ('GL_LEDGERS') order by 3 desc;

select count(*) from apps.FND_HISTOGRAM_COLS;
select count(*) from apps.FND_HISTOGRAM_COLS where table_name in ('PA_AGREEMENTS_ALL','GL_LEDGERS','PA_CUST_EVENT_RDL_ALL','PA_DRAFT_REVENUES_ALL','PA_EVENTS','PA_PROJECTS_ALL');

SELECT fa.application_id           "Application ID",
       fat.application_name        "Application Name",
       fa.application_short_name   "Application Short Name",
       fa.basepath                 "Basepath"
  FROM fnd_application     fa,
       fnd_application_tl  fat
 WHERE fa.application_id = fat.application_id
   AND fat.language      = USERENV('LANG')
   -- AND fat.application_name = 'Payables'  -- <change it>
 ORDER BY fat.application_name;
 
 
select * from apps.ap_invoice_lines_all where invoice_id = 969815 and line_number = 1;

select do.object_name,sid,s.serial#,s.osuser,
row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#, --s.session_id,
dbms_rowid.rowid_create ( 1, ROW_WAIT_OBJ#, ROW_WAIT_FILE#, ROW_WAIT_BLOCK#, ROW_WAIT_ROW# )
from v$session s, dba_objects do
where s.ROW_WAIT_OBJ# = do.OBJECT_ID 
and object_name like '%AP_INVOICE%';




