-- How many redo is generated daily
alter session set nls_date_format = 'YYYY-MM-DD';
select trunc(COMPLETION_TIME),round(sum(blocks*block_size)/1024/1024/1024) SIZE_GB
from (select distinct first_change#,first_time,blocks,block_size,completion_time
from v$archived_log) 
group by trunc(COMPLETION_TIME) 
order by trunc(COMPLETION_TIME) desc; 
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$archived_log order by completion_time desc;

-- Archivelog size each hour GB
alter session set nls_date_format = 'YYYY-MM-DD HH24';
select trunc(COMPLETION_TIME,'HH24') TIME, round(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024) SIZE_GB from V$ARCHIVED_LOG group by trunc (COMPLETION_TIME,'HH24') order by 1 desc;

-- Archivelog size each hour MB
alter session set nls_date_format = 'YYYY-MM-DD HH24';
select trunc(COMPLETION_TIME,'HH24') TIME, round(SUM(BLOCKS * BLOCK_SIZE)/1024/1024) SIZE_MB from V$ARCHIVED_LOG group by trunc (COMPLETION_TIME,'HH24') order by 1 desc;

-- How many redo switches are in each hour
alter session set nls_date_format = 'YYYY-MM-DD HH24';
select trunc(first_time,'HH24'), count(*) from V$ARCHIVED_LOG group by trunc(first_time,'HH24') order by 1 desc;

-- Archive log generated in the last week
select round(sum(blocks*block_size)/1024/1024/1024) SIZE_GB
from (select distinct first_change#,first_time,blocks,block_size,completion_time
from v$archived_log where completion_time > sysdate -1); 

-- Who is responsible for the most changes (based on AWR reports)
-- NOTE :- Please change the timing as per the Awr report timings. 
SELECT dhso.object_name, object_type, SUM (db_block_changes_delta) 
FROM dba_hist_seg_stat dhss, dba_hist_seg_stat_obj dhso, dba_hist_snapshot 
dhs 
WHERE dhs.snap_id = dhss.snap_id 
AND dhs.instance_number = dhss.instance_number 
AND dhss.obj# = dhso.obj# 
AND dhss.dataobj# = dhso.dataobj# 
AND begin_interval_time BETWEEN TO_DATE ('12-12-2016 00:00:00', 'DD-MM-YYYY 
HH24:mi:ss') AND TO_DATE ('13-12-2016 23:59:59', 'DD-MM-YYYY HH24:mi:ss') 
GROUP BY dhso.object_name, object_type 
HAVING SUM (db_block_changes_delta) > 0 
ORDER BY 2, SUM (db_block_changes_delta) DESC; 

-- NOW monitor Top sessions consuming most of the redo : 
select b.inst_id, b.SID,b.sql_id, b.serial# sid_serial, b.username, machine, 
b.osuser, b.status, a.redo_mb 
from (select n.inst_id, sid, round(value/1024/1024) redo_mb from gv$statname 
n, gv$sesstat s 
where n.inst_id=s.inst_id and n.statistic#=134 and s.statistic# = 
n.statistic# order by value desc) a, gv$session b 
where b.inst_id=a.inst_id 
and a.sid = b.sid 
and rownum <= 10; 
select sql_text from v$sql where sql_id in('');


 
-- tmp 
select * from v$archived_log;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$log order by first_time;
select * from v$logfile;
select group#,thread#,sequence#,bytes,archived,status from v$log;
select BYTES/1024/1024 AS SIZE_MB from v$log; 