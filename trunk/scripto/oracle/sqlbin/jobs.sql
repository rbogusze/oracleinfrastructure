prompt Show some info about the jobs
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
column what format a40
column LOG_USER format a10
set lines 200
set pagesize 100
select JOB, LOG_USER, WHAT, LAST_DATE, NEXT_DATE, BROKEN from dba_jobs 
order by LAST_DATE;
