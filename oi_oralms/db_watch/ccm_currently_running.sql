set linesize 200
column ARGUMENT_TEXT format a30
column USER_CONCURRENT_PROGRAM_NAME format a30
column USER_NAME format a15
SELECT DISTINCT c.USER_CONCURRENT_PROGRAM_NAME,round(((sysdate-a.actual_start_date)*24*60*60/60),2) AS Process_time,
a.request_id,a.parent_request_id,a.request_date,a.actual_start_date, d.user_name, a.phase_code,a.status_code,a.argument_text,a.priority
FROM   apps.fnd_concurrent_requests a,apps.fnd_concurrent_programs b,apps.FND_CONCURRENT_PROGRAMS_TL c,apps.fnd_user d
WHERE  a.concurrent_program_id=b.concurrent_program_id AND b.concurrent_program_id=c.concurrent_program_id AND
a.requested_by=d.user_id AND status_code='R' order by Process_time desc;
