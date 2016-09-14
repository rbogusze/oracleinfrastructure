-- Basic info
select name from v$database;
select * from v$version;
select COMMENTS from  registry$history where COMMENTS like 'PSU%';
select release_name from apps.fnd_product_groups;
select patch_level from apps.fnd_product_installations where patch_level like '%AD%';
select patch_level from apps.fnd_product_installations where patch_level like '%ATG%';
select patch_level from apps.fnd_product_installations where patch_level like '%FND%';

-- bugs
select BUG_ID, BUG_NUMBER, LAST_UPDATE_DATE from APPLSYS.AD_BUGS where BUG_NUMBER = '&p';

-- connect SID to request id, Vijay
select fcr.oracle_session_id, fcr.request_id,fcr.PARENT_REQUEST_ID from apps.fnd_concurrent_requests fcr where fcr.oracle_session_id 
in (select s.audsid from gv$session s where s.sid='&Sid');


alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select request_id, phase_code, status_code, ARGUMENT_TEXT, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE  from apps.fnd_concurrent_requests 
where request_id in ('4216335');


-- combo: check what is request doing
select distinct ses.SID, stx.sql_id, ses.sql_hash_value, ses.USERNAME, pro.SPID "OS PID", stx.sql_text from 
     V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
where ses.paddr = pro.addr
and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and ses.sid in (select d.sid
    from apps.fnd_concurrent_requests a,
    apps.fnd_concurrent_processes b,
    v$process c,
    v$session d
    where a.controlling_manager = b.concurrent_process_id
    and c.pid = b.oracle_process_id
    and b.session_id=d.audsid
    and a.request_id in ('4216335')
    --and a.phase_code = 'R'
)
order by ses.sid
;


-- Vijay connect request with SID
select r.request_id req_id,r.concurrent_program_id,r.parent_request_id,fu.user_name ,
       r.phase_code p,
       r.status_code s,
       (select node_name || ':'
          from applsys.fnd_concurrent_processes cp
         where concurrent_process_id = r.controlling_manager) ||
       r.os_process_id cp_process,
       gi.INSTANCE_NAME || ':' || ss.sid || ',' || ss.serial# inst_sid_serial#,
       gi.HOST_NAME || ':' || pp.spid db_process,
       ss.program,
       ss.status,
   ss.last_call_et,ROUND( ( NVL( r.actual_completion_date, sysdate ) - r.actual_start_date ) * 24*60, 2 ) "duration in min",
       ss.sql_id || ':' || ss.sql_child_number sql_id_chld,
       ss.event,
       ss.WAIT_TIME,
       ss.STATE
  from applsys.fnd_concurrent_requests  r,
       gv$session                       ss,
       gv$process                       pp,
       gv$instance                      gi,
       applsys.fnd_concurrent_processes cp,
       applsys.fnd_user fu
where request_id = &request_id
-- request_id = 667741450
--concurrent_program_id = 667741450
--and status_code = 'R'
   and ss.audsid(+) = r.oracle_session_id
   and pp.inst_id(+) = ss.inst_id
   and pp.addr(+) = ss.paddr
   and fu.user_id=r.requested_by
   and gi.inst_id(+) = ss.inst_id
   and cp.concurrent_process_id(+) = r.controlling_manager
;

/*
If you see something like this:
REQ_ID	CONCURRENT_PROGRAM_ID	PARENT_REQUEST_ID	USER_NAME	P	S	CP_PROCESS	INST_SID_SERIAL#	DB_PROCESS	PROGRAM	STATUS	LAST_CALL_ET	duration in min	SQL_ID_CHLD	EVENT	WAIT_TIME	STATE
672071839	            1025546	        672071822	502060547	R	R	28406	      :,	:				                                                5766.8	:			

Which sugests that request is still running, but does not provide where - Instance and SID are null check the diagnostics for that request

The reason could be:
This request did not finish processing due to an unrecoverable error, and the concurrent manager that was running this request is no longer active.
The Internal Concurrent Manager will mark this request as having completed with an error. Please refer to the concurrent manager or the Internal Concurrent Manager log files for the cause of the error.

*/

-- check request diagnostics
select * from FND_CONCURRENT_REQUESTS where request_id = 672071839;


dba_triggers and check status <> ENABLED for CLL 

select * from dba_triggers where status <> 'ENABLED';

select count(1) from dba_triggers where table_owner='CLL' and status='DISABLED';

select count(1) from dba_triggers where table_owner='CLL' and status='ENABLED';




--- #####################

--- that is fastes t!!!
check scripto/oracle/sqlbin/cm.sql
@cm
@cm1
@cm2




-- connect Request ID with DB SID    
select a.request_id, d.sid, d.serial# , c.spid
    from apps.fnd_concurrent_requests a,
    apps.fnd_concurrent_processes b,
    gv$process c,
    gv$session d
    where a.controlling_manager = b.concurrent_process_id
    and c.pid = b.oracle_process_id
    and b.session_id=d.audsid
    and a.request_id = &request_id
    and a.phase_code = 'R';

select * from gv$process;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";

-- connect Request ID with DB SID
select a.request_id, c.spid, d.sid, d.serial#, c.inst_id from apps.fnd_concurrent_requests a, apps.fnd_concurrent_processes b, gv$process c, gv$session d
where a.controlling_manager = b.concurrent_process_id
and c.pid = b.oracle_process_id
and b.session_id=d.audsid
and a.request_id = 3994487;


--	CCMs Currently Running 
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
SELECT DISTINCT c.USER_CONCURRENT_PROGRAM_NAME,round(((sysdate-a.actual_start_date)*24*60*60/60)) AS Process_time,
a.request_id,a.parent_request_id,a.request_date,a.actual_start_date,a.actual_completion_date,(a.actual_completion_date-a.request_date)*24*60*60 AS end_to_end,
(a.actual_start_date-a.request_date)*24*60*60 AS lag_time,d.user_name, a.phase_code,a.status_code,a.argument_text,a.priority
FROM   apps.fnd_concurrent_requests a,apps.fnd_concurrent_programs b,apps.FND_CONCURRENT_PROGRAMS_TL c,apps.fnd_user d
WHERE  a.concurrent_program_id=b.concurrent_program_id AND b.concurrent_program_id=c.concurrent_program_id AND
a.requested_by=d.user_id AND status_code='R' order by Process_time desc;



-- Administer CM view
steps currently following by AA team for alternate of Admin concurrent form.
1)	Front end navigation : OAM > site map > monitoring tab > Internal Concurrent Manager
2)	Backend script: 
> @rac_mgr


-- Administer CM view
-- Uses custom XX_FND_CONCURRENT_WORKER_REQ view, see Troubleschooting / Fixing FND_CONCURRENT_WORKER_REQUESTS view
SELECT * FROM 
(
SELECT   /*+ FIRST_ROWS */
fcqt.user_concurrent_queue_name, fcq.concurrent_queue_name, 
        fcq.target_node, fcq.running_processes actual, fcq.max_processes target, 
         DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag) ENABLED,
         SUM (DECODE (fcwr.phase_code, 'R', 1, 0)) running,
           SUM (DECODE (fcwr.phase_code, 'P', 1, 0))
         - SUM (DECODE (fcwr.hold_flag, 'Y', 1, 0))
         - SUM (DECODE (SIGN (fcwr.requested_start_date - SYSDATE), 1, 1, 0)) pending,
         SUM (DECODE (fcwr.hold_flag, 'Y', 1, 0)) hold,
         SUM (DECODE (SIGN (fcwr.requested_start_date - SYSDATE), 1, 1, 0)) sched,
         NVL (paused_jobs.paused_count, 0) paused, fcq.sleep_seconds, 
 fcq.application_id, fcq.concurrent_queue_id
    FROM apps.ge_fnd_concurrent_worker_req fcwr,
         applsys.fnd_concurrent_queues fcq,
         applsys.fnd_concurrent_queues_tl fcqt,
         (SELECT   fcp.concurrent_queue_id, COUNT (*) paused_count
              FROM applsys.fnd_concurrent_requests fcr, applsys.fnd_concurrent_processes fcp
             WHERE fcr.phase_code = 'R'
               AND fcr.status_code = 'W'                             -- Paused
               AND fcr.controlling_manager = fcp.concurrent_process_id
          GROUP BY fcp.concurrent_queue_id) paused_jobs
   WHERE fcwr.queue_application_id(+) = fcq.application_id
     AND fcwr.concurrent_queue_id(+) = fcq.concurrent_queue_id
     AND fcq.concurrent_queue_id = paused_jobs.concurrent_queue_id(+)
     AND fcq.application_id = fcqt.application_id
     AND fcq.concurrent_queue_id = fcqt.concurrent_queue_id
     AND fcqt.LANGUAGE = USERENV ('LANG')
     AND fcq.running_processes > 0
GROUP BY fcq.concurrent_queue_name, fcqt.user_concurrent_queue_name, fcq.application_id,
         fcq.concurrent_queue_id, fcq.target_node, fcq.max_processes, fcq.running_processes,
         fcq.sleep_seconds, fcq.cache_size,
         DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag),
         paused_jobs.paused_count
ORDER BY DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag) DESC,
         DECODE (fcq.concurrent_queue_name,'FNDICM', 'AAA','STANDARD', 'AAB','Your name', 'AAC',fcq.concurrent_queue_name)
) ;
--WHERE user_concurrent_queue_name LIKE 'SFM%';

-- org FND_CONCURRENT_WORKER_REQUESTS
SELECT * FROM 
(
SELECT   /*+ FIRST_ROWS */
fcqt.user_concurrent_queue_name, fcq.concurrent_queue_name, 
        fcq.target_node, fcq.running_processes actual, fcq.max_processes target, 
         DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag) ENABLED,
         SUM (DECODE (fcwr.phase_code, 'R', 1, 0)) running,
           SUM (DECODE (fcwr.phase_code, 'P', 1, 0))
         - SUM (DECODE (fcwr.hold_flag, 'Y', 1, 0))
         - SUM (DECODE (SIGN (fcwr.requested_start_date - SYSDATE), 1, 1, 0)) pending,
         SUM (DECODE (fcwr.hold_flag, 'Y', 1, 0)) hold,
         SUM (DECODE (SIGN (fcwr.requested_start_date - SYSDATE), 1, 1, 0)) sched,
         NVL (paused_jobs.paused_count, 0) paused, fcq.sleep_seconds, 
 fcq.application_id, fcq.concurrent_queue_id
    FROM apps.fnd_concurrent_worker_requests fcwr,
         applsys.fnd_concurrent_queues fcq,
         applsys.fnd_concurrent_queues_tl fcqt,
         (SELECT   fcp.concurrent_queue_id, COUNT (*) paused_count
              FROM applsys.fnd_concurrent_requests fcr, applsys.fnd_concurrent_processes fcp
             WHERE fcr.phase_code = 'R'
               AND fcr.status_code = 'W'                             -- Paused
               AND fcr.controlling_manager = fcp.concurrent_process_id
          GROUP BY fcp.concurrent_queue_id) paused_jobs
   WHERE fcwr.queue_application_id(+) = fcq.application_id
     AND fcwr.concurrent_queue_id(+) = fcq.concurrent_queue_id
     AND fcq.concurrent_queue_id = paused_jobs.concurrent_queue_id(+)
     AND fcq.application_id = fcqt.application_id
     AND fcq.concurrent_queue_id = fcqt.concurrent_queue_id
     AND fcqt.LANGUAGE = USERENV ('LANG')
     AND fcq.running_processes > 0
GROUP BY fcq.concurrent_queue_name, fcqt.user_concurrent_queue_name, fcq.application_id,
         fcq.concurrent_queue_id, fcq.target_node, fcq.max_processes, fcq.running_processes,
         fcq.sleep_seconds, fcq.cache_size,
         DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag),
         paused_jobs.paused_count
ORDER BY DECODE (fcq.enabled_flag,'Y', 'Y','N', 'N',fcq.enabled_flag) DESC,
         DECODE (fcq.concurrent_queue_name,'FNDICM', 'AAA','STANDARD', 'AAB','Your name', 'AAC',fcq.concurrent_queue_name)
) ;



--- from Bob
--	CCM Child Requests Given Parent Request ID 
SELECT /*+ ORDERED USE_NL(x fcr fcp fcptl)*/
       fcr.request_id "Request ID",
       fcptl.user_concurrent_program_name"Program Name",
       fcr.phase_code,
       fcr.status_code,
--     to_char(fcr.request_date,'DD-MON-YYYY HH24:MI:SS') "Submitted",
--     (fcr.actual_start_date - fcr.request_date)*1440 "Delay",
       to_char(fcr.actual_start_date,'DD-MON-YYYY HH24:MI:SS') "Start Time",
       to_char(fcr.actual_completion_date, 'DD-MON-YYYY HH24:MI:SS') "End Time",
       (fcr.actual_completion_date - fcr.actual_start_date)*1440 "Elapsed",
       fcr.oracle_process_id "Trace ID"
  FROM (SELECT /*+ index (fcr1 fnd_concurrent_requests_n3) */
               fcr1.request_id
          FROM apps.fnd_concurrent_requests fcr1
         WHERE 1=1
         START WITH fcr1.request_id = &parent_request_id
       CONNECT BY PRIOR fcr1.request_id = fcr1.parent_request_id) x,
       apps.fnd_concurrent_requests fcr,
       apps.fnd_concurrent_programs fcp,
       apps.fnd_concurrent_programs_tl fcptl
WHERE fcr.request_id = x.request_id
   AND fcr.concurrent_program_id = fcp.concurrent_program_id
   AND fcr.program_application_id = fcp.application_id
   AND fcp.application_id = fcptl.application_id
   AND fcp.concurrent_program_id = fcptl.concurrent_program_id
   AND fcptl.language = 'US'
ORDER BY 1;


--	CCMs Currently Running 
SELECT DISTINCT c.USER_CONCURRENT_PROGRAM_NAME,round(((sysdate-a.actual_start_date)*24*60*60/60),2) AS Process_time,
a.request_id,a.parent_request_id,a.request_date,a.actual_start_date,a.actual_completion_date,(a.actual_completion_date-a.request_date)*24*60*60 AS end_to_end,
(a.actual_start_date-a.request_date)*24*60*60 AS lag_time,d.user_name, a.phase_code,a.status_code,a.argument_text,a.priority
FROM   apps.fnd_concurrent_requests a,apps.fnd_concurrent_programs b,apps.FND_CONCURRENT_PROGRAMS_TL c,apps.fnd_user d
WHERE  a.concurrent_program_id=b.concurrent_program_id AND b.concurrent_program_id=c.concurrent_program_id AND
a.requested_by=d.user_id AND status_code='R' order by Process_time desc;

--????	CCM Prvious Program Times 
select round((cast(to_char(min(a.actual_completion_date)-min(a.actual_start_date))        
as float))*24*60*60) as   
total_PROG_TIME,to_char(min(a.actual_start_date),'DD-MON-YYYY hh24:mi:ss') as actual_start_date , 
to_char(min(a.actual_completion_date),'DD-MON-YYYY hh24:mi:ss') as actual_completion_date,   
a.Concurrent_Program_Name   
from      
(Select fcr.request_id,fcr.actual_start_date as       
actual_start_date,      
fcr.actual_completion_date as       
actual_completion_date,  
wnd.confirm_date as confirm_date,  
to_char      
(wnd.confirm_date,'hh24:mi:ss'), (cast(to_char      
((fcr.actual_completion_date)-(fcr.actual_start_date)) as      
float))*24*60*60 as time_taken_by_printing_program,      
(cast(to_char((fcr.actual_start_date)-(wnd.confirm_date))        
as float))*24*60*60 as   
time_to_start_printing_program,fcr.printer,      
Wrs.Usage_Code,fcr.status_code as status_code,    
Wrs.Name Shipping_Document_Set,fcr.argument2 as       
delivery_id,      
Fcpt.User_Concurrent_Program_Name       
Concurrent_Program_Name,Fcpt.concurrent_program_id,      
wnd.name      
FROM APPS.WSH_REPORT_SETS WRS, APPS.WSH_REPORT_SET_LINES       
WRSL, APPS.FND_CONCURRENT_PROGRAMS_TL       
FCPT,inv.mtl_parameters imtl,      
apps.wsh_new_deliveries wnd, fnd_concurrent_requests fcr       
WHERE WRSL.REPORT_SET_ID = WRS.REPORT_SET_ID      
And Fcpt.Concurrent_Program_Id =       
Wrsl.Concurrent_Program_Id      
and wrs.name like 'R00 Shipping Set'      
and fcr.concurrent_program_id = fcpt.concurrent_program_id      
and fcr.argument2 = wnd.name      
and imtl.organization_id=fcr.argument1      
and imtl.organization_code = 'R00'     
and Fcpt.User_Concurrent_Program_Name NOT LIKE   
'%NOTIFICATION'    
order by fcr.argument2)a      
group by actual_start_date,a.concurrent_program_name;


--	CCM Run, Length of Time, Number of Times 
select
c.application_short_name,
b.concurrent_program_name,
b.user_concurrent_program_name,
count(*),
avg((a.actual_start_date-a.requested_start_date)*24*60*60) DELAY,
avg((a.actual_completion_date-a.actual_start_date)*24*60*60) AVGRUN,
avg((a.actual_completion_date-a.actual_start_date)*24*60*60) + 3*(stddev((a.actual_completion_date-a.actual_start_date)*24*60*60)) AVG3STDDEV,
max((a.actual_completion_date-a.actual_start_date)*24*60*60) MAXRUN
from apps.fnd_concurrent_requests a, apps.fnd_concurrent_programs_vl b, apps.fnd_application c
WHERE a.status_code = 'C'
and a.phase_code = 'C'
and a.concurrent_program_id = b.concurrent_program_id
and a.program_application_id = c.application_id
group by c.application_short_name, b.concurrent_program_name, b.user_concurrent_program_name
ORDER BY 7 ASC;


--	Concurrent Manager Programs With Trace Enabled 
select 'Trace Enabled' ||';'||  concurrent_program_name ||';' || substr(user_concurrent_program_name,1,30), last_update_date
from apps.fnd_Concurrent_programs_vl
where enable_trace = 'Y';

-- WIP
select * from apps.fnd_concurrent_requests;
--	CCM Request Details 
set echo off
set serveroutput on size 50000
set verify off
set feedback off
accept uxproc prompt 'Enter Unix process id: '
accept inst_id prompt 'Enter instance id: '
DECLARE
  v_sid number;
  vs_cnt number;
  s sys.gv_$session%ROWTYPE;
  p sys.gv_$process%ROWTYPE;
  cursor cur_c1 is select sid from sys.gv_$process p, sys.gv_$session s  where  p.addr  = s.paddr and  (p.spid =  &uxproc or s.process = '&uxproc') and s.inst_id='&inst_id' and p.inst_id=s.inst_id;
BEGIN
    dbms_output.put_line('=====================================================================');
        select nvl(count(sid),0) into vs_cnt from sys.gv_$process p, sys.gv_$session s  where  p.addr  = s.paddr and  (p.spid =  &uxproc or s.process = '&uxproc') and s.inst_id='&inst_id' and p.inst_id=s.inst_id;
        dbms_output.put_line(to_char(vs_cnt)||' sessions were found with '||'&uxproc'||' as their unix process id for the instance number '||'&inst_id');
         dbms_output.put_line('=====================================================================');
        open cur_c1;
        LOOP
      FETCH cur_c1 INTO v_sid;
            EXIT WHEN (cur_c1%NOTFOUND);
                select * into s from sys.gv_$session where sid  = v_sid and inst_id='&inst_id';
                select * into p from sys.gv_$process where addr = s.paddr and inst_id='&inst_id';
                dbms_output.put_line('SID/Serial  : '|| s.sid||','||s.serial#);
                dbms_output.put_line('Foreground  : '|| 'PID: '||s.process||' - '||s.program);
                dbms_output.put_line('Shadow      : '|| 'PID: '||p.spid||' - '||p.program);
                dbms_output.put_line('Terminal    : '|| s.terminal || '/ ' || p.terminal);
                dbms_output.put_line('OS User     : '|| s.osuser||' on '||s.machine);
                dbms_output.put_line('Ora User    : '|| s.username);
                dbms_output.put_line('Details     : '|| s.action||' - '||s.module);
                dbms_output.put_line('Status Flags: '|| s.status||' '||s.server||' '||s.type);
                dbms_output.put_line('Tran Active : '|| nvl(s.taddr, 'NONE'));
                dbms_output.put_line('Login Time  : '|| to_char(s.logon_time, 'Dy HH24:MI:SS'));
                dbms_output.put_line('Last Call   : '|| to_char(sysdate-(s.last_call_et/60/60/24), 'Dy HH24:MI:SS') || ' - ' || to_char(s.last_call_et/60, '9990.0') || ' min');
                dbms_output.put_line('Lock/ Latch : '|| nvl(s.lockwait, 'NONE')||'/ '||nvl(p.latchwait, 'NONE'));
                dbms_output.put_line('Latch Spin  : '|| nvl(p.latchspin, 'NONE'));
                                                                dbms_output.put_line('Current SQL_ID  : '|| s.sql_id);
                dbms_output.put_line('PreviousSQL_ID  : '|| s.prev_sql_id);
               dbms_output.put_line('Current SQL statement:');
                for c1 in ( select * from sys.gv_$sqltext  where HASH_VALUE = s.sql_hash_value and inst_id='&inst_id' order by piece)
                loop
                dbms_output.put_line(chr(9)||c1.sql_text);
                end loop;
                dbms_output.put_line('Previous SQL statement:');
                for c1 in ( select * from sys.gv_$sqltext  where HASH_VALUE = s.prev_hash_value and inst_id='&inst_id' order by piece)
                loop
                dbms_output.put_line(chr(9)||c1.sql_text);
                end loop;
                dbms_output.put_line('Session Waits:');
                for c1 in ( select * from sys.gv_$session_wait where sid = s.sid and inst_id='&inst_id')
                loop
        dbms_output.put_line(chr(9)||c1.state||': '||c1.event);
                end loop;
--  dbms_output.put_line('Connect Info:');
--  for c1 in ( select * from sys.gv_$session_connect_info where sid = s.sid and inst_id='&inst_id') loop
--    dbms_output.put_line(chr(9)||': '||c1.network_service_banner);
--  end loop;
                dbms_output.put_line('Locks:');
                for c1 in ( select  /*+ RULE */ decode(l.type,
          -- Long locks
                      'TM', 'DML/DATA ENQ',   'TX', 'TRANSAC ENQ',
                      'UL', 'PLS USR LOCK',
          -- Short locks
                      'BL', 'BUF HASH TBL',  'CF', 'CONTROL FILE',
                      'CI', 'CROSS INST F',  'DF', 'DATA FILE   ',
                      'CU', 'CURSOR BIND ',
                      'DL', 'DIRECT LOAD ',  'DM', 'MOUNT/STRTUP',
                      'DR', 'RECO LOCK   ',  'DX', 'DISTRIB TRAN',
                      'FS', 'FILE SET    ',  'IN', 'INSTANCE NUM',
                      'FI', 'SGA OPN FILE',
                      'IR', 'INSTCE RECVR',  'IS', 'GET STATE   ',
                      'IV', 'LIBCACHE INV',  'KK', 'LOG SW KICK ',
                      'LS', 'LOG SWITCH  ',
                      'MM', 'MOUNT DEF   ',  'MR', 'MEDIA RECVRY',
                      'PF', 'PWFILE ENQ  ',  'PR', 'PROCESS STRT',
                      'RT', 'REDO THREAD ',  'SC', 'SCN ENQ     ',
                      'RW', 'ROW WAIT    ',
                      'SM', 'SMON LOCK   ',  'SN', 'SEQNO INSTCE',
                      'SQ', 'SEQNO ENQ   ',  'ST', 'SPACE TRANSC',
                      'SV', 'SEQNO VALUE ',  'TA', 'GENERIC ENQ ',
                      'TD', 'DLL ENQ     ',  'TE', 'EXTEND SEG  ',
                      'TS', 'TEMP SEGMENT',  'TT', 'TEMP TABLE  ',
                      'UN', 'USER NAME   ',  'WL', 'WRITE REDO  ',
                      'TYPE='||l.type) type,
                                  decode(l.lmode, 0, 'NONE', 1, 'NULL', 2, 'RS', 3, 'RX',
                       4, 'S',    5, 'RSX',  6, 'X',
                       to_char(l.lmode) ) lmode,
                                   decode(l.request, 0, 'NONE', 1, 'NULL', 2, 'RS', 3, 'RX',
                         4, 'S', 5, 'RSX', 6, 'X',
                         to_char(l.request) ) lrequest,
                                        decode(l.type, 'MR', o.name,
                      'TD', o.name,
                      'TM', o.name,
                      'RW', 'FILE#='||substr(l.id1,1,3)||
                            ' BLOCK#='||substr(l.id1,4,5)||' ROW='||l.id2,
                      'TX', 'RS+SLOT#'||l.id1||' WRP#'||l.id2,
                      'WL', 'REDO LOG FILE#='||l.id1,
                      'RT', 'THREAD='||l.id1,
                      'TS', decode(l.id2, 0, 'ENQUEUE', 'NEW BLOCK ALLOCATION'),
                      'ID1='||l.id1||' ID2='||l.id2) objname
                                from  sys.gv_$lock l, sys.obj$ o
                                where sid   = s.sid
                                and inst_id='&inst_id'
                                        and l.id1 = o.obj#(+) )
                        loop
                        dbms_output.put_line(chr(9)||c1.type||' H: '||c1.lmode||' R: '||c1.lrequest||' - '||c1.objname);
                        end loop;
                        dbms_output.put_line('=====================================================================');
        END LOOP;
        dbms_output.put_line(to_char(vs_cnt)||' sessions were found with '||'&uxproc'||' as their unix process id for the instance number '||'&inst_id');
        dbms_output.put_line('Please scroll up to see details of all the sessions.');
        dbms_output.put_line('=====================================================================');
        close cur_c1;
exception
    when no_data_found then
      dbms_output.put_line('Unable to find process id &&uxproc for the instance number '||'&inst_id'||' !!!');
          dbms_output.put_line('=====================================================================');
      return;
    when others then
      dbms_output.put_line(sqlerrm);
      return;
END;
/
undef uxproc
set heading on
set verify on
set feedback on
set echo on


--	Find SID Based on CCM Request ID 
SELECT distinct d.inst_id, a.request_id, d.sid, d.serial# ,d.osuser,d.process,a.status_code,c.SPID
FROM apps.fnd_concurrent_requests a,
apps.fnd_concurrent_processes b,
gv$process c,
gv$session d
WHERE a.controlling_manager = b.concurrent_process_id
AND c.pid = b.oracle_process_id
AND b.session_id=d.audsid
AND a.phase_code = 'R';





--	Top Concurrent Request 
SELECT
   f.application_short_name app,
   SUBSTR(p.user_concurrent_program_name,1,55) description,
p.concurrent_program_name PROGRAM,
   r.priority,
   COUNT(*) cnt,
   SUM(actual_completion_date - actual_start_date) * 24 elapsed,
   AVG(actual_completion_date - actual_start_date) * 24 average,
   MAX(actual_completion_date - actual_start_date) * 24 MAX,
   MIN(actual_completion_date - actual_start_date) * 24 MIN,
   STDDEV(actual_completion_date - actual_start_date) * 24 STDDEV,
   STDDEV(actual_start_date - requested_start_date) * 24 wstddev,
   SUM(actual_start_date - requested_start_date) * 24 waited,
   AVG(actual_start_date - requested_start_date) * 24 avewait,
   c.request_class_name TYPE
FROM apps.fnd_concurrent_queues fcq,
     apps.fnd_concurrent_queue_content fcqc,
     apps.fnd_concurrent_request_class c,
     apps.fnd_application f,
     apps.fnd_concurrent_programs_vl p,
     apps.fnd_concurrent_requests r
WHERE r.program_application_id = p.application_id
   AND r.concurrent_program_id = p.concurrent_program_id
--AND r.status_code IN ('C','G','E','R')
  -- AND actual_completion_date BETWEEN sysdate-30  AND sysdate
   AND p.application_id = f.application_id
   AND r.program_application_id = f.application_id
   AND r.request_class_application_id = c.application_id(+)
   AND r.concurrent_request_class_id = c.request_class_id(+)
   AND r.request_class_application_id = fcqc.type_application_id(+)
   AND r.concurrent_request_class_id = fcqc.type_id(+)
   AND fcqc.queue_application_id = fcq.application_id(+)
   AND fcqc.concurrent_queue_id = fcq.concurrent_queue_id(+)
GROUP BY
   c.request_class_name,
   f.application_short_name,
   p.concurrent_program_name,
   p.user_concurrent_program_name,
   r.priority
ORDER BY 3;


--	Determine SPID to Find CCM Details and Run CCM_Request_Details 
1)        Get SPID of session below SQL
 
select s.inst_id,s.sid,
p.spid, s.sid, s.serial#, s.status, substr(s.osuser,1,15),substr(s.username,1,25), substr(s.module,1,30)
from gv$process p,
gv$session s
where p.addr=s.paddr
and p.inst_id = s.inst_id
and s.sid = &sid
and s.inst_id = &inst_id;
 
2)        Run unix_rac.sql , it prompts for SPID (Get from Step1) and instance details(1/2)

-- is not that the same as before?
 
set echo off
set serveroutput on size 50000
set verify off
set feedback off
accept uxproc prompt 'Enter Unix process id: '
accept inst_id prompt 'Enter instance id: '
DECLARE
  v_sid number;
  vs_cnt number;
  s sys.gv_$session%ROWTYPE;
  p sys.gv_$process%ROWTYPE;
  cursor cur_c1 is select sid from sys.gv_$process p, sys.gv_$session s  where  p.addr  = s.paddr and  (p.spid =  &uxproc or s.process = '&uxproc') and s.inst_id='&inst_id' and p.inst_id=s.inst_id;
BEGIN
    dbms_output.put_line('=====================================================================');
        select nvl(count(sid),0) into vs_cnt from sys.gv_$process p, sys.gv_$session s  where  p.addr  = s.paddr and  (p.spid =  &uxproc or s.process = '&uxproc') and s.inst_id='&inst_id' and p.inst_id=s.inst_id;
        dbms_output.put_line(to_char(vs_cnt)||' sessions were found with '||'&uxproc'||' as their unix process id for the instance number '||'&inst_id');
         dbms_output.put_line('=====================================================================');
        open cur_c1;
        LOOP
      FETCH cur_c1 INTO v_sid;
            EXIT WHEN (cur_c1%NOTFOUND);
                select * into s from sys.gv_$session where sid  = v_sid and inst_id='&inst_id';
                select * into p from sys.gv_$process where addr = s.paddr and inst_id='&inst_id';
                dbms_output.put_line('SID/Serial  : '|| s.sid||','||s.serial#);
                dbms_output.put_line('Foreground  : '|| 'PID: '||s.process||' - '||s.program);
                dbms_output.put_line('Shadow      : '|| 'PID: '||p.spid||' - '||p.program);
                dbms_output.put_line('Terminal    : '|| s.terminal || '/ ' || p.terminal);
                dbms_output.put_line('OS User     : '|| s.osuser||' on '||s.machine);
                dbms_output.put_line('Ora User    : '|| s.username);
                dbms_output.put_line('Details     : '|| s.action||' - '||s.module);
                dbms_output.put_line('Status Flags: '|| s.status||' '||s.server||' '||s.type);
                dbms_output.put_line('Tran Active : '|| nvl(s.taddr, 'NONE'));
                dbms_output.put_line('Login Time  : '|| to_char(s.logon_time, 'Dy HH24:MI:SS'));
                dbms_output.put_line('Last Call   : '|| to_char(sysdate-(s.last_call_et/60/60/24), 'Dy HH24:MI:SS') || ' - ' || to_char(s.last_call_et/60, '9990.0') || ' min');
                dbms_output.put_line('Lock/ Latch : '|| nvl(s.lockwait, 'NONE')||'/ '||nvl(p.latchwait, 'NONE'));
                dbms_output.put_line('Latch Spin  : '|| nvl(p.latchspin, 'NONE'));
                                                                dbms_output.put_line('Current SQL_ID  : '|| s.sql_id);
                dbms_output.put_line('PreviousSQL_ID  : '|| s.prev_sql_id);
                dbms_output.put_line('Current SQL statement:');
                for c1 in ( select * from sys.gv_$sqltext  where HASH_VALUE = s.sql_hash_value and inst_id='&inst_id' order by piece)
                loop
                dbms_output.put_line(chr(9)||c1.sql_text);
                end loop;
                dbms_output.put_line('Previous SQL statement:');
                for c1 in ( select * from sys.gv_$sqltext  where HASH_VALUE = s.prev_hash_value and inst_id='&inst_id' order by piece)
                loop
                dbms_output.put_line(chr(9)||c1.sql_text);
                end loop;
                dbms_output.put_line('Session Waits:');
                for c1 in ( select * from sys.gv_$session_wait where sid = s.sid and inst_id='&inst_id')
                loop
        dbms_output.put_line(chr(9)||c1.state||': '||c1.event);
                end loop;
--  dbms_output.put_line('Connect Info:');
--  for c1 in ( select * from sys.gv_$session_connect_info where sid = s.sid and inst_id='&inst_id') loop
--    dbms_output.put_line(chr(9)||': '||c1.network_service_banner);
--  end loop;
                dbms_output.put_line('Locks:');
                for c1 in ( select  /*+ RULE */ decode(l.type,
          -- Long locks
                      'TM', 'DML/DATA ENQ',   'TX', 'TRANSAC ENQ',
                      'UL', 'PLS USR LOCK',
          -- Short locks
                      'BL', 'BUF HASH TBL',  'CF', 'CONTROL FILE',
                      'CI', 'CROSS INST F',  'DF', 'DATA FILE   ',
                      'CU', 'CURSOR BIND ',
                      'DL', 'DIRECT LOAD ',  'DM', 'MOUNT/STRTUP',
                      'DR', 'RECO LOCK   ',  'DX', 'DISTRIB TRAN',
                      'FS', 'FILE SET    ',  'IN', 'INSTANCE NUM',
                      'FI', 'SGA OPN FILE',
                      'IR', 'INSTCE RECVR',  'IS', 'GET STATE   ',
                      'IV', 'LIBCACHE INV',  'KK', 'LOG SW KICK ',
                      'LS', 'LOG SWITCH  ',
                      'MM', 'MOUNT DEF   ',  'MR', 'MEDIA RECVRY',
                      'PF', 'PWFILE ENQ  ',  'PR', 'PROCESS STRT',
                      'RT', 'REDO THREAD ',  'SC', 'SCN ENQ     ',
                      'RW', 'ROW WAIT    ',
                      'SM', 'SMON LOCK   ',  'SN', 'SEQNO INSTCE',
                      'SQ', 'SEQNO ENQ   ',  'ST', 'SPACE TRANSC',
                      'SV', 'SEQNO VALUE ',  'TA', 'GENERIC ENQ ',
                      'TD', 'DLL ENQ     ',  'TE', 'EXTEND SEG  ',
                      'TS', 'TEMP SEGMENT',  'TT', 'TEMP TABLE  ',
                      'UN', 'USER NAME   ',  'WL', 'WRITE REDO  ',
                      'TYPE='||l.type) type,
                                  decode(l.lmode, 0, 'NONE', 1, 'NULL', 2, 'RS', 3, 'RX',
                       4, 'S',    5, 'RSX',  6, 'X',
                       to_char(l.lmode) ) lmode,
                                   decode(l.request, 0, 'NONE', 1, 'NULL', 2, 'RS', 3, 'RX',
                         4, 'S', 5, 'RSX', 6, 'X',
                         to_char(l.request) ) lrequest,
                                        decode(l.type, 'MR', o.name,
                      'TD', o.name,
                      'TM', o.name,
                      'RW', 'FILE#='||substr(l.id1,1,3)||
                            ' BLOCK#='||substr(l.id1,4,5)||' ROW='||l.id2,
                      'TX', 'RS+SLOT#'||l.id1||' WRP#'||l.id2,
                      'WL', 'REDO LOG FILE#='||l.id1,
                      'RT', 'THREAD='||l.id1,
                      'TS', decode(l.id2, 0, 'ENQUEUE', 'NEW BLOCK ALLOCATION'),
                      'ID1='||l.id1||' ID2='||l.id2) objname
                                from  sys.gv_$lock l, sys.obj$ o
                                where sid   = s.sid
                                and inst_id='&inst_id'
                                        and l.id1 = o.obj#(+) )
                        loop
                        dbms_output.put_line(chr(9)||c1.type||' H: '||c1.lmode||' R: '||c1.lrequest||' - '||c1.objname);
                        end loop;
                        dbms_output.put_line('=====================================================================');
        END LOOP;
        dbms_output.put_line(to_char(vs_cnt)||' sessions were found with '||'&uxproc'||' as their unix process id for the instance number '||'&inst_id');
        dbms_output.put_line('Please scroll up to see details of all the sessions.');
        dbms_output.put_line('=====================================================================');
        close cur_c1;
exception
    when no_data_found then
      dbms_output.put_line('Unable to find process id &&uxproc for the instance number '||'&inst_id'||' !!!');
          dbms_output.put_line('=====================================================================');
      return;
    when others then
      dbms_output.put_line(sqlerrm);
      return;
END;
/
undef uxproc
set heading on
set verify on
set feedback on
set echo on


-- test

-- Vijay provide SID, you will receive request ID
select r.request_id req_id,r.concurrent_program_id,r.parent_request_id,fu.user_name ,
       r.phase_code p,
       r.status_code s,
       (select node_name || ':'
          from applsys.fnd_concurrent_processes cp
         where concurrent_process_id = r.controlling_manager) ||
       r.os_process_id cp_process,
       gi.INSTANCE_NAME || ':' || ss.sid || ',' || ss.serial# inst_sid_serial#,
       gi.HOST_NAME || ':' || pp.spid db_process,
       ss.program,
       ss.status,
   ss.last_call_et,ROUND( ( NVL( r.actual_completion_date, sysdate ) - r.actual_start_date ) * 24*60, 2 ) "duration in min",
       ss.sql_id || ':' || ss.sql_child_number sql_id_chld,
       ss.event,
       ss.WAIT_TIME,
       ss.STATE
  from applsys.fnd_concurrent_requests  r,
       gv$session                       ss,
       gv$process                       pp,
       gv$instance                      gi,
       applsys.fnd_concurrent_processes cp,
       applsys.fnd_user fu
where ss.sid = 775
   and status_code = 'R'
   and ss.audsid(+) = r.oracle_session_id
   and pp.inst_id(+) = ss.inst_id
   and pp.addr(+) = ss.paddr
   and fu.user_id=r.requested_by
   and gi.inst_id(+) = ss.inst_id
   and cp.concurrent_process_id(+) = r.controlling_manager
;

-- show info about request

-- cluster blocks
SELECT DECODE(request,0,'Holder: ','Waiter:') || sid sess, inst_id,id1, id2, lmode, request, type 
FROM gv$lock 
WHERE (id1, id2, type) IN ( 
  SELECT id1, id2, type FROM gv$lock WHERE request>0) 
ORDER BY id1, request;

-- from Swapan
-- 1) find out concurrent program id 
select parent_request_id,phase_code,status_code,concurrent_program_id,logfile_node_name,logfile_name,os_process_id,to_char(actual_start_date,'dd-mon-yy HH24:mi:ss')start_date,to_char(actual_completion_date,'dd-mon-yy HH24:mi:ss') completion_date,ROUND( ( NVL( actual_completion_date, sysdate ) - actual_start_date ) * 24*60, 2 ) duration
from fnd_concurrent_requests
where request_id=668786402;

-- 2) place that here and u will get history 
SELECT request_id,phase_code,status_code, TO_CHAR( request_date, 'DD-MON-YYYY HH24:MI:SS' )
request_date, TO_CHAR( requested_start_date,'DD-MON-YYYY HH24:MI:SS' )
requested_start_date, TO_CHAR( actual_start_date, 'DD-MON-YYYY HH24:MI:SS' )
actual_start_date, TO_CHAR( actual_completion_date, 'DD-MON-YYYY HH24:MI:SS' )
actual_completion_date, TO_CHAR( sysdate, 'DD-MON-YYYY HH24:MI:SS' )
current_date, ROUND( ( NVL( actual_completion_date, sysdate ) - actual_start_date ) * 24*60, 2 ) duration,ARGUMENT_TEXT
FROM FND_CONCURRENT_REQUESTS
WHERE concurrent_program_id = 1013524
order by request_id desc; 


-- From Tausif, monitoring what is user doing, SSO
select inst_id, SID, serial#, sql_id, prev_sql_id, client_identifier, event,module,
       last_call_et,status from gv$session where client_identifier='SMW';
       
select inst_id, SID, serial#, sql_id, prev_sql_id, client_identifier, event,module,
       last_call_et,status from gv$session where client_identifier='KHWA';
       
select inst_id, SID, serial#, sql_id, prev_sql_id, client_identifier, event,module,
       last_call_et,status from gv$session where client_identifier='KHWA';       
       
       show parameter name
       
select * from v$sql where sql_id ='0uan6npnsf1tg';
       
-- From Tausif, monitoring what is user doing, SSO
select inst_id, SID, serial#, sql_id, prev_sql_id, client_identifier, event,module,
       last_call_et,status from gv$session where SID=6303;
       
select * from gv$session where sid=2422;

SELECT * FROM apps.test_tempo_det ORDER BY 2;
SELECT * FROM APPS.TEST_TEMPO_DET ORDER BY 2;

