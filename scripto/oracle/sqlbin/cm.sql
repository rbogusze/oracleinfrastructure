set echo off
set linesize 130
set serveroutput on size 50000
set feed off
set veri off
DECLARE
running_count NUMBER := 0;
pending_count NUMBER := 0;
crm_pend_count NUMBER := 0;
--get the list of all conc managers and max worker and running workers
CURSOR conc_que IS
SELECT concurrent_queue_id,
concurrent_queue_name,
user_concurrent_queue_name,
max_processes,
running_processes
FROM apps.fnd_concurrent_queues_vl
WHERE enabled_flag='Y' and
concurrent_queue_name not like 'XDP%' and
concurrent_queue_name not like 'IEU%' and
concurrent_queue_name not in ('ARTAXMGR','PASMGR') ;
BEGIN
DBMS_OUTPUT.PUT_LINE('====================================================================================================');
DBMS_OUTPUT.PUT_LINE('QueueID'||' '||'Queue          '||
'Concurrent Queue Name                '||' '||'MAX '||' '||'RUN '||' '||
'Running '||' '||'Pending   '||' '||'In CRM');
DBMS_OUTPUT.PUT_LINE('====================================================================================================');
FOR i IN conc_que
LOOP
--for each manager get the number of pending and running requests in each queue
SELECT /*+ RULE */ nvl(sum(decode(phase_code, 'R', 1, 0)), 0),
nvl(sum(decode(phase_code, 'P', 1, 0)), 0)
INTO running_count, pending_count
FROM fnd_concurrent_worker_requests
WHERE
requested_start_date <= sysdate
and concurrent_queue_id = i.concurrent_queue_id
AND hold_flag != 'Y';
--for each manager get the list of requests pending due to conflicts in each manager
SELECT /*+ RULE */ count(1)
INTO crm_pend_count
FROM apps.fnd_concurrent_worker_requests a
WHERE concurrent_queue_id = 4
AND hold_flag != 'Y'
AND requested_start_date <= sysdate
AND exists (
SELECT 'x'
FROM apps.fnd_concurrent_worker_requests b
WHERE a.request_id=b.request_id
and concurrent_queue_id = i.concurrent_queue_id
AND hold_flag != 'Y'
AND requested_start_date <= sysdate);
--print the output by joining the outputs of manager counts,
DBMS_OUTPUT.PUT_LINE(
rpad(i.concurrent_queue_id,8,'_')||
rpad(i.concurrent_queue_name,15, ' ')||
rpad(i.user_concurrent_queue_name,40,' ')||
rpad(i.max_processes,6,' ')||
rpad(i.running_processes,6,' ')||
rpad(running_count,10,' ')||
rpad(pending_count,10,' ')||
rpad(crm_pend_count,10,' '));
--DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------------------------------');
END LOOP;
DBMS_OUTPUT.PUT_LINE('====================================================================================================');
END;
/
set verify on
set echo on

