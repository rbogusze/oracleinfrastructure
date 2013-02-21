prompt Show some info about the jobs
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
column what format a40
set lines 100
set pagesize 100
select JOB, WHAT, LAST_DATE, NEXT_DATE, BROKEN from dba_jobs 
order by LAST_DATE;
