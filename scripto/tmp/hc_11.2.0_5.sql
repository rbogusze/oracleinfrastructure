REM
REM This healthcheck script is for use on Oracle11gR2 databases only.
REM 
REM
REM Do not use this script on Oracle 10g or Oracle 11gR1 configurations.
REM
REM  It  is recommended to run with markup html ON (default is on) and generate an HTML file for web viewing.
REM  Please provide the output in HTML format when Oracle (support or development) requests healthcheck output.
REM  To convert output to a text file viewable with a text editor, 
REM    change the HTML ON to HTML OFF in the set markup command
REM
REM  Remember to set up a spool file to capture the output
REM
REM Please note that this script also checks Messaging Gateway (MGW) installation if it is configured.
REM If MGW is not configured in your database you will observe errors ORA-942 on output generated. 
REM These errors are expected and can be safely ignored.
REM MGW is NOT required for correct behavior of Advanced Queueing (AQ)


-- connect / as sysdba
-- spool <directory>/file.html

set markup HTML ON entmap off
alter session set nls_date_format='HH24:Mi:SS MM/DD/YY';
set heading off
set echo off
set define off
set lines 180
set numf 9999999999999999
set pages 9999

select 'AQ Health Check (V11.2.0R5) for '||global_name||' on Instance='||instance_name||' generated: '||sysdate o  from global_name, v$instance;
set heading on timing off

DROP TABLE TEMPAQHC_DROPME;
CREATE GLOBAL TEMPORARY TABLE TEMPAQHC_DROPME (ERRORCODE VARCHAR2(12), OBJECT VARCHAR2(50),DESCRIPTION VARCHAR2(1000),ACTION VARCHAR2(1000))
ON COMMIT PRESERVE ROWS;

prompt <a name="Top">  </a>
prompt Configuration: <a href="#DBConfig">Database</a> <a href="#QTConfig">Queue Tables</a> <a href="#QConfig">Queues</a> <a href="#Subsconf">Subscribers</a> <a href="#Props">Propagations</a>  <a href="#Notif">Notifications</a> <a href="#Confother">Other</a>
prompt MGW: <a href="#MGWAgent">Agent</a> <a href="#MGWFQ">Foreign Queues</a> <a href="#MGWLink">Links</a> <a href="#MGWProps">Propagation</a> 
prompt Statistics : <a href="#QMONstats">QMON</a> <a href="#Qstats">Queues</a> <a href="#Pubstats">Publishers</a> <a href="#substats">Subscribers</a> <a href="#subprop">Propagation</a> <a href="#Notifstats">Notifications</a> 
prompt Analisys : <a href="#History">History</a> <a href="#Alerts">Alerts</a>


prompt
prompt ============================================================================================<a name="DBConfig"> </a>
prompt                                                                     
prompt ++ DATABASE CONFIGURATION ++    <a href="#Instance">Instance</a> <a href="#Registry">Registry</a> <a href="#NLS">NLS</a> <a href="#Parameters">Parameters</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

prompt
prompt ++ <a name="Instance">INSTANCE INFORMATION</a> ++ <a href="#DBConfig">DB</a> <a href="#Top">Top</a>
col host format a30 wrap 
select instance_number INSTANCE, instance_name NAME, HOST_NAME HOST, VERSION,
STARTUP_TIME, STATUS, PARALLEL, ARCHIVER,LOGINS, SHUTDOWN_PENDING, INSTANCE_ROLE, ACTIVE_STATE  from gv$instance;
prompt
prompt ============================================================================================<a name="Registry"> </a>

prompt
prompt ++ REGISTRY INFORMATION ++ <a href="#DBConfig">DB</a> <a href="#Top">Top</a>
col comp_id format a10 wrap
col comp_name format a35 wrap
col version format a10 wrap
col schema format a10
select comp_id, comp_name,version,status,modified,schema from DBA_REGISTRY;
prompt
prompt ============================================================================================<a name="NLS"> </a>

prompt
prompt ++ NLS DATABASE PARAMETERS ++ <a href="#DBConfig">DB</a> <a href="#Top">Top</a>
col parameter format a30 wrap
col value format a30 wrap
select * from NLS_DATABASE_PARAMETERS;
prompt
prompt ============================================================================================<a name="Parameters"> </a>

prompt
prompt ++ KEY INITALIZATION PARAMETERS ++  <a href="#DBConfig">DB</a> <a href="#Top">Top</a>
col inst_id HEADING 'Instance' format 99
col name HEADING 'Parameter|Name' format a20
col value HEADING 'Parameter|Value' format a15
col description HEADING 'Description' format a60 word
col defaul HEADING  'Default?' format a8 
select inst_id, name, value, decode (isdefault,'TRUE','YES','NO') defaul, description from gv$parameter 
where name in ('aq_tm_processes', 'job_queue_processes','_job_queue_interval',
    'global_names', 'global_topic_enabled', 'compatible', 'shared_pool_size', 'memory_max_target', 'memory_target',
     'sga_max_size', 'sga_target','streams_pool_size')
order by 1,2;
prompt
prompt ============================================================================================
prompt
prompt

prompt
prompt ============================================================================================<a name="QTConfig"> </a>
prompt                                                                     
prompt ++ QUEUE TABLES ++  <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col owner HEADING 'Owner' format a15
col object_type HEADING 'Payload' format a35 wrap
col message_grouping HEADING 'Message|Grouping' format a13
col primary_instance HEADING 'Primary|Instance' format 999
col secondary_instance HEADING 'Secondary|Instance' format 999
col owner_instance HEADING 'Owner|Instance' format 999
col user_comment HEADING 'User|Comment' format a20 wrap
col objno heading 'Object|Number'

select owner, queue_table, recipients, sort_order, compatible, object_type,
       owner_instance, primary_instance, secondary_instance, type, secure, user_comment 
from dba_queue_tables
order by owner, queue_table;
prompt
prompt ============================================================================================<a name="QConfig"> </a>
prompt                                                                     
prompt ++ QUEUES ++  <a href="#Normalq">Normal Queues</a> <a href="#NPQ">Non Persistent</a> <a href="#Excpq">Exception Queues</a> <a href="#Quepriv">Privileges</a> <a href="#Top">Top</a> 
prompt
prompt ============================================================================================<a name="Normalq"> </a>


col owner HEADING 'Owner' format a10
col name HEADING 'Queue Name' format a30
col qid HEADING 'Id' format 999999999
col max_retries HEADING 'Max.|Retries' format 999999999
col retry_delay HEADING 'Retry|Delay' format 999999999
col dequeue_enabled HEADING 'Dequeue|Enabled' format a7
col enqueue_enabled HEADING 'Enqueue|Enabled' format a7
col retention HEADING 'Retention' format a10 wrap
col user_comment HEADING 'User|Comment' format a10 wrap
col network_name HEADING 'Network|Name' format a10 wrap
col buffered HEADING 'Buffered' format a8

prompt
prompt ++ NORMAL QUEUES ++ <a href="#QConfig">Queues</a> <a href="#Top">Top</a>
select q.owner, q.queue_table, q.name, q.qid, q.enqueue_enabled, q.dequeue_enabled, NVL2(b.queue_id,'YES','NO') buffered,
       q.max_retries, q.retry_delay, q.retention, q.user_comment, q.network_name
from dba_queues q, gv$buffered_queues b
where q.queue_type='NORMAL_QUEUE'
  and q.qid=b.queue_id(+)
order by q.owner, q.queue_table, q.name;
prompt
prompt ============================================================================================<a name="NPQ"> </a>

prompt
prompt ++ NON PERSISTENT QUEUES ++ <a href="#QConfig">Queues</a> <a href="#Top">Top</a>
select owner, queue_table, name, qid, enqueue_enabled, dequeue_enabled,
       max_retries, retry_delay, retention, user_comment, network_name
from dba_queues
where queue_type='NON_PERSISTENT_QUEUE'
order by owner, queue_table, name;
prompt
prompt ============================================================================================ <a name="Excpq"> </a>

prompt
prompt ++ EXCEPTION QUEUES ++ <a href="#QConfig">Queues</a> <a href="#Top">Top</a>
select owner, queue_table, name, qid, enqueue_enabled, dequeue_enabled,
       max_retries, retry_delay, retention, user_comment, network_name
from dba_queues
where queue_type='EXCEPTION_QUEUE'
order by owner, queue_table, name;
prompt

prompt ============================================================================================ <a name="Quepriv"> </a>
prompt
prompt ++ QUEUE PRIVILEGES ++ <a href="#QConfig">Queues</a> <a href="#Top">Top</a>
col owner HEADING 'Owner'
col name HEADING 'Name'
col grantee HEADING 'Grantee'
col grantor HEADING 'Grantor'
col enqueue_privilege HEADING 'Enqueue'
col dequeue_privilege HEADING 'Dequeue'

select owner, name, grantee, grantor, enqueue_privilege, dequeue_privilege from queue_privileges
order by 1,2,3;


prompt <a name="Subsconf"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ SUBSCRIBERS ++ <a href="#Top">Top</a>
prompt
prompt ============================================================================================

set markup HTML OFF entmap off
set serveroutput on


declare 
   cursor mult_qt is select owner, queue_table from dba_queue_tables where recipients='MULTIPLE' order by 1,2;
   statement varchar2(4000);
   TYPE qttype IS REF CURSOR;
   v_qttype qttype;
   qt_record SYS.AQ$_ALERT_QT_S%ROWTYPE;
   queuename varchar2(30);
   substype varchar2(82);
   type_no_match exception;
   pragma exception_init(type_no_match, -932);
begin

  dbms_output.put_line ('<table border=''1'' width=''90%'' align=''center'' summary=''Script output''>');
  dbms_output.put_line ('<tr>');
  dbms_output.put_line ('<th scope=""col"">Owner</th><th scope=""col"">Queue<br>Table</th><th scope=""col"">Queue<br>Name</th>');
  dbms_output.put_line ('<th scope=""col"">Subsriber<br>Name</th><th scope=""col"">Address</th><th scope=""col"">Id</th>');
  dbms_output.put_line ('<th scope=""col"">Subscriber_Type_Description</th><th scope=""col"">Ruleset<br>Name</th><th scope=""col"">Rule<br>Name</th>');
  dbms_output.put_line ('<th scope=""col"">Negative<br>Ruleset</th><th scope=""col"">Transformation</th>');
  dbms_output.put_line ('</tr>');
  dbms_output.put_line ('<tr>');

  for qt_name in mult_qt loop 
    statement :=  'select * from '||qt_name.owner||'.AQ$_'|| qt_name.queue_table || '_S order by queue_name, name, address';
    open v_qttype for statement;
    LOOP
      begin
      FETCH v_qttype INTO qt_record;
      EXIT WHEN v_qttype%NOTFOUND;
      
      substype := '';
      IF qt_record.subscriber_type is NULL THEN substype := 'DEFAULT'; END IF;
      IF BITAND(qt_record.subscriber_type,1) > 0 THEN substype := 'Subscriber'; END IF;
      IF BITAND(qt_record.subscriber_type,2) > 0 THEN substype := substype||' Removed'; END IF;
      IF BITAND(qt_record.subscriber_type,4) > 0 THEN substype := substype||' For address only'; END IF;
      IF BITAND(qt_record.subscriber_type,8) > 0 THEN substype := substype||' Proxy'; END IF;
      IF BITAND(qt_record.subscriber_type,64) > 0 THEN substype := substype||' for persistent msgs'; END IF;
      IF BITAND(qt_record.subscriber_type,128) > 0 THEN substype := substype||' for buffered msgs'; END IF;
      IF BITAND(qt_record.subscriber_type,1024) > 0 THEN substype := substype||' for deferred msgs'; END IF;
      IF substype = '' THEN substype := 'UNKNOWN'; END IF;
      substype := substype||' ('||qt_record.subscriber_type||')';
      select decode(qt_record.queue_name,'0','DEFAULT',qt_record.queue_name) into queuename from dual;
      
      
      dbms_output.put_line ('<td>');
      dbms_output.put_line (qt_name.owner);
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (qt_name.queue_table);
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (queuename);
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (NVL(qt_record.name,'&nbsp;'));
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (NVL(qt_record.address,'&nbsp;'));
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (qt_record.subscriber_id);
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (substype);
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('<td>');
      dbms_output.put_line (NVL(qt_record.ruleset_name,'&nbsp;'));
      dbms_output.put_line ('</td>');            
      dbms_output.put_line ('<td>');
      dbms_output.put_line (NVL(qt_record.rule_name,'&nbsp;'));
      dbms_output.put_line ('</td>');            
      dbms_output.put_line ('<td');
      dbms_output.put_line (NVL(qt_record.negative_ruleset_name,'&nbsp;'));
      dbms_output.put_line ('</td>');            
      dbms_output.put_line ('<td>');
      dbms_output.put_line (NVL(qt_record.trans_name,'&nbsp;'));
      dbms_output.put_line ('</td>');
      dbms_output.put_line ('</tr>');            
 
      exception 
        when type_no_match then
         insert into tempaqhc_dropme values ('Error',qt_name.owner||'.AQ$_'|| qt_name.queue_table || '_S',
            'Potential dictionary insconsistence on queue table '||qt_name.owner||'.'||qt_name.queue_table||'. Error ORA-932',
            'Verify if queues on queue table are working properly. If not contact Oracle Support.');
         commit;
         when others then null;
       end; 
    END LOOP;
    CLOSE v_qttype;     
  end loop;
   
  dbms_output.put_line ('</table>');
end;
/  
set serveroutput off
set markup HTML ON entmap off
prompt
prompt
prompt ============================================================================================


prompt <a name="Props"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ PROPAGATIONS ++ <a href="#Schedule">Scheduled</a> <a href="#Propjob">Jobs</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt
prompt ============================================================================================<a name="Schedule"> </a>
prompt                                                                     
prompt ++ SCHEDULED PROPAGATIONS ++ <a href="#Props">Propagations</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================


col origin format a34
col destination format a34
col schedule_disabled HEADING 'Disabled?' format a9
col message_delivery_mode HEADING 'Delivery|Mode' format a10
col propagation_window HEADING 'Prop.|Window'
col start_date HEADING 'Start|Date'


select schema||'.'||qname origin, destination, schedule_disabled, propagation_window, latency, start_date, current_start_date, max_number, max_bytes
from dba_queue_schedules order by schema, qname, destination, message_delivery_mode;

prompt

select schema||'.'||qname origin, destination, message_delivery_mode, instance, process_name, session_id, last_run_date, next_run_date, next_time
from dba_queue_schedules order by schema, qname, destination, message_delivery_mode;

prompt

select schema||'.'||qname origin, destination, failures, last_error_date, last_error_msg
from dba_queue_schedules order by schema, qname, destination, message_delivery_mode;

prompt ============================================================================================<a name="Propjob"> </a>
prompt                                                                     
prompt ++ PROPAGATION JOBS ++ <a href="#Props">Propagations</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================

col decinst heading 'Declared|Instance' format 99
col runins heading 'Running|Instance' format 99
col state heading 'Job|State'
col status heading 'Running|Status'

prompt
prompt ++ SCHEDULER JOBS ++
prompt

select s.job_name, enabled, state, detached, s.instance_id decinst, running_instance runins, session_id, slave_os_process_id, elapsed_time, cpu_used
from DBA_SCHEDULER_JOBS s LEFT OUTER JOIN DBA_SCHEDULER_RUNNING_JOBS r
    ON (s.job_name=r.job_name and s.owner=r.owner)
where s.JOB_NAME LIKE 'AQ_JOB%'
order by s.instance_id, s.job_name;

prompt
prompt ++ REGULAR JOBS ++
prompt

col broken heading 'BROKEN'

select j.instance decinst, j.job, j.broken, r.instance runins, r.sid, r.spid, r.program, j.failures
from dba_jobs j,
  (select jr.job, jr.sid, p.spid, p.program, jr.instance
   from v$process p, dba_jobs_running jr, v$session s
   where s.sid=jr.sid and s.paddr=p.addr) r 
where r.job(+)=j.job and j.what like '%sys.dbms_aqadm.aq$_propaq(job)%'
order by j.instance, j.job;

prompt
prompt ++ SCHEDULER JOB LAST RUN DETAILS ++ 
prompt

select r.job_name, r.status, r.instance_id, r.session_id, r.slave_pid, r.error#, r.run_duration
from DBA_SCHEDULER_JOB_RUN_DETAILS r,
   (select owner, job_name, max(log_id) max_id
   from DBA_SCHEDULER_JOB_RUN_DETAILS where job_name like '%AQ_JOB%'
   group by owner, job_name) f
where r.log_id = f.max_id;


prompt <a name="Notif"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ NOTIFICATIONS ++ <a href="#Top">Top</a>
prompt
prompt ============================================================================================

col emon# heading 'EMON|Process'
col connection# heading 'Connection|Number'
col qosflags heading 'Service|Quality'
col job_name heading 'Job|Name'
col instance_id heading 'Scheduled|Instance'
col running_instance heading 'Running|Instance'
col session_id heading 'Session|Id'
col slave_os_process_id heading 'Slave OS|Process'
col elapsed_time heading 'Elapsed|Time'
col cpu_used heading 'Cpu|used'

select REG_ID, SUBSCRIPTION_NAME, R.LOCATION_NAME, EMON#, CONNECTION#, QOSFLAGS, TIMEOUT, REG_TIME, STATUS, VERSION
from DBA_SUBSCR_REGISTRATIONS R, SYS.LOC$ L
WHERE R.LOCATION_NAME = L.LOCATION_NAME (+)
order by REG_ID;

prompt

select REG_ID, SUBSCRIPTION_NAME, PAYLOAD_CALLBACK, NAMESPACE, PRESENTATION, USER_CONTEXT, USER#
from DBA_SUBSCR_REGISTRATIONS
order by REG_ID;

prompt 
prompt ++ PL/SQL NOTIFICATION JOBS ++
prompt

select s.job_name, enabled, state, detached, s.instance_id, running_instance, session_id, slave_os_process_id, elapsed_time, cpu_used
from DBA_SCHEDULER_JOBS s LEFT OUTER JOIN DBA_SCHEDULER_RUNNING_JOBS r
    ON (s.job_name=r.job_name and s.owner=r.owner)
where s.JOB_NAME LIKE '%AQ$_PLSQL_NTFN%'
order by s.instance_id, s.job_name;

prompt
prompt ++ GROUPING ++
prompt

select REG_ID, SUBSCRIPTION_NAME, NTFN_GROUPING_CLASS, NTFN_GROUPING_VALUE, NTFN_GROUPING_TYPE, NTFN_GROUPING_START_TIME, NTFN_GROUPING_REPEAT_COUNT
from DBA_SUBSCR_REGISTRATIONS
order by REG_ID;

prompt <a name="Confother"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ OTHER ++ <a href="#Transf">Transformations</a> <a href="#IAgents">HTTP/SMTP Agents</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt
prompt <a name="Transf"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ TRANSFORMATIONS ++ <a href="#Confother">Other</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt
select * from sys.dba_attribute_transformations 
order by owner, name, transformation_id, attribute;
prompt
prompt <a name="IAgents"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ HTTP/SMTP AGENTS ++ <a href="#Confother">Other</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt
select * from AQ$INTERNET_USERS;


prompt <a name="MGWAgent"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ MGW AGENT ++ <a href="#MGWAsts">Status</a> <a href="#MGWAconn">Connection</a> <a href="#MGWAots">Options</a> <a href="#MGWAerr">Error</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col agent_name heading 'Agent|Name'
col agent_status heading 'Status'
col agent_ping heading 'Ping'
col agent_job heading 'Job'
col max_memory heading 'Max.|Memory'
col max_threads heading 'Max.|Threads'
col initfile heading 'Init.|File'
col agent_start_time heading 'Start|Time'
col conntype heading 'Connection|Type'
col max_connections heading 'Max.|Connections'
col agent_user heading 'DB User|Connection'
col agent_database heading 'Connect|String'
col agent_instance heading 'Instance'

prompt <a name="MGWAsts"> </a>
prompt ++ STATUS ++ <a href="#MGWAgent">Agent</a> <a href="#Top">Top</a>
prompt

select agent_name, agent_status, agent_ping, agent_job, max_memory, max_threads, initfile, agent_start_time
from mgw_gateway order by agent_name;

prompt <a name="MGWAconn"> </a>
prompt ++ CONNECTION ++ <a href="#MGWAgent">Agent</a> <a href="#Top">Top</a>
prompt

select agent_name, conntype, max_connections, service, agent_user, agent_database, agent_instance
from mgw_gateway order by agent_name;

prompt <a name="MGWAots"> </a>
prompt ++ OPTIONS ++ <a href="#MGWAgent">Agent</a> <a href="#Top">Top</a>
prompt

select * from mgw_agent_options order by agent_name;

prompt <a name="MGWAerr"> </a>
prompt ++ ERRORS ++ <a href="#MGWAgent">Agent</a> <a href="#Top">Top</a>
prompt

select agent_name, agent_status, last_error_date, last_error_time, last_error_msg
from mgw_gateway order by agent_name;


prompt <a name="MGWFQ"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ MGW FOREIGN QUEUES  ++ <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

select * from mgw_foreign_queues order by name;

prompt <a name="MGWLink"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ MGW LINKS ++ <a href="#MGWLG">Generic</a> <a href="#MGWLM">MQSeries</a> <a href="#MGWLT">TIB/Rendezvous</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

prompt <a name="MGWLG"> </a>
prompt ++ GENERIC ++ <a href="#MGWLink">Links</a> <a href="#Top">Top</a>
prompt

col link_name heading 'Link|Name'
col link_type heading 'Link|Type'
col link_comment heading 'Comment'

select * from mgw_links order by link_name;

prompt <a name="MGWLM"> </a>
prompt ++ Websphere MQ Series Links ++ <a href="#MGWLink">Links</a> <a href="#Top">Top</a>
prompt

col queue_manager heading 'Queue|Manager'
col interface_type heading 'Interface|Type'
col max_connections heading 'Max.|Conn,'
col inbound_log_queue heading 'Inbound|Queue'
col outbound_log_queue heading 'Outbound|Queue'

select * from mgw_mqseries_links order by link_name;

prompt <a name="MGWLT"> </a>
prompt ++ TIB/Rendezvous Links ++ <a href="#MGWLink">Links</a> <a href="#Top">Top</a>
prompt

select * from mgw_tibrv_links order by link_name;

prompt <a name="MGWProps"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ MGW PROPAGATIONS ++ <a href="#MGWSch">Scheduled</a>  <a href="#MGWJobs">Jobs</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col schedule_id heading 'Schedule|Id'
col schedule_disabled heading 'Schedule|Disabled'
col propagation_type heading 'Propagation|Type'
col propagation_window heading 'Propagation|Window'
col job_name heading 'Job|Name'
col agent_name heading 'Agent|Name'
col prop_style heading 'Prop|style'
col link_name heading 'Link|Name'
col poll_interval heading 'Poll|Interval'
col propagated_msgs heading 'Prop.|Msgs'
col exceptionq_msgs heading 'Excpt.|Msgs'


prompt <a name="MGWSch"> </a>
prompt ++ SCHEDULED ++ <a href="#MGWProps">Progations</a> <a href="#Top">Top</a>
prompt

select schedule_id, source, destination, schedule_disabled, propagation_type, latency, start_date, propagation_window
from mgw_schedules order by 1;  

prompt <a name="MGWJobs"> </a>
prompt ++ JOBS ++ <a href="#MGWProps">Progations</a> <a href="#Top">Top</a>
prompt

select job_name, source, destination, enabled, agent_name, status, propagation_type, prop_style
from mgw_jobs order by 1,2,3;

prompt

select job_name, source, destination, link_name, poll_interval, propagated_msgs, exceptionq_msgs, rule, transformation, options
from mgw_jobs order by 1,2,3;

prompt

select job_name, source, destination, failures, last_error_date, last_error_msg, exception_queue
from mgw_jobs order by 1,2,3;

prompt <a name="QMONstats"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ QMON STATISTICS ++ <a href="#QMST">Tasks</a> <a href="#QMSC">Coordinator</a> <a href="#QMSS">Slave</a> <a href="#QMSQ">Per Queue</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col queue_name HEADING 'Queue Name' format a40
col inst_id heading 'Inst' format 99
col task_name heading 'Name'
col task_number heading 'Number'
col task_type heading 'Type'
col task_submit_time heading 'Submit|Time'
col task_ready_time heading 'Ready|time'
col task_expiry_time heading 'Expiry|Time'
col task_start_time heading 'Start|Time'
col task_status heading 'Status'
col server_name heading 'Server|Name'
col num_runs heading 'Runs'
col num_failures heading 'Failures'
col last_created_tasknum heading 'Last|Created|Task'
col num_tasks heading 'Num|Tasks'
col total_task_run_time heading 'Total|Run Time'
col total_task_runs heading 'Total|Runs'
col total_task_failures heading 'Total|Failures'
col metric_type heading 'Metric|Type'
col metric_value heading 'Metric'
col last_failure heading 'Last|Fail'
col last_failure_time heading 'Last|Fail|Time'
col last_failure_tasknum heading 'Last|Fail|TaskNum'
col remark heading 'Remark' format a20
col qmnc_pid heading 'PID'
col num_servers heading 'Num|Servers'
col last_server_start_time heading 'Last Server|Start Time'
col last_server_pid heading 'Last|Server'
col next_wakeup_time heading 'Next|Wakeup'
col next_ready_time heading 'Next|Ready'
col next_expiry_time heading 'Next|Expiry'
col last_wait_time heading 'Last Wait|time'
col last_failure heading 'Last|Failure'
col last_failure_time heading 'Time Last|Failure'
col max_task_latency heading 'Max|Latency'
col min_task_latency heading 'Min|Latency'
col total_task_latency heading 'Total|Latency'
col total_tasks_executed heading 'Total Tasks|Executed'
col max_servers heading 'Max|Severs'
col server_pid heading 'PID'
col server_name heading 'Server|Name'
col server_start_time heading 'Start|time'
col task_start_time heading 'Task Start|Time'
col max_latency heading 'Max|Latency'
col min_latency heading 'Min|Latency'
col total_latency heading ''
col num_tasks heading 'Num|Tasks'
col last_failure_task heading 'Last Fail|Task'
col type HEADING 'Type'
col status HEADING 'Status'
col next_service_time heading 'Next|Service'
col window_end_time heading 'Window|Ends'
col total_runs heading 'Runs'
col total_latency heading 'Latency'
col total_elapsed_time heading 'Elapsed|Time'
col total_cpu_time heading 'CPU|Time'
col tmgr_rows_processed heading 'Mgr|Rows|Processed'
col tmgr_elapsed_time heading  'Mgr|Elapsed|Time'
col tmgr_cpu_time heading 'Mgr|CPU|Time'
col last_tmgr_processing_time heading 'Last Mgr|Processing' 
col deqlog_rows_processed heading 'Deqlog|Rows|Processed'
col deqlog_processing_elapsed_time heading 'DeqLog|Elapsed|Time'
col deqlog_processing_cpu_time heading  'DeqLog|CPU|Time'
col last_deqlog_processing_time heading 'Last DeqLog|Processing'
col dequeue_index_blocks_freed heading 'Dequeue Index|blocks freed'
col history_index_blocks_freed heading 'History Index|blocks freed'
col time_index_blocks_freed heading 'Time Index|blocks freed'
col index_cleanup_count heading 'Index cleanup|Count'
col index_cleanup_elapsed_time heading 'Index cleanup|Elapsed Time'
col index_cleanup_cpu_time heading 'Index cleanup|CPU time'
col last_index_cleanup_time heading 'Index cleanup|Time'

prompt <a name="QMST"> </a>
prompt ++ TASKS ++ <a href="#QMONstats">QMON Stats</a> <a href="#Top">Top</a>
prompt 

select * from gv$qmon_tasks order by inst_id, task_type, task_name, task_number;

select * from gv$qmon_task_stats order by inst_id, task_type, task_name; 

prompt <a name="QMSC"> </a>
prompt ++ COORDINATOR ++ <a href="#QMONstats">QMON Stats</a> <a href="#Top">Top</a>
prompt 

select * from gv$qmon_coordinator_stats order by inst_id;

prompt <a name="QMSS"> </a>
prompt ++ SLAVE ++ <a href="#QMONstats">QMON Stats</a> <a href="#Top">Top</a>
prompt 

select * from gv$qmon_server_stats order by inst_id, qmnc_pid, server_name;

prompt <a name="QMSQ"> </a>
prompt ++ PER QUEUE ++ <a href="#QMONstats">QMON Stats</a> <a href="#Top">Top</a>
prompt 

select qt.schema||'.'||qt.name queue_name, inst_id, type, status, next_service_time, window_end_time, 
       total_runs, total_latency, total_elapsed_time, total_cpu_time
from gv$persistent_qmn_cache, system.aq$_queue_tables qt
where queue_table_id = qt.objno
order by inst_id, queue_name;

prompt

select qt.schema||'.'||qt.name queue_name, tmgr_rows_processed, tmgr_elapsed_time, tmgr_cpu_time, last_tmgr_processing_time, 
       deqlog_rows_processed, deqlog_processing_elapsed_time, deqlog_processing_cpu_time, last_deqlog_processing_time
from gv$persistent_qmn_cache, system.aq$_queue_tables qt
where queue_table_id = qt.objno
order by inst_id, queue_name;

prompt

select qt.schema||'.'||qt.name queue_name, dequeue_index_blocks_freed, history_index_blocks_freed, time_index_blocks_freed, 
       index_cleanup_count, index_cleanup_elapsed_time, index_cleanup_cpu_time, last_index_cleanup_time
from gv$persistent_qmn_cache, system.aq$_queue_tables qt
where queue_table_id = qt.objno
order by inst_id, queue_name;
 
prompt

prompt <a name="Qstats"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ QUEUE STATISTICS ++ <a href="#Perq">Persistent</a>  <a href="#Buffq">Buffered</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col queue_schema HEADING 'Owner' format a10
col queue_name HEADING 'Queue Name' format a30
col queue_id HEADING 'Id' format 999999999
col queue_state HEADING 'State' format a10 wrap
col startup_time HEADING 'Startup'
col num_msgs    HEADING 'Current|Number of Msgs|in Queue'
col cnum_msgs   HEADING 'Cumulative|Total Msgs|for Queue'
col spill_msgs  HEADING 'Current|Spilled Msgs|in Queue'
col cspill_msgs HEADING 'Cumulative|Total Spilled|for Queue'
col dbid HEADING 'Database|Identifier'
col total_spilled_msg HEADING 'Cumulative|Total Spilled|Messages'
col enqueued_msgs heading 'Total msgs|enqueued'
col dequeued_msgs heading 'Total msgs|dequeued'
col browsed_msgs heading 'Total msgs|browsed'
col waiting heading 'Current Msgs| in WAIT Status'
col ready heading 'Current Msgs| in READY Status'
col expired heading 'CCurrent Msgs| in EXPIRED Status'
col enqueued_expiry_msgs heading 'Total msgs|enqueued with|expiry'
col enqueued_delay_msgs heading 'Total msgs|enqueued with|delay'
col msgs_made_expired heading 'Total msgs|made expired'
col msgs_made_ready heading 'Total msgs|made ready'
col first_activity_time heading 'First|Activity|Time'
col last_enqueue_time heading 'Last|Enqueue|Time'
col last_dequeue_time heading 'Last|Enqueue|Time'
col last_tm_ready_time heading 'Last time|Msg ready|by TM'
col last_tm_expiry_time heading 'Last time|Msg expired|by TM'
col total_wait heading 'Total Time|all READY|messages'
col average_wait heading 'Avg Time|all READY|messages'
col elapsed_enqueue_time heading 'Elapsed|Enqueue|time'
col elapsed_dequeue_time heading 'Elapsed|Dequeue|time'
col elapsed_transformation_time heading 'Elapsed|Transformation|time'
col elapsed_rule_evaluation_time heading 'Elapsed|Rule eval.|time'
col queue_recovered heading 'Recovered'
col large_txn_disk_deletes heading 'Large Txn|Disk Deletes'
col small_txn_disk_deletes heading 'Small Txn|Disk Deletes'
col small_txn_disk_locks heading 'Small Txn|Disk Locks'
col current_disk_del_txn_count heading 'Current|Disk deletes|Txn count'
col current_deq_txn_count heading 'Current|Dequeue txn|Count'
col large_txn_size heading 'Large|Txn size'
col deqlog_array_size heading 'Size|Dequeue Log'


prompt <a name="Perq"> </a>
prompt ++ PERSISTENT QUEUES ++ <a href="#Qstats">Queue Statistics</a> <a href="#Top">Top</a>
prompt 

select inst_id, queue_schema, queue_name, queue_id, enqueued_msgs, dequeued_msgs, browsed_msgs,
     waiting, ready, expired, enqueued_expiry_msgs, enqueued_delay_msgs, msgs_made_ready, msgs_made_expired 
from gv$persistent_queues, gv$aq
where queue_id=qid
order by 1,2,3;

prompt

select inst_id, queue_schema, queue_name, queue_id, first_activity_time, last_enqueue_time, 
     last_dequeue_time, last_tm_ready_time, last_tm_expiry_time, total_wait, average_wait, elapsed_enqueue_time, 
     elapsed_dequeue_time, elapsed_transformation_time, elapsed_rule_evaluation_time 
from gv$persistent_queues, gv$aq
where queue_id=qid
order by 1,2,3;

prompt

select pq.inst_id, queue_schema, queue_name, pq.queue_id, queue_recovered, 
     large_txn_disk_deletes, small_txn_disk_deletes, small_txn_disk_locks, 
     current_disk_del_txn_count, current_deq_txn_count, large_txn_size, deqlog_array_size
from gv$persistent_queues pq, x$kwqdlstat dq
where pq.inst_id=dq.inst_id and pq.queue_id=dq.queue_id
order by 1,2,3;

prompt <a name="Buffq"> </a>
prompt ++ BUFFERED QUEUES ++ <a href="#Qstats">Queue Statistics</a> <a href="#Top">Top</a>
prompt 

select inst_id, queue_schema, queue_name, queue_id, queue_state, startup_time, 
       num_msgs, spill_msgs, waiting, ready, expired, cnum_msgs, cspill_msgs, expired_msgs,
       total_wait, average_wait
from gv$buffered_queues, gv$aq
where queue_id=qid
order by 1,2,3;

prompt

select bq.inst_id, queue_schema, queue_name, bq.queue_id, queue_recovered, 
     large_txn_disk_deletes, small_txn_disk_deletes, small_txn_disk_locks, 
     current_disk_del_txn_count, current_deq_txn_count, large_txn_size, deqlog_array_size
from gv$buffered_queues bq, x$kwqdlstat dq
where bq.inst_id=dq.inst_id and bq.queue_id=dq.queue_id
order by 1,2,3;


prompt <a name="Pubstats"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ PUBLISHERS STATISTICS ++ <a href="#Perpub">Persistent</a>  <a href="#Buffpub">Buffered</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt
 
col queue_schema HEADING 'Owner' format a10
col queue_name HEADING 'Queue Name' format a30
col startup_time HEADING 'Startup'
col num_msgs    HEADING 'Current|Number of Msgs|for Publisher'
col cnum_msgs   HEADING 'Cumulative|Total Msgs|for Publisher'
col sender_name HEADING 'Name'
col sender_address HEADING 'Address' format a40 wrap
col publisher_state HEADING 'State' format a20
col last_enqueued_msg HEADING 'Last enqueued|Msgs Id'
col unbrowsed_msgs HEADING 'Unbrowsed|Msgs'
col overspilled_msgs HEADING 'Overspilled|Mesgs'
col memused HEADING 'Memory|Used(Kb)'
col publisher_name heading 'Name'
col publisher_address heading 'Address'

prompt <a name="Perpub"> </a>
prompt ++ PERSISTENT PUBLISHERS ++ <a href="#Pubstats">Publishers</a> <a href="#Top">Top</a>
prompt 

select * from gv$persistent_publishers 
order by inst_id, queue_schema, queue_name, publisher_name, publisher_address;

prompt <a name="Buffpub"> </a>
prompt ++ BUFFERED PUBLISHERS ++ <a href="#Pubstats">Publishers</a> <a href="#Top">Top</a>
prompt
prompt   Note: For Streams Buffered publishers not populated when CCA optimization is in effect
prompt

select inst_id, queue_schema, queue_name, sender_name, sender_address, publisher_state,
       num_msgs, cnum_msgs, last_enqueued_msg, unbrowsed_msgs, overspilled_msgs, memory_usage/1024 memused
from gv$buffered_publishers
order by 1,2,3,4,5;

prompt <a name="substats"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ SUBSCRIBERS STATISTICS ++ <a href="#Persubs">Persistent</a>  <a href="#Buffsubs">Buffered</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col queue_schema HEADING 'Owner' format a10
col queue_name HEADING 'Queue Name' format a30
col startup_time HEADING 'Startup'
col num_msgs    HEADING 'Current|Number of Msgs|for Subscriber'
col cnum_msgs   HEADING 'Cumulative|Total Msgs|for Subscriber'
col subscriber_name HEADING 'Name'
col subscriber_address HEADING 'Address' format a40 wrap
col subscriber_type HEADING 'Type' format a20
col message_lag HEADING 'Subscriber|Delay'
col total_dequeued_msg HEADING 'Total Msgs|Dequeued'
col total_spilled_msg HEADING 'Total Msgs|Spilled'
col last_browsed_num HEADING 'SCN last|browsed Msgs'
col last_dequeued_num HEADING 'SCN last|dequeued Msgs'
col current_enq_seq HEADING 'SCN current|enqueued Msg'
col expired_msgs heading 'Total msgs|expired'

prompt <a name="Buffsubs"> </a>
prompt ++ PERSISTENT SUBSCRIBERS ++ <a href="#substats">Subscribers</a> <a href="#Top">Top</a>
prompt

select inst_id, queue_id, queue_schema, queue_name, subscriber_name, subscriber_address, first_activity_time,
   enqueued_msgs, dequeued_msgs, browsed_msgs, expired_msgs, dequeued_msg_latency, last_enqueue_time, last_dequeue_time   
from gv$persistent_subscribers
order by inst_id, queue_schema, queue_name, subscriber_name, subscriber_address;

prompt <a name="Buffsubs"> </a>
prompt ++ BUFFERED SUBSCRIBERS ++ <a href="#substats">Subscribers</a> <a href="#Top">Top</a>
prompt
prompt   Note: For Streams Buffered Subscribers statistics are zero when CCA optimization is in effect
prompt

select inst_id, queue_schema, queue_name, subscriber_name, subscriber_address, subscriber_type,
       message_lag, num_msgs, cnum_msgs, total_dequeued_msg, total_spilled_msg, expired_msgs
       startup_time, last_browsed_num, last_dequeued_num, current_enq_seq
from gv$buffered_subscribers
order by 1,2,3,4,5;

prompt <a name="subprop"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ PROPAGATION STATISTICS ++ <a href="#schstat">Scheduled</a> <a href="#Buffsend">Buffered Sender</a> <a href="#Buffrec">Buffered Receiver</a> <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt


col dblink Heading 'Destination|Database|Link'
col total_msgs HEADING 'Total|Messages'
col total_bytes HEADING 'Total|Bytes'
col elapsed_dequeue_time HEADING 'Elapsed|Dequeue Time|(CentiSecs)'
col elapsed_pickle_time HEADING 'Total Time|(CentiSecs)'
col elapsed_propagation_time heading 'Elapsed|Propagation Time|(CentiSecs)'
col last_msg_latency heading 'Last Msg|Latency'
col last_msg_enqueue_time heading 'Last Msg|Enqueue Time'
col last_msg_propagation_time  heading 'Last Msg|Propagation Time'
col src_dbname heading 'Source|DB Name'
col last_received_msg heading 'Last|Received|Msg'
col elapsed_enqueue_time heading 'Elapsed|Enqueue Time|(CSecs)'
col elapsed_unpickle_time heading 'Elapsed|Unpickle|Time(CSecs)'
col elapsed_pickle_time heading 'Elapsed|Pickle|Time(CSecs)'
col elapsed_rule_time heading 'Elapsed|Rule|Time(CSecs)'
col total_time heading 'Total Time|Executing (Secs)'
col total_number heading 'Total Msgs|Propagated'
col total_bytes heading 'Total Bytes|Propagated'
col avg_size heading 'Avg. message|size(bytes)'
col avg_size heading 'Avg. seconds|to propagate|1 Message'

prompt <a name="schstat"> </a>
prompt ++ SCHEDULES STATISTICS ++ <a href="#subprop">Propagation</a> <a href="#Top">Top</a>
prompt

select schema||'.'||qname origin, destination, message_delivery_mode, total_time, total_number, total_bytes, 
 avg_size, avg_time, elapsed_dequeue_time, elapsed_pickle_time
from dba_queue_schedules order by origin, destination, message_delivery_mode;
 
prompt <a name="Buffsend"> </a>
prompt ++ BUFFERED SENDER ++ <a href="#subprop">Propagation</a> <a href="#Top">Top</a>
prompt

select inst_id, queue_schema||'.'||queue_name origin, dst_queue_schema||'.'||dst_queue_name destination, dblink, 
   total_msgs, total_bytes,  elapsed_dequeue_time, elapsed_pickle_time,  elapsed_propagation_time,
   last_msg_latency, last_msg_enqueue_time, last_msg_propagation_time
from gv$propagation_sender order by 1,2,3;   

prompt <a name="Buffrec"> </a>
prompt ++ BUFFERED RECEIVER ++ <a href="#subprop">Propagation</a> <a href="#Top">Top</a>
prompt

select inst_id, src_queue_schema||'.'||src_queue_name origin, dst_queue_schema||'.'||dst_queue_name destination, src_dbname
   last_received_msg, total_msgs, elapsed_enqueue_time, elapsed_unpickle_time,  elapsed_rule_time
from gv$propagation_receiver order by inst_id, src_queue_schema, src_queue_name;  

prompt <a name="Notifstats"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ NOTIFICATION STATISTICS ++ <a href="#Top">Top</a>
prompt
prompt ============================================================================================
prompt

col all_emon_servers heading 'EMON slaves|that server|registration'
col num_ntfns heading 'Number of|notifications'
col num_grouping_ntfns heading 'Number of|Grouping|notifications'
col total_payload_bytes_sent heading 'Total|Payload|Bytes Sent'
col total_plsql_exec_time heading 'PL/SQL|Callback|Exec Time'
col last_ntfn_start_time heading 'Last|Notification|Start'
col last_ntfn_sent_time heading 'Last|Notification|Sent'
col total_emon_latency heading 'Time to|process|notifications'
col last_err heading 'Last|Error'
col last_err_time heading 'Last|Error|Time'
col last_update_time heading 'Last|Update|Time'

select s.inst_id, s.reg_id, r.subscription_name, s.emon#, all_emon_servers, num_ntfns, num_grouping_ntfns, total_payload_bytes_sent, total_plsql_exec_time
from gv$subscr_registration_stats s, dba_subscr_registrations r
where s.reg_id=r.reg_id (+)
order by s.inst_id, s.reg_id;

prompt

select s.inst_id, s.reg_id, r.subscription_name, last_ntfn_start_time, last_ntfn_sent_time, total_emon_latency, last_err, last_err_time, last_update_time
from gv$subscr_registration_stats s, dba_subscr_registrations r
where s.reg_id=r.reg_id (+)
order by s.inst_id, s.reg_id;


prompt <a name="History"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ HISTORY ++ <a href="#hprpmin">Propagation waits Last 30 min</a> <a href="#hprpday">Propagation waits Last day</a> <a href="#hbufq">Buffered Queues</a> <a href="#hbufsubs">Buffered Subscribers</a>  <a href="#Top">Top</a>
prompt
prompt ============================================================================================

col busy format a4
col percentage format 999d9
col event wrapped
col snap_id format 999999 HEADING 'Snap ID'
col BEGIN_INTERVAL_TIME format a28 HEADING 'Interval|Begin|Time'
col END_INTERVAL_TIME format a28 HEADING 'Interval|End|Time'
col INSTANCE_NUMBER HEADING 'Instance|Number'
col Queue format a28 wrap Heading 'Queue|Name'
col num_msgs    HEADING 'Current|Number of Msgs|in Queue'
col cnum_msgs   HEADING 'Cumulative|Total Msgs|for Queue'
col spill_msgs  HEADING 'Current|Spilled Msgs|in Queue'
col cspill_msgs HEADING 'Cumulative|Total Spilled|for Queue'
col dbid        HEADING 'Database|Identifier'
col total_spilled_msg HEADING 'Cumulative|Total Spilled|Messages'


prompt <a name="hprpmin"> </a>
prompt ++ PROPAGATION WAITS FOR LAST 30 MINUTES ++ <a href="#History">History</a> <a href="#Top">Top</a>
prompt

BREAK ON process_name;
COMPUTE SUM LABEL 'TOTAL' OF PERCENTAGE ON process_name;

SELECT props.process_name,
       ash_cp.event_count, ash_tot.total_count, 
       ash_cp.event_count*100/ash_tot.total_count percentage, 
       'YES' busy,
       ash_cp.event
FROM
(select inst_id, session_id, session_serial#, event,
             count(sample_time) as event_count
 from  gv$active_session_history
 where sample_time > sysdate - 30/24/60
 group by inst_id, session_id, session_serial#, event) ash_cp,       
(select inst_id, count(distinct sample_time) as total_count
 from  gv$active_session_history
 where sample_time > sysdate - 30/24/60
 group by inst_id) ash_tot,
(select schema, qname, destination, process_name, instance, session_id, count(*) counting
 from dba_queue_schedules
 group by instance, session_id, schema, qname, destination, process_name) props     
WHERE ash_tot.inst_id=ash_cp.inst_id
  AND props.instance=ash_cp.inst_id
  AND substr(props.session_id,1,instr(props.session_id,',')-1) = ash_cp.session_id 
ORDER BY props.process_name;

prompt <a name="hprpday"> </a>
prompt ++ PROPAGATION WAITS FOR LAST DAY ++ <a href="#History">History</a> <a href="#Top">Top</a>
prompt

SELECT props.process_name,
       ash_cp.event_count, ash_tot.total_count, 
       ash_cp.event_count*100/ash_tot.total_count percentage, 
       'YES' busy,
       ash_cp.event
FROM
(select inst_id, session_id, session_serial#, event,
             count(sample_time) as event_count
 from  gv$active_session_history
 where sample_time > sysdate - 1
 group by inst_id, session_id, session_serial#, event) ash_cp,       
(select inst_id, count(distinct sample_time) as total_count
 from  gv$active_session_history
 where sample_time > sysdate - 1
 group by inst_id) ash_tot,
(select schema, qname, destination, process_name, instance, session_id, count(*) counting
 from dba_queue_schedules
 group by instance, session_id, schema, qname, destination, process_name) props     
WHERE ash_tot.inst_id=ash_cp.inst_id
  AND props.instance=ash_cp.inst_id
  AND substr(props.session_id,1,instr(props.session_id,',')-1) = ash_cp.session_id 
ORDER BY props.process_name;

prompt <a name="hbufq"> </a>
prompt ++ BUFFERED QUEUE HISTORY FOR LAST DAY ++ <a href="#History">History</a> <a href="#Top">Top</a>
prompt

select s.begin_interval_time,s.end_interval_time , 
   bq.snap_id, 
   bq.num_msgs, bq.spill_msgs, bq.cnum_msgs, bq.cspill_msgs,
   bq.queue_schema||'.'||bq.queue_name Queue,
   bq.queue_id, bq.startup_time,bq.instance_number,bq.dbid
from   dba_hist_buffered_queues bq, dba_hist_snapshot s 
where  bq.snap_id=s.snap_id   and s.end_interval_time >= systimestamp-1 
order by bq.queue_schema,bq.queue_name,s.end_interval_time;

prompt <a name="hbufsubs"> </a>
prompt ++ BUFFERED SUBSCRIBER HISTORY FOR LAST DAY ++ <a href="#History">History</a> <a href="#Top">Top</a>
prompt

select s.begin_interval_time,s.end_interval_time , 
   bs.snap_id,bs.subscriber_id, 
   bs.num_msgs, bs.cnum_msgs, bs.total_spilled_msg,
   bs.subscriber_name,subscriber_address,
   bs.queue_schema||'.'||bs.queue_name Queue,
   bs.startup_time,bs.instance_number,bs.dbid
from   dba_hist_buffered_subscribers bs, dba_hist_snapshot s 
where    bs.snap_id=s.snap_id and s.end_interval_time >= systimestamp-1 
order by    bs.queue_schema,bs.queue_name,bs.subscriber_id,s.end_interval_time;

prompt

prompt <a name="Alerts"> </a>
prompt ============================================================================================
prompt                                                                     
prompt ++ ALERTS ++ <a href="#Top">Top</a>
prompt
prompt ============================================================================================

declare 
   cursor c_registry is select comp_name, status from dba_registry where status != 'VALID';
   cursor c_aq_tm is select inst_id, value from gv$parameter 
      where isdefault != 'TRUE' and name = 'aq_tm_processes';
begin
  for r_registry in c_registry loop 
      insert into tempaqhc_dropme values ('Warning',r_registry.comp_name,'Component '||r_registry.comp_name||' is on status '||r_registry.status,
            'If you have upgraded recently verify that you have followed all post-upgrade steps. Check My Oracle Support for further help. Action will dependent on component.');
         commit;
  end loop;
  
  for r_aq_tm in c_aq_tm loop 
    IF ((to_number(r_aq_tm.value) = 0) OR (to_number(r_aq_tm.value) = 10)) THEN
       insert into tempaqhc_dropme values ('Alert','Wrong value for aq_tm_processes parameter','Current setting of parameter aq_tm_processes on instance '||r_aq_tm.inst_id||' may produce a inadequate AQ management',
         'Please change the value of this parameter to its default setting. Use : alter system reset aq_tm_processes statement.');
       commit;
    ELSIF (to_number(r_aq_tm.value) > 5) THEN
       insert into tempaqhc_dropme values ('Information','High value for aq_tm_processes parameter','Current setting of parameter aq_tm_processes on instance '||r_aq_tm.inst_id||' could be considered high',
         'Please consider changing value for aq_tm_processes parameter to its default setting. Use : alter system reset aq_tm_processes statement.');
       commit;
    END IF;   
  end loop; 
  
  insert into tempaqhc_dropme values ('Information','Consider coalesce','If you have observed QMON performance problems, please consider coalecing AQ OITs',
     'Please check details on My Oracle Support Doc Id 271855.1');   
  
end;
/

col errorcode heading 'Type of alert' format a15
col description format a50 wrap
col action format a50 wrap

select * from tempaqhc_dropme;

set timing off
set markup html off
clear col
clear break
spool
prompt   Turning Spool OFF!!!
spool off

DROP TABLE TEMPAQHC_DROPME;

exit;
REM ala ma kota
