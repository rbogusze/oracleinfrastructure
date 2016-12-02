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


 
-- tmp 
select * from v$archived_log;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$log order by first_time;
select * from v$logfile;
select group#,thread#,sequence#,bytes,archived,status from v$log;
select BYTES/1024/1024 AS SIZE_MB from v$log; 