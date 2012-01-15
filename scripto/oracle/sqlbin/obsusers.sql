prompt Select Users logged in last 24H and still logged in
col USER_NAME format a40 
col RESPONSIBILITY format a40 
col FIRST_CONNECT format a30 
col LAST_CONNECT format a30 
set linesize 400 
set pagesize 400 
alter session set current_schema=APPS;
select distinct fu.user_name User_Name,fr.RESPONSIBILITY_KEY Responsibility , to_char(first_connect, 'YYYY/MM/DD HH24:MI') FIRST_CONNECT , to_char(last_connect,'YYYY/MM/DD HH24:MI') LAST_CONNECT 
from fnd_user fu, fnd_responsibility fr, icx_sessions ic 
where fu.user_id = ic.user_id AND 
fr.responsibility_id = ic.responsibility_id AND 
ic.disabled_flag='N' AND 
ic.responsibility_id is not null AND 
ic.last_connect > sysdate - 1 and ic.user_id != '-1'; 
exit;
