variable WAIT_NAME varchar2(30)
rem exec :WAIT_NAME := 'latch free'
rem exec :WAIT_NAME := 'db file sequential read'
rem exec :WAIT_NAME := 'db file scattered read'
rem exec :WAIT_NAME := 'PL/SQL lock timer'
rem exec :WAIT_NAME := 'CPU time'
rem exec :WAIT_NAME := 'log file parallel write'
exec :WAIT_NAME := 'log file sync'

prompt ###########################################################
prompt # For OBS with request ID			         #
prompt ###########################################################

set linesize 200
column EVENT format a12
column USER_CONCURRENT_PROGRAM_NAME format a22
select ses.SID, ses.SERIAL#, wait.EVENT, wait.WAIT_TIME, wait.SECONDS_IN_WAIT, fnd.REQUEST_ID, fnd.user_concurrent_program_name
FROM V$SESSION ses
 , V$SESSION_WAIT wait
 , apps.FND_CONCURRENT_WORKER_REQUESTS fnd
where ses.sid = wait.sid
and wait.EVENT = :WAIT_NAME
and fnd.os_process_id = ses.process
order by wait.SECONDS_IN_WAIT;

prompt ###########################################################
prompt # Based on V$SESSION_WAIT		 		 #
prompt ###########################################################

set pagesize 120
set linesize 200
column EVENT format a26
column USER_CONCURRENT_PROGRAM_NAME format a22
select ses.SID
 , ses.SERIAL#
 , wait.EVENT
 , wait.WAIT_TIME
 , wait.SECONDS_IN_WAIT
 , ses.sql_hash_value
 , ses.USERNAME
 , substr(stx.sql_text,1,100)
FROM V$SESSION ses
 , V$SESSION_WAIT wait 
 , V$SQL stx
where ses.sid = wait.sid
and wait.EVENT = :WAIT_NAME
and stx.hash_value = ses.sql_hash_value
order by wait.SECONDS_IN_WAIT;

select 'ALTER SYSTEM KILL SESSION ''' || ses.SID || ',' || ses.SERIAL# || ''';' 
FROM V$SESSION ses
 , V$SESSION_WAIT wait
where ses.sid = wait.sid
and wait.EVENT = :WAIT_NAME
order by wait.SECONDS_IN_WAIT;

prompt ###########################################################
prompt # Based on V$SESSION_EVENT				 #
prompt # Active sessions reporting the wait for more than 5s	 #
prompt ###########################################################

column USERNAME format a26
select * from (
select ses.SID
 , ses.SERIAL#
 , ses.sql_hash_value
 , ses.USERNAME
-- , ses.process
 , event.EVENT
 , event.TOTAL_WAITS
 , event.TIME_WAITED
 , substr(stx.sql_text,1,100)
FROM V$SESSION ses
 , V$SESSION_EVENT event
 , V$SQL stx
where ses.sid = event.sid
and event.EVENT = :WAIT_NAME
and stx.hash_value = ses.sql_hash_value
and ses.status = 'ACTIVE'
and event.TIME_WAITED > 500
order by event.TIME_WAITED desc)
where rownum < 5;

select * from (
select 'ALTER SYSTEM KILL SESSION ''' || ses.SID || ',' || ses.SERIAL# || ''';'
FROM V$SESSION ses
 , V$SESSION_EVENT event
 , V$SQL stx
where ses.sid = event.sid
and event.EVENT = :WAIT_NAME
and stx.hash_value = ses.sql_hash_value
and ses.status = 'ACTIVE'
and event.TIME_WAITED > 500
order by event.TIME_WAITED desc)
where rownum < 5;

