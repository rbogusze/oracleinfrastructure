set linesize 200
set pagesize 50
column ARGUMENT_TEXT format a30
column USER_CONCURRENT_PROGRAM_NAME format a52
column USER_NAME format a18
column DURATION format 999999
column REQ_ID format 9999999
column P_REQ_ID format 9999999
column ARGUMENT_TEXT format a30
column PRIO format 99
alter session set NLS_DATE_FORMAT = "HH24:MI:SS";
SELECT DISTINCT c.USER_CONCURRENT_PROGRAM_NAME,round(((sysdate-a.actual_start_date)*24*60*60/60)) AS duration,
a.request_id as REQ_ID,a.parent_request_id as P_REQ_ID,a.request_date,a.actual_start_date, d.user_name, a.phase_code,a.status_code,substr(a.argument_text,1,30) as ARGUMENT_TEXT,a.priority as PRIO
FROM   apps.fnd_concurrent_requests a,apps.fnd_concurrent_programs b,apps.FND_CONCURRENT_PROGRAMS_TL c,apps.fnd_user d
WHERE  a.concurrent_program_id=b.concurrent_program_id AND b.concurrent_program_id=c.concurrent_program_id AND
a.requested_by=d.user_id AND status_code='R' order by duration desc;
