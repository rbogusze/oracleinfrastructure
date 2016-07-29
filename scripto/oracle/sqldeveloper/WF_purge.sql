-- Size information
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('WF_ITEM_ACTIVITY_STATUSES','WF_ITEM_ACTIVITY_STATUSES_N1','WF_ITEM_ACTIVITY_STATUSES_PK','WF_ITEM_ACTIVITY_STATUSES_N2','WF_ITEM_ACTIVITY_STATUSES_N3','WF_ITEM_ACTIVITY_STATUSES_N4',
'WF_ITEM_ACTIVITY_STATUSES_H','WF_ITEM_ACTIVITY_STATUSES_H_N1','WF_ITEM_ACTIVITY_STATUSES_H_N2','WF_ITEM_ACTIVITY_STATUSES_H_N3','WF_ITEM_ACTIVITY_STAT_H_N98',
'WF_ITEM_ATTRIBUTE_VALUES','WF_ITEM_ATTRIBUTE_VALUES_N1','WF_ITEM_ATTRIBUTE_VALUES_PK',
'WF_NOTIFICATIONS','WF_NOTIFICATIONS_N1','WF_NOTIFICATIONS_N2','WF_NOTIFICATIONS_N3','WF_NOTIFICATIONS_N4','WF_NOTIFICATIONS_N5','WF_NOTIFICATIONS_N6','WF_NOTIFICATIONS_N7','WF_NOTIFICATIONS_N8','WF_NOTIFICATIONS_PK',
'WF_NOTIFICATION_ATTRIBUTES','WF_NOTIFICATIONS_ATTR_PK',
'WF_ITEMS','WF_ITEMS_N1','WF_ITEMS_N2','WF_ITEMS_N3','WF_ITEMS_N4','WF_ITEMS_N5','WF_ITEMS_N6','WF_ITEMS_PK',
'WF_NOTIFICATION_ATTRIBUTES','WF_NOTIFICATIONS_ATTR_PK',
'WF_COMMENTS','WF_COMMENTS_N1','WF_COMMENTS_N2','WF_COMMENTS_N3','WF_COMMENTS_N4');
--1089GB

@i

--select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name in 
select * from all_tables where table_name in 
('WF_ITEM_ACTIVITY_STATUSES','WF_ITEM_ACTIVITY_STATUSES_H','WF_ITEM_ATTRIBUTE_VALUES','WF_NOTIFICATIONS','WF_ITEMS','WF_PROCESS_ACTIVITIES');

select table_name, num_rows, blocks from all_tables where table_name in 
('WF_ITEM_ACTIVITY_STATUSES','WF_ITEM_ACTIVITY_STATUSES_H','WF_ITEM_ATTRIBUTE_VALUES','WF_NOTIFICATIONS','WF_ITEMS','WF_PROCESS_ACTIVITIES');


-- Basic statistics to watch purging progress
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_ITEMS a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_ITEM_ACTIVITY_STATUSES a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_ITEM_ACTIVITY_STATUSES_H a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_ITEM_ATTRIBUTE_VALUES a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_NOTIFICATIONS a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_ACTIVITY_TRANSITIONS a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_PROCESS_ACTIVITIES a; 

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_NOTIFICATION_OUT a;

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_NOTIFICATION_ATTRIBUTES a;


alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select request_id, phase_code, status_code, ARGUMENT_TEXT, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE  from apps.fnd_concurrent_requests 
where request_id in ('5630746','5630742');

-- 593261442  - the one that does not work
-- 593331642 - my with 10000

show parameter undo
@longops
@active4


-- check how purge is doing
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
    and a.request_id in ('4771','5440')
    --and a.phase_code = 'R'
)
order by ses.sid
;

-- Check just my running requests, based on SSO
select distinct ses.SID, stx.sql_id, ses.sql_hash_value, ses.USERNAME, pro.SPID "OS PID", stx.sql_text from 
     V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
where ses.paddr = pro.addr
and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and ses.client_identifier='212469221'
order by 1;

-- check bind variables
SELECT name,      position ,      datatype_string ,      was_captured,      value_string  
FROM   v$sql_bind_capture  WHERE  sql_id = 'ahp1qmsnqdyhc';


select distinct ses.SID, stx.sql_id, ses.sql_hash_value, ses.USERNAME, ses.event, stx.sql_text from 
     V$SESSION ses
    ,V$SQL stx
    ,V$PROCESS pro
where ses.paddr = pro.addr
--and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and ses.sid = 2070
;



select 
  distinct ses.SID, 
  stx.sql_id, 
  ses.event,
  a.request_id, 
  a.ARGUMENT_TEXT, 
  stx.sql_text 
from 
    GV$SESSION ses,
    GV$SQL stx,
    GV$PROCESS pro,
    apps.fnd_concurrent_requests a,
    apps.fnd_concurrent_processes b    
where ses.paddr = pro.addr
and ses.status = 'ACTIVE'
and stx.hash_value = ses.sql_hash_value
and a.controlling_manager = b.concurrent_process_id
and pro.pid = b.oracle_process_id
and b.session_id=ses.audsid
and a.request_id in ('667741398')
and a.phase_code = 'R'
order by ses.sid
;


/*
This is good:
SELECT /*+ first_rows index(WI,WF_ITEMS_N3)  WI.ITEM_TYPE, WI.ITEM_KEY FROM WF_ITEMS WI WHERE WI.END_DATE <= :B2 AND WI.END_DATE > :B1 AND EXISTS (SELECT NULL FROM WF_ITEM_TYPES WIT WHERE WI.END_DAT
SELECT WN.NOTIFICATION_ID FROM WF_ITEM_ACTIVITY_STATUSES WIAS, WF_NOTIFICATIONS WN WHERE WIAS.ITEM_TYPE = :B2 AND WIAS.ITEM_KEY = :B1 AND WIAS.NOTIFICATION_ID = WN.GROUP_ID AND ((:B3 = 1) OR NOT EXIST
DELETE FROM WF_ITEM_ACTIVITY_STATUSES_H WHERE ITEM_TYPE = :B2 AND ITEM_KEY = :B1 
DELETE FROM WF_ITEM_ACTIVITY_STATUSES WHERE ITEM_TYPE = :B2 AND ITEM_KEY = :B1 
DELETE FROM WF_ITEM_ATTRIBUTE_VALUES WHERE ITEM_TYPE = :B2 AND ITEM_KEY = :B1 
DELETE FROM WF_ITEMS WHERE ITEM_TYPE = :B2 AND ITEM_KEY = :B1 
and now we see the commit

Right after request submission (10
SELECT WI.ITEM_KEY FROM WF_ITEM_ACTIVITY_STATUSES WIAS, WF_ITEMS WI WHERE WI.ITEM_TYPE = 'WFERROR' AND WI.PARENT_ITEM_TYPE = WIAS.ITEM_TYPE AND WI.PARENT_ITEM_KEY = WIAS.ITEM_KEY AND WI.PARENT_CONTEXT = WIAS.PROCESS_ACTIVITY AND WI.END_DATE IS NULL AND WIAS.ACTIVITY_STATUS = 'COMPLETE'

After a while
DELETE FROM WF_NOTIFICATION_ATTRIBUTES WNA WHERE WNA.NOTIFICATION_ID = :B1 
DELETE FROM WF_NOTIFICATIONS WN WHERE WN.NOTIFICATION_ID = :B1 

And after 5 days of running it just sits doing this:
gnm9yr4rp7pad SELECT WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE FROM WF_ITEMS WI WHERE WI.BEGIN_DATE BETWEEN :B4 AND NVL(:B3 , WI.BEGIN_DATE) AND WI.ITEM_TYPE = :B2 AND WI.ROOT_ACTIVITY = :B1 

593780245 - WFERROR, , 70, TEMP, N, 500, N, N
SELECT WI.ITEM_TYPE, WI.ITEM_KEY FROM (SELECT PERSISTENCE_DAYS, NAME FROM WF_ITEM_TYPES WHERE PERSISTENCE_TYPE = :B2 AND NAME=:B1 ) WIT, WF_ITEMS WI WHERE WI.ITEM_TYPE = WIT.NAME AND WI.END_DATE <= :B4 -NVL(WIT.PERSISTENCE_DAYS,0) AND WI.END_DATE > :B3 AND NOT EXISTS (SELECT NULL FROM WF_ITEMS WI2 WHERE WI2.END_DATE IS NULL START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE AND WI2.ITEM_KEY = WI.ITEM_KEY CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE AND PRIOR WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY ) AND NOT EXISTS (SELECT NULL FROM WF_ITEMS WI2 WHERE WI2.END_DATE IS NULL START WITH WI2.ITEM_TYPE = WI.ITEM_TYPE AND WI2.ITEM_KEY = WI.ITEM_KEY CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY) ORDER BY WI.END_DATE
SELECT WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE FROM WF_ITEMS WI WHERE WI.BEGIN_DATE BETWEEN :B4 AND NVL(:B3 , WI.BEGIN_DATE) AND WI.ITEM_TYPE = :B2 AND WI.ROOT_ACTIVITY = :B1 
UPDATE WF_NOTIFICATIONS WN SET END_DATE = NVL(BEGIN_DATE, TO_DATE('2002/08/01','YYYY/MM/DD')) + 1 WHERE NOT EXISTS (SELECT NULL FROM WF_ITEM_ACTIVITY_STATUSES WIAS WHERE WIAS.NOTIFICATION_ID = WN.GROUP_ID) AND NOT EXISTS (SELECT NULL FROM WF_ITEM_ACTIVITY_STATUSES_H WIASH WHERE WIASH.NOTIFICATION_ID = WN.GROUP_ID) AND WN.END_DATE IS NULL AND WN.BEGIN_DATE <= :B2 AND ROWNUM < :B1 
SELECT WN.NOTIFICATION_ID FROM WF_NOTIFICATIONS WN WHERE WN.MESSAXX_TYPE = :B2 AND NOT EXISTS (SELECT NULL FROM WF_ITEM_ACTIVITY_STATUSES WIAS WHERE WIAS.NOTIFICATION_ID = WN.GROUP_ID) AND NOT EXISTS (SELECT NULL FROM WF_ITEM_ACTIVITY_STATUSES_H WIAS WHERE WIAS.NOTIFICATION_ID = WN.GROUP_ID) AND ( EXISTS( SELECT NULL FROM WF_ITEM_TYPES WIT WHERE WN.END_DATE+NVL(WIT.PERSISTENCE_DAYS,0) <= :B4 AND WN.MESSAXX_TYPE = WIT.NAME AND WIT.PERSISTENCE_TYPE = :B3 ) OR NOT EXISTS( SELECT NULL FROM WF_ITEM_TYPES WIT WHERE WN.MESSAXX_TYPE = WIT.NAME)) AND( (:B1 = 1) OR NOT EXISTS (SELECT NULL FROM WF_DIG_SIGS WDS WHERE SIG_OBJ_TYPE = 'WF_NTF' AND SIG_OBJ_ID = WN.NOTIFICATION_ID))


593783412 - 1194 - , , 70, TEMP, N, 1, N, N
DELETE FROM WF_ACTIVITY_TRANSITIONS WAT WHERE WAT.TO_PROCESS_ACTIVITY IN (SELECT WPA.INSTANCE_ID FROM WF_PROCESS_ACTIVITIES WPA WHERE WPA.PROCESS_NAME = :B3 AND WPA.PROCESS_ITEM_TYPE = :B2 AND WPA.PROCESS_VERSION = :B1 )

593815380 - 4290 - , , 0, TEMP, N, 300000, N, N
First regular delete, as expected, then 2 days of:
SELECT WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE FROM WF_ITEMS WI WHERE WI.BEGIN_DATE BETWEEN :B4 AND NVL(:B3 , WI.BEGIN_DATE) AND WI.ITEM_TYPE = :B2 AND WI.ROOT_ACTIVITY = :B1 
which looked like stale, but after a while:
BEGIN WF_PURGE.TotalConcurrent(:errbuf,:rc,:A0,:A1,:A2,:A3,:A4,:A5,:A6,:A7); END;
SELECT WPA2.INSTANCE_ID, WPA2.ACTIVITY_ITEM_TYPE, WPA2.ACTIVITY_NAME FROM WF_PROCESS_ACTIVITIES WPA1, WF_ACTIVITIES WA, WF_PROCESS_ACTIVITIES WPA2 WHERE WPA1.INSTANCE_ID = :B2 AND WPA2.PROCESS_ITEM_TYPE = WA.ITEM_TYPE AND WPA2.PROCESS_NAME = WA.NAME AND WA.ITEM_TYPE = WPA1.ACTIVITY_ITEM_TYPE AND WA.NAME = WPA1.ACTIVITY_NAME AND :B1 >= WA.BEGIN_DATE AND :B1 < NVL(WA.END_DATE, :B1 +1) AND WPA2.PROCESS_VERSION = WA.VERSION
which is something I have not seen before
Again:
SELECT WI.ITEM_TYPE, WI.ITEM_KEY, WI.ROOT_ACTIVITY, WI.BEGIN_DATE FROM WF_ITEMS WI WHERE WI.BEGIN_DATE BETWEEN :B4 AND NVL(:B3 , WI.BEGIN_DATE) AND WI.ITEM_TYPE = :B2 AND WI.ROOT_ACTIVITY = :B1 


*/

@tpt/snapper ash 5 1 1035
@tpt/sw 4201
@tpt/sw 4290
@tpt/sqltext 8uzpput57hqkf
@tpt/snapper ash,stats 20 1 4290,4201
@tpt/sw 


-- how often is the SQL executed
select *
from   dba_hist_sqlstat t, dba_hist_snapshot s
where  t.snap_id = s.snap_id
and    t.dbid = s.dbid
and    t.instance_number = s.instance_number
and    s.begin_interval_time between trunc(sysdate)-1 and trunc(sysdate) -- yesterday's stats
and sql_id='gnm9yr4rp7pad'
;

select * from V$ACTIVE_SESSION_HISTORY
where session_id=1194
order by sample_id desc
;

-- ######################################################
-- Trying to figure out what WFERROR is trying to tell me
-- ######################################################
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date), count(*) from WF_ITEMS a where item_type = 'WFERROR' 
group by trunc(begin_date) order by trunc(begin_date) desc; 

select * from fnd_nodes;

-- check for new errors
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select /*+ FULL(a) parallel(a,8) */ * from wf_items a where item_type = 'WFERROR' order by begin_date desc;

select /*+ FULL(a) parallel(a,8) */ * from wf_items a where item_type = 'WFERROR' and trunc(begin_date) = '2016/03/09' 
order by begin_date desc;
/*
*/

select * from wf_item_activity_statuses where item_key = '&1';
/*
ITEM_TYPE	ITEM_KEY	PROCESS_ACTIVITY	ACTIVITY_STATUS	ACTIVITY_RESULT_CODE	ASSIGNED_USER	NOTIFICATION_ID	BEGIN_DATE	END_DATE	EXECUTION_TIME	ERROR_NAME	ERROR_MESSAGE	ERROR_STACK	OUTBOUND_QUEUE_ID	DUE_DATE	SECURITY_GROUP_ID	ACTION	PERFORMED_BY	INST_ID
WFERROR	412961535	61174	ACTIVE	#NULL			2016/01/29		1125903									2
WFERROR	412961535	271347	NOTIFIED		SYSADMIN	499517781	2016/01/29		1125909									2
WFERROR	412961535	271351	COMPLETE	EVENT_ERROR			2016/01/29	2016/01/29	1125907									2
WFERROR	412961535	271353	COMPLETE	#NULL			2016/01/29	2016/01/29	1125906									2
*/

select * from wf_item_activity_statuses_h where notification_id = 502457466;

select * from WF_ITEM_ATTRIBUTE_VALUES where item_key = '429026269';
/*
An error occurred in subscription execution but the details are not available. Verify that Workflow API WF_EVENT.SetErrorInfo is used to set the error details in the PLSQL rule function.
WFERROR	414597735	SUB_GUID	8BC7FF01BC631A21E0340000BEA7000B
WFERROR	414597735	EVENT_NAME	ge.apps.inv.ItemTypes.Mail

ITEM_TYPE	ITEM_KEY	NAME	TEXT_VALUE
WFERROR	414973314	EVENT_KEY	GFB_OM_OL_32632187_210316040360686
WFERROR	414973314	EVENT_MESSAGE	
WFERROR	414973314	EVENT_NAME	ge.gfb.ont.real
*/

-- nice, where recent errors come from
select wf.item_key, wf.begin_date, wfa.text_value
from WF_ITEM_ATTRIBUTE_VALUES wfa, wf_items wf 
where wfa.item_type = 'WFERROR' and wfa.name = 'ERROR_STACK' and wf.item_key = wfa.item_key and wf.begin_date > sysdate -1 order by wf.begin_date desc;


-- OK, check how many events we have like ge.gfb.ont.real
-- **** stat_av_1
select /*+ FULL(a) parallel(a,8) */ text_value, count(*) from WF_ITEM_ATTRIBUTE_VALUES a where item_type = 'WFERROR' and name = 'EVENT_NAME' group by text_value order by count(*) desc;

-- What type of WFERROR items has come today
-- **** stat_av_2
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select wf.item_key, wf.begin_date, wfa.text_value
from WF_ITEM_ATTRIBUTE_VALUES wfa, wf_items wf 
where wfa.item_type = 'WFERROR' and wfa.name = 'EVENT_NAME' and wf.item_key = wfa.item_key and wf.begin_date > sysdate -1 order by wf.begin_date desc;

select wf.item_key, wf.begin_date, wfa.text_value
from WF_ITEM_ATTRIBUTE_VALUES wfa, wf_items wf 
where wfa.item_type = 'WFERROR' and wfa.name = 'EVENT_NAME' and wf.item_key = wfa.item_key 
and wf.begin_date < sysdate -100 and wf.begin_date > sysdate -101 order by wf.begin_date desc;

-- different look, searching patterns for null WFERRORs, group by ERROR_STACK
-- **** stat_av_3
select substr(wfa.text_value, 1, 40), count(*)
from WF_ITEM_ATTRIBUTE_VALUES wfa, wf_items wf 
where wfa.item_type = 'WFERROR' and wfa.name = 'ERROR_STACK' and wf.item_key = wfa.item_key 
and wf.begin_date > sysdate -1 group by substr(wfa.text_value, 1, 40) order by count(*) desc;


/*
ITEM_TYPE	ITEM_KEY	NAME	TEXT_VALUE
WFERROR	WF415753259	ERROR_ITEM_KEY	3715842
WFERROR	WF415753259	ERROR_ITEM_TYPE	OEOL
WFERROR	WF415753259	ERROR_MESSAGE	User-Defined Exception
WFERROR	WF415753259	ERROR_MONITOR_URL	http://erpitest.health.ge.com:8800/OA_HTML/RF.jsp?function_id=1005803&resp_id=-1&resp_appl_id=-1&security_group_id=0&lang_code=US&params2=itemType%3D%7B!A7600C1A575ED20F%26itemKey%3D%7B!B9667B5E009CB0A6%26wa%3D%7B!4E7C112D98B8D1B25576CF5003C9F764%26wm%3D%7B!DD284597289EA766%26fExt%3DX
WFERROR	WF415753259	ERROR_NAME	1
WFERROR	WF415753259	ERROR_NOTIFICATION_ID	
WFERROR	WF415753259	ERROR_NTF_RECIPIENT_ROLE	
WFERROR	WF415753259	ERROR_PERSON_ID	
WFERROR	WF415753259	ERROR_PERSON_USERNAME	
WFERROR	WF415753259	ERROR_RESULT_CODE	#EXCEPTION
WFERROR	WF415753259	ERROR_STACK	"
XXXX_IIP_PKG.PROCESS_IIP_TRANSFER(OEOL, 3715842, Insufficient quantity to issue from IIP, DGR.IIP.631.017.GR)
Wf_Engine_Util.Function_Call(XXXX_ONT.XXXX_IIP_PKG.PROCESS_IIP_TRANSFER, OEOL, 3715842, 133434, RUN)"
WFERROR	WF415753259	ERROR_TYPE	
WFERROR	WF415753259	ERROR_USER_KEY	Sales Order 2527205, Line 4.1..
*/

-- different look 2, searching patterns for null WFERRORs, group by EVENT_NAME
-- **** stat_av_4
select wfa.text_value, count(*)
from WF_ITEM_ATTRIBUTE_VALUES wfa, wf_items wf 
where wfa.item_type = 'WFERROR' and wfa.name = 'EVENT_NAME' and wf.item_key = wfa.item_key 
and wf.begin_date > sysdate -1 group by wfa.text_value order by count(*) desc;

select * from WF_ITEM_ATTRIBUTE_VALUES where item_key = '429026269';
/*
ITEM_TYPE	ITEM_KEY	NAME	TEXT_VALUE
WFERROR	429026269	CONTEXT	WSH
WFERROR	429026269	DELIVERY_ID	163790251
WFERROR	429026269	ERROR_ACTIVITY_ID	
WFERROR	429026269	ERROR_ACTIVITY_LABEL	
WFERROR	429026269	ERROR_ASSIGNED_USER	
WFERROR	429026269	ERROR_DETAILS	PLSQL:WF_STANDARD.ErrorDetails/WFERROR:429026269
WFERROR	429026269	ERROR_ITEM_KEY	
WFERROR	429026269	ERROR_ITEM_TYPE	
WFERROR	429026269	ERROR_MESSAGE	An error occurred in subscription execution but the details are not available. Verify that Workflow API WF_EVENT.SetErrorInfo is used to set the error details in the PLSQL rule function.
WFERROR	429026269	ERROR_STACK	
WFERROR	429026269	EVENT_DATA_URL	https://erp-web-prod-04.am.health.ge.com:8800/OA_HTML/RF.jsp?function_id=1016903&resp_id=-1&resp_appl_id=-1&security_group_id=0&lang_code=US&params=nCt2uo6vRiN4-4vjslpXAfsF5Vqd7j3OXwukOuvtA-bJi5NSC0qYeNrUGv3bhG6HCuzheI2NoCQaxI7adkzeqQ0lDiDYHaVnunnAgupCb71CvdHocblHE4KFGLDNqGoC
WFERROR	429026269	EVENT_DETAILS	PLSQL:WF_STANDARD.EVENTDETAILS/WFERROR:429026269
WFERROR	429026269	EVENT_KEY	ITCS_WSH_ND_163790251_300316030355054
WFERROR	429026269	EVENT_MESSAGE	
WFERROR	429026269	EVENT_NAME	oracle.apps.ge.ont.delivery.insert
WFERROR	429026269	EVENT_SUBSCRIPTION	https://erp-web-prod-04.am.health.ge.com:8800/OA_HTML/RF.jsp?function_id=1023212&resp_id=-1&resp_appl_id=-1&security_group_id=0&lang_code=US&params=nFqFuK3RWhcSb7jyRPOE2cwqAUPRIu9CMSyFDFH6ydg.Mu1UukxcZbyIkabp5vER
WFERROR	429026269	SKIP_ERROR_SUB	3230303832303036313634373336
WFERROR	429026269	SUBSCRIPTION_DETAILS	PLSQL:WF_STANDARD.SubscriptionDetails/WFERROR:429026269
WFERROR	429026269	SUB_GUID	8BC7FF01BC631A21E0340000BEA7000B
*/

-- **** stat_av_5
-- just check for new records in wf_items
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select /*+ FULL(a) parallel(a,8) */ * from wf_items a order by begin_date desc;



-- tmp
select * from wf_item_activity_statuses where item_key = '&1';

select * from dba_objects where status='INVALID' AND OWNER IN ('APPS','APPLSYS'); 

select * from wf_item_activity_statuses where notification_id = 501816850;

select count(*) from wf_event_subscriptions;
select * from wf_event_subscriptions where GUID='8BC7FF01BC631A21E0340000BEA7000B';


-- check what comes new
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from WF_ITEMS;
select /*+ FULL(a) parallel(a,8) */ * from WF_ITEMS a order by begin_date desc;




-- show number of WFERROR messages every day
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date), item_type, count(*) from WF_ITEMS a group by trunc(begin_date), item_type order by trunc(begin_date) desc ;


-- pivot1 see what is comming in
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
with pivot_data as ( select /*+ FULL(a) parallel(a,8) */ trunc(begin_date) t_date, item_type from WF_ITEMS a )
select * from pivot_data
pivot ( count(*) for (item_type) in ('WFERROR','CREATEPO','POAPPRV','OEOL','OEOH') ) order by t_date desc ;

with pivot_data as ( select /*+ FULL(a) parallel(a,8) */ trunc(date_value) t_date, item_type from WF_ITEM_ATTRIBUTE_VALUES a )
select * from pivot_data
pivot ( count(*) for (item_type) in ('WFERROR','CREATEPO','POAPPRV','OEOL','OEOH') ) order by t_date desc ;

/*
300605607	7672368	809435723	973524829	40888095
05-JAN-05	0	0	0	0	0
22-JAN-20	0	0	0	0	0
*/

-- why do we have so many open WFERROR items? what is there
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date), item_type, count(*) from WF_ITEMS a group by trunc(begin_date), item_type order by trunc(begin_date) desc ;
select /*+ FULL(a) parallel(a,8) */ * from WF_ITEMS order by begin_date desc ;

-- trash
select count(*) from ECX_OUTBOUND_LOGS;
select count(*) from ECX_DOCLOGS;
select count(*) from ECX_ERROR_MSGS;
select count(*) from ECX_MSG_LOGS;
select count(*) from ECX_EXTERNAL_LOGS;


-- SR request, but nice monitoring anyway
-- **** stat1 WFERROR items analysis
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
select /*+ FULL(p) parallel(p,8) FULL(c) parallel(c,8) */ sysdate, c.item_type child, decode(c.end_date,null,'OPEN','CLOSED') child_status, 
c.parent_item_type parent, decode(c.parent_item_type,null,'NOPARENT',decode(p.end_date,null,'OPEN','CLOSED')) parent_status, 
count(*) 
from 
wf_items p, 
wf_items c 
where 
p.item_type(+) = c.parent_item_type 
and p.item_key(+) = c.parent_item_key 
and c.item_type='WFERROR' 
group by c.item_type, decode(c.end_date,null,'OPEN','CLOSED'), c.parent_item_type , 
decode(c.parent_item_type,null,'NOPARENT',decode(p.end_date,null,'OPEN','CLOSED')) 
--order by c.item_type , c.parent_item_type; 
order by count(*) desc, c.item_type , c.parent_item_type; 

-- **** stat2 All items analysis
select /*+ FULL(wi) parallel(wi,8) */ wi.item_type, witt.DISPLAY_NAME, wit.PERSISTENCE_TYPE P_TYPE, wit.PERSISTENCE_DAYS P_DAYS, 
nvl(to_char(wi.end_date, 'YYYY'),'OPEN') CLOSED, count(wi.item_key) COUNT 
from wf_items wi, wf_item_types wit, wf_item_types_tl witt 
where wi.ITEM_TYPE=wit.NAME 
and wit.NAME=witt.NAME 
and witt.LANGUAGE = 'US' 
group by wi.item_type, witt.DISPLAY_NAME, wit.PERSISTENCE_TYPE, 
wit.PERSISTENCE_DAYS, to_char(wi.end_date, 'YYYY') 
--order by 3 asc, 1 asc, 5 asc; 
order by COUNT desc, 3 asc, 1 asc, 5 asc; 

-- **** stat3 count all items group by type
select /*+ FULL(a) parallel(a,8) */ item_type, count(*) from WF_ITEMS a group by item_type order by count(*) desc;

-- **** stat4 show number of items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR'), item_type, count(*) from WF_ITEMS a group by trunc(begin_date, 'YEAR'), item_type having count(*) > 1000 order by trunc(begin_date, 'YEAR') desc;

-- **** stat5 show number of OEOL items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a where item_type='OEOL' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;

-- **** stat6 show number of WFERROR items for every year
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a where item_type='WFERROR' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a where item_type='ECXERROR' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;

-- **** stat7 check what will be purged by the @purge_wferror_new2.sql
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
SELECT /*+ FULL(a) parallel(a,8) */ count(1), sysdate
FROM wf_items a
WHERE item_type = 'WFERROR' and parent_item_type is null 
AND end_date is null ; 

-- **** stat8 check what will be purged by the @purge_wferre_where_parent_closed.sql
SELECT /*+ FULL(a) parallel(a,8) */ count(*)
FROM wf_items a
WHERE item_type = 'WFERROR' and parent_item_key in (select /*+ FULL(b) parallel(b,8) */ item_key from wf_items b where end_date is not NULL);

-- **** ??stat9 show closed items that will be purged by standard Purge program
select /*+ FULL(wi) parallel(wi,8) */ wi.item_type, witt.DISPLAY_NAME, wit.PERSISTENCE_TYPE P_TYPE, wit.PERSISTENCE_DAYS P_DAYS, 
nvl(to_char(wi.end_date, 'YYYY'),'OPEN') CLOSED, count(wi.item_key) COUNT 
from wf_items wi, wf_item_types wit, wf_item_types_tl witt 
where wi.ITEM_TYPE=wit.NAME 
and wit.NAME=witt.NAME 
and witt.LANGUAGE = 'US' 
and wi.end_date is not null
group by wi.item_type, witt.DISPLAY_NAME, wit.PERSISTENCE_TYPE, 
wit.PERSISTENCE_DAYS, to_char(wi.end_date, 'YYYY') 
--order by 3 asc, 1 asc, 5 asc; 
order by COUNT desc, 3 asc, 1 asc, 5 asc; 

-- **** stat10 What is comming as 'WFERROR'
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date), count(*) from WF_ITEMS a where item_type = 'WFERROR' group by trunc(begin_date) order by trunc(begin_date) desc;

-- **** stat11 check when end-date was set in wf_items, null when there is no end-date
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD";
select /*+ FULL(a) parallel(a,8) */ trunc(end_date), count(*) from WF_ITEMS a group by trunc(end_date) order by count(*) desc;

-- **** stat12 show number of POAPPRV items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a 
where item_type='POAPPRV' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;

-- **** stat14 show number of MRPEXPWF items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a 
where item_type='MRPEXPWF' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;

-- **** stat15 show number of OECHGORD items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a 
where item_type='OECHGORD' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;

select distinct to_char(begin_date,'RRRR'), count(1)
from apps.wf_items
where item_type = 'OECHGORD'
group by to_char(begin_date,'RRRR')
order by 1;

-- **** stat16 show number of OEOH items for every year
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) 
from WF_ITEMS a where item_type='OEOH' group by trunc(begin_date, 'YEAR'), item_type order by trunc(begin_date, 'YEAR') desc;



--- other
-- check what takes most of the space
select * from dba_segments;
select owner,segment_name, round((bytes)/1024/1024/1024) SIZE_GB, tablespace_name, segment_type from dba_segments order by bytes desc;

select count(*) from XXXX_EOM.ORDER_LINE_LOG ;
select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name='ORDER_LINE_LOG';

-- XXXX_EOM	ORDER_LINE_LOG
select /*+ FULL(a) parallel(a,8) */ trunc(logged_date, 'YEAR') year, count(*) from XXXX_EOM.ORDER_LINE_LOG a group by trunc(logged_date, 'YEAR') order by trunc(logged_date, 'YEAR') desc;

-- #################################################################
-- APPLSYS	SYS_LOB0002693761C00040$$	370	WF_NOTIFICATION_OUT	LOBSEGMENT
-- #################################################################
SELECT table_name, column_name, segment_name, a.bytes 
FROM dba_segments a JOIN dba_lobs b 
USING (owner, segment_name) 
WHERE b.table_name = 'WF_NOTIFICATION_OUT'; 
/*
TABLE_NAME	COLUMN_NAME	SEGMENT_NAME	BYTES
WF_NOTIFICATION_OUT	"USER_DATA"."HEADER"."PROPERTIES"	SYS_LOB0002693761C00037$$	5242880
WF_NOTIFICATION_OUT	"USER_DATA"."TEXT_LOB"	SYS_LOB0002693761C00040$$	397416595456
WF_NOTIFICATION_OUT	USER_PROP	SYS_LOB0002693761C00041$$	5242880
*/

select owner,segment_name, round((bytes)/1024/1024/1024) SIZE_GB, tablespace_name, segment_type from dba_segments where segment_name = 'SYS_LOB0002693761C00040$$';

/*
OWNER	SEGMENT_NAME	SIZE_GB	TABLESPACE_NAME	SEGMENT_TYPE
APPLSYS	SYS_LOB0002693761C00040$$	370	APPS_TS_QUEUES	LOBSEGMENT

after srink:
OWNER	SEGMENT_NAME	SIZE_GB	TABLESPACE_NAME	SEGMENT_TYPE
APPLSYS	SYS_LOB0002693761C00040$$	0	APPS_TS_QUEUES	LOBSEGMENT
*/

select owner,segment_name, round((bytes)/1024/1024/1024) SIZE_GB, tablespace_name, segment_type from dba_segments where segment_name = 'WF_NOTIFICATION_OUT';
/*
OWNER	SEGMENT_NAME	SIZE_GB	TABLESPACE_NAME	SEGMENT_TYPE
APPLSYS	WF_NOTIFICATION_OUT	9	APPS_TS_QUEUES	TABLE

OK, so size ot the table and log size are different things, althou lob belongs to table
*/


select * from dba_lobs;
select * from dba_lobs where segment_name='SYS_LOB0002693761C00040$$';
/*
OWNER	TABLE_NAME	COLUMN_NAME	SEGMENT_NAME	TABLESPACE_NAME	INDEX_NAME	CHUNK	PCTVERSION	RETENTION	FREEPOOLS	CACHE	LOGGING	ENCRYPT	COMPRESSION	DEDUPLICATION	IN_ROW	FORMAT	PARTITIONED	SECUREFILE	SEGMENT_CREATED	RETENTION_TYPE	RETENTION_VALUE
APPLSYS	WF_NOTIFICATION_OUT	"USER_DATA"."TEXT_LOB"	SYS_LOB0002693761C00040$$	APPS_TS_QUEUES	SYS_IL0002693761C00040$$	8192		18000		NO	YES	NONE	NONE	NONE	YES	ENDIAN NEUTRAL 	NO	NO	YES	YES	
*/
select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name='WF_NOTIFICATION_OUT';
/*
TABLE_NAME	LAST_ANALYZED	SAMPLE_SIZE	NUM_ROWS	BLOCKS
WF_NOTIFICATION_OUT	2016/01/31 13:56:57	4910	7522	1155896
*/

select count(*) from WF_NOTIFICATION_OUT;

SELECT table_name, column_name, segment_name, a.bytes
FROM dba_segments a JOIN dba_lobs b
USING (owner, segment_name)
WHERE b.table_name = 'WF_NOTIFICATION_OUT';
/*
TABLE_NAME	COLUMN_NAME	SEGMENT_NAME	BYTES
WF_NOTIFICATION_OUT	"USER_DATA"."HEADER"."PROPERTIES"	SYS_LOB0002693761C00037$$	5242880
WF_NOTIFICATION_OUT	"USER_DATA"."TEXT_LOB"	SYS_LOB0002693761C00040$$	397416595456
WF_NOTIFICATION_OUT	USER_PROP	SYS_LOB0002693761C00041$$	5242880

after shrink:

TABLE_NAME	COLUMN_NAME	SEGMENT_NAME	BYTES
WF_NOTIFICATION_OUT	"USER_DATA"."HEADER"."PROPERTIES"	SYS_LOB0002693761C00037$$	1048576
WF_NOTIFICATION_OUT	"USER_DATA"."TEXT_LOB"	SYS_LOB0002693761C00040$$	133169152
WF_NOTIFICATION_OUT	USER_PROP	SYS_LOB0002693761C00041$$	1048576
*/

desc WF_NOTIFICATION_OUT
/*
Name              Null     Type                     
----------------- -------- ------------------------ 
Q_NAME                     VARCHAR2(30)             
MSGID             NOT NULL RAW(16 BYTE)             
CORRID                     VARCHAR2(128)            
PRIORITY                   NUMBER                   
STATE                      NUMBER                   
DELAY                      TIMESTAMP(6)             
EXPIRATION                 NUMBER                   
TIME_MANAGER_INFO          TIMESTAMP(6)             
LOCAL_ORDER_NO             NUMBER                   
CHAIN_NO                   NUMBER                   
CSCN                       NUMBER                   
DSCN                       NUMBER                   
ENQ_TIME                   TIMESTAMP(6)             
ENQ_UID                    NUMBER                   
ENQ_TID                    VARCHAR2(30)             
DEQ_TIME                   TIMESTAMP(6)             
DEQ_UID                    NUMBER                   
DEQ_TID                    VARCHAR2(30)             
RETRY_COUNT                NUMBER                   
EXCEPTION_QSCHEMA          VARCHAR2(30)             
EXCEPTION_QUEUE            VARCHAR2(30)             
STEP_NO                    NUMBER                   
RECIPIENT_KEY              NUMBER                   
DEQUEUE_MSGID              RAW(16 BYTE)             
SENDER_NAME                VARCHAR2(30)             
SENDER_ADDRESS             VARCHAR2(1024)           
SENDER_PROTOCOL            NUMBER                   
USER_DATA                  SYS.AQ$_JMS_TEXT_MESSAGE 
USER_PROP                  SYS.ANYDATA              

*/

-- summary
select count(*) from WF_NOTIFICATION_OUT;

select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'WF_NOTIFICATION_OUT';

select * from dba_lobs where segment_name='SYS_LOB0002693761C00040$$';

select owner,segment_name, round((bytes)/1024/1024/1024) SIZE_GB, tablespace_name, segment_type from dba_segments where segment_name = 'SYS_LOB0002693761C00040$$';

-- does not work
select sum(dbms_lob.getlength ("USER_DATA")) from WF_NOTIFICATION_OUT;
select sum(dbms_lob.getlength (USER_DATA)) from WF_NOTIFICATION_OUT;
select sum(dbms_lob.getlength ("USER_DATA"."TEXT_LOB")) from WF_NOTIFICATION_OUT;
select sum(dbms_lob.getlength ("SYS_LOB0002693761C00040$$")) from WF_NOTIFICATION_OUT;
select sum(dbms_lob.getlength (SYS_LOB0002693761C00040$$)) from WF_NOTIFICATION_OUT;
/*
'USER_PROP' - 62064
'USER_DATA' - 62073
'USER_DATA.TEXT_LOB' - 124146
'USER_DATA.HEADER' - 110352
*/

select dbms_lob.getlength (SYS_LOB0002693761C00040$$) from APPLSYS.WF_NOTIFICATION_OUT;
select dbms_lob.getlength ("SYS_LOB0002693761C00040$$") from APPLSYS.WF_NOTIFICATION_OUT;
select sum(dbms_lob.getlength (SYS_LOB0002693761C00040$$)) from APPLSYS.WF_NOTIFICATION_OUT;
@o WF_NOTIFICATION_OUT

select 
owner username, 
segment_name segment_name, 
segment_type segment_type, 
bytes/1024/1024/1024 Gbytes, 
extents extents 
from 
dba_segments 
where 
segment_name ='SYS_LOB0002693761C00040$$'; 

select sum(dbms_lob.getlength(file_data))/1024/1024/1024 GB from applsys.fnd_lobs; 





-- #############################################################
-- APPS	SYS_LOB0009030171C00036$$	347	WF_BPEL_QTAB
-- #############################################################

select * from dba_lobs where segment_name='SYS_LOB0009030171C00036$$';
/*
OWNER	TABLE_NAME	COLUMN_NAME	SEGMENT_NAME
APPS	WF_BPEL_QTAB	"USER_DATA"."EVENT_DATA"	SYS_LOB0009030171C00036$$
*/

desc WF_BPEL_QTAB
/*
Name              Null     Type               
----------------- -------- ------------------ 
(...)
SENDER_PROTOCOL            NUMBER             
USER_DATA                  APPS_NE.WF_EVENT_T 
USER_PROP                  SYS.ANYDATA        
*/

select * from WF_BPEL_QTAB;

select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name='WF_BPEL_QTAB';

select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0009030171C00036$$';
-- 348GB
-- 348GB after shrink

select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('WF_BPEL_QTAB');
-- 33GB
-- 33GB after shrink

select /*+ FULL(a) parallel(a,8) */ count(*), sysdate from WF_BPEL_QTAB a;
/*
19750822	30-MAR-16
*/

select table_name, last_analyzed, sample_size, num_rows, blocks from all_tables where table_name='WF_BPEL_QTAB';
--WF_BPEL_QTAB	31-JAN-16	3936935	19684675	4274844

select owner,segment_name, round((bytes)/1024/1024/1024) SIZE_GB, tablespace_name, segment_type from dba_segments where segment_name = 'SYS_LOB0009030171C00036$$';
-- OWNER	SEGMENT_NAME	SIZE_GB	TABLESPACE_NAME	SEGMENT_TYPE
-- APPS	SYS_LOB0009030171C00036$$	348	APPS_TS_QUEUES	LOBSEGMENT

@o wf_queue_temp_evt_table
@o wf_queue_temp_evt_table

select count(*) from WF_QUEUE_TEMP_EVT_TABLE;

-- Deq_time Column not Updated when Message Dequeued (Doc ID 1293709.1)
-- 2.
select * from dba_queues where name = 'WF_BPEL_Q';
select name, queue_table from dba_queues where name = 'WF_BPEL_Q';
WF_BPEL_Q	WF_BPEL_QTAB

-- 3.
select queue_table, recipients from dba_queue_tables where queue_table = 'WF_BPEL_QTAB';
QUEUE_TABLE	RECIPIENTS
WF_BPEL_QTAB	MULTIPLE

-- 4.
select queue, name from aq$wf_bpel_qtab_s;
45 rows

select name, EVENTID from system.aq$_queues where name = 'WF_BPEL_Q';
NAME	EVENTID
WF_BPEL_Q	9030193

select NAME, FLAGS from system.aq$_queue_tables where name = 'WF_BPEL_QTAB';
NAME	FLAGS
WF_BPEL_QTAB	9

-- 5.
select AQ$_GET_SUBSCRIBERS('APPS','WF_BPEL_Q','WF_BPEL_QTAB',null, 9030193, 9) from dual;
errors out

select * from dba_objects where object_name like '%SUBSCRIBERS';
SYS	AQ$_GET_SUBSCRIBERS		11853284		FUNCTION	16-OCT-09	22-JAN-16	2012-08-11:06:27:56	VALID	N	N	N	1	

-- 6.
select queue,msg_id,msg_state,enq_time,deq_time,consumer_name from apps.aq$wf_bpel_qtab order by queue,msg_id;




-- #############################################################
-- Largest tables in DB
-- #############################################################

select owner, segment_name, segment_type, round(sum(bytes)/1024/1024/1024) SIZE_GB 
from dba_segments group by owner, segment_name, segment_type order by SIZE_GB desc;

select owner, segment_name, segment_type, round(sum(bytes)/1024/1024/1024) SIZE_GB 
from dba_segments group by owner, segment_name, segment_type 
having round(sum(bytes)/1024/1024/1024) > 50 order by SIZE_GB desc;



-- #############################################################
-- TMP
-- #############################################################

select /*+ FULL(a) parallel(a,8) */ item_type, parent_item_type, count(item_key)
from wf_items a
where item_type in ('MRPEXPWF','WFERROR')
group by item_type, parent_item_type;

alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(begin_date, 'YEAR') year, item_type, count(*) from WF_ITEMS a 
where item_type='WIPISHPW' group by trunc(begin_date, 'YEAR'), item_type having count(*) > 1000 order by trunc(begin_date, 'YEAR') desc;

desc wf_items
@o

select wf_purge.GetPurgeableCount('WFERROR') from dual;
select wf_purge.GetPurgeableCount('OEOL') from dual;

SELECT /*+ FULL(WAS) parallel(WAS,8) FULL(P) parallel(P,8) FULL(H) parallel(H,8) */ count(*) 
FROM WF_ITEM_ACTIVITY_STATUSES WAS, WF_PROCESS_ACTIVITIES P, OE_ORDER_HEADERS_ALL H 
WHERE TO_NUMBER(WAS.ITEM_KEY) = H.HEADER_ID AND WAS.PROCESS_ACTIVITY = P.INSTANCE_ID 
AND P.ACTIVITY_ITEM_TYPE = 'OEOH' AND P.ACTIVITY_NAME = 'CLOSE_WAIT_FOR_L' 
AND WAS.ACTIVITY_STATUS = 'NOTIFIED' AND WAS.ITEM_TYPE = 'OEOH' 
AND NOT EXISTS (SELECT /*+ FULL(a) parallel(a,8) */ 1 FROM OE_ORDER_LINES_ALL a WHERE HEADER_ID = H.HEADER_ID AND OPEN_FLAG = 'Y' );


Select /*+ FULL(a) parallel(a,8) */ count(*) from wf_items a
where item_type = 'OEOL' and end_date is null;

Select /*+ FULL(a) parallel(a,8) */ count(*) from wf_items a
where item_type = 'OEOL' and end_date is not null;

SELECT /*+ FULL(sta) parallel(sta,8) FULL(wfi) parallel(wfi,8) */ sta.item_type, sta.item_key, COUNT(*),
TO_CHAR(wfi.begin_date, 'YYYY-MM-DD'),
TO_CHAR(wfi.end_date, 'YYYY-MM-DD'), wfi.user_key
FROM wf_item_activity_statuses_h sta,
wf_items wfi WHERE sta.item_type = wfi.item_type AND sta.item_key = wfi.item_key
AND wfi.item_type LIKE 'OEOL'
GROUP BY sta.item_type, sta.item_key,
wfi.USER_KEY, TO_CHAR(wfi.begin_date, 'YYYY-MM-DD'),
TO_CHAR(wfi.end_date, 'YYYY-MM-DD')
HAVING COUNT(*) > 500
ORDER BY COUNT(*) DESC;

---Cancelled lines with the open_flag = Y and workflow active.
--select /*+ FULL(ol) parallel(ol,8) FULL(wi) parallel(wi,8) */ ol.line_id, wi.end_date, ol.flow_status_code
select /*+ FULL(ol) parallel(ol,8) FULL(wi) parallel(wi,8) */ count(*)
from oe_order_lines_all ol,
                wf_items wi
where wi.item_type='OEOL'
and wi.item_key=to_char(ol.line_id)
and ol.open_flag='Y'
and ol.cancelled_flag='Y'
and ol.ordered_quantity=0
and ol.cancelled_quantity>0
and wi.end_date IS null;

---Closed lines with the open_flag = Y and workflow active
--select /*+ FULL(ol) parallel(ol,8) FULL(wi) parallel(wi,8) */ ol.line_id, wi.end_date, ol.flow_status_code
select /*+ FULL(ol) parallel(ol,8) FULL(wi) parallel(wi,8) */ count(*)
from oe_order_lines_all ol,
                wf_items wi
where wi.item_type='OEOL'
and wi.item_key=to_char(ol.line_id)
and ol.open_flag='Y'
and ol.cancelled_flag='N'
and ol.ordered_quantity>0
and ol.cancelled_quantity=0
and ol.flow_status_code = 'CLOSED'
and wi.end_date IS null;

SELECT /*+ FULL(sta) parallel(sta,8) FULL(wfi) parallel(wfi,8) */ sta.item_type, sta.item_key, COUNT(*),
TO_CHAR(wfi.begin_date, 'YYYY-MM-DD'),
TO_CHAR(wfi.end_date, 'YYYY-MM-DD'), wfi.user_key
FROM wf_item_activity_statuses_h sta,
wf_items wfi WHERE sta.item_type = wfi.item_type AND sta.item_key = wfi.item_key
AND wfi.item_type LIKE 'OEOL'
GROUP BY sta.item_type, sta.item_key,
wfi.USER_KEY, TO_CHAR(wfi.begin_date, 'YYYY-MM-DD'),
TO_CHAR(wfi.end_date, 'YYYY-MM-DD')
HAVING COUNT(*) > 500
ORDER BY COUNT(*) DESC;

select /*+ FULL(wfi) parallel(wfi,8) */ wfi.user_key from wf_items wfi 
where wfi.user_key like 'Sales Order 2529478%';

select count(*), ala from (
select /*+ FULL(wfi) parallel(wfi,8) */ substr(wfi.user_key, 1, 21) ala
from wf_items wfi where wfi.item_type LIKE 'OEOL'
) group by ala order by count(*) desc
;

select * from wf_items wfi where wfi.user_key is null and ;

SELECT count(*)
	FROM WF_ITEM_ACTIVITY_STATUSES WAS,
	  WF_PROCESS_ACTIVITIES P,
	  OE_ORDER_HEADERS_ALL H
	WHERE TO_NUMBER(WAS.ITEM_KEY) = H.HEADER_ID
	AND   WAS.PROCESS_ACTIVITY = P.INSTANCE_ID
	AND   P.ACTIVITY_ITEM_TYPE = 'OEOH'
	AND   P.ACTIVITY_NAME = 'CLOSE_WAIT_FOR_L'
	AND   WAS.ACTIVITY_STATUS = 'NOTIFIED'
	AND   WAS.ITEM_TYPE = 'OEOH'
	AND   NOT EXISTS ( SELECT /*+ NO_UNNEST */ 1
			  FROM   OE_ORDER_LINES_ALL
			  WHERE  HEADER_ID = TO_NUMBER(WAS.ITEM_KEY)
			  AND    OPEN_FLAG = 'Y');


SELECT /*+ FULL(a) parallel(a,8) */ count(*)
FROM wf_items a
WHERE item_type in ('OEOL','OEOH') 
and begin_date < sysdate - 90
;

select c.item_type child, decode(c.end_date,null,'OPEN','CLOSED') c_status, 
c.parent_item_type parent, decode(c.parent_item_type,null,'NOPARENT', 
decode(p.end_date,null,'OPEN','CLOSED')) p_status, 
count(*) 
from wf_items p , wf_items c 
where p.item_type(+) = c.parent_item_type 
and p.item_key(+) = c.parent_item_key 
and (c.begin_date < to_date('01-JUN-2014','DD-MON-YYYY') or p.begin_date < to_date('01-JUN-2014','DD-MON-YYYY')) 
group by c.item_type, decode(c.end_date,null,'OPEN','CLOSED'), 
c.parent_item_type , decode(c.parent_item_type,null,'NOPARENT', 
decode(p.end_date,null,'OPEN','CLOSED')) 
order by c.item_type , c.parent_item_type; 

select /*+ FULL(a) parallel(a,8) */ corrid,q_name,count(*) from WF_BPEL_QTAB a group by corrid,q_name; 

select /*+ FULL(a) parallel(a,8) */ item_type,activity_status,count(*) 
from wf_item_activity_statuses a
group by item_type,activity_status
order by count(*) desc;

select * from DBA_HIST_SEG_STAT;

SELECT  * FROM  (
    select
      to_char(sn.end_interval_time, 'DD/MM/YYYY')              mydate,
      round(sum(st.space_used_total)/1024/1024, 2)             "Space used since startup (MB)",
      avg(sg.bytes)/1024/1024                                  "Total Object Size (MB)",
      round(sum(st.space_used_total) / sum(sg.bytes) * 100, 2) "% Disk Usage since startup"  
    FROM
      dba_hist_snapshot sn,
      dba_hist_seg_stat st,
      dba_objects o,
      dba_segments sg
    WHERE
      sn.begin_interval_time  > trunc(sysdate) - &days_back
      and sn.snap_id        = st.snap_id
      and o.object_id       = st.obj#
      and o.owner           = sg.owner
      and o.object_name     = sg.segment_name
      and sg.segment_name   = '&segment_name'
    group by to_char(sn.end_interval_time, 'DD/MM/YYYY')
) order by mydate; 

@o wf_queue_temp_evt1_table
@o wf_queue_temp_jms_table
@temp

select * from dba_lobs where segment_name='SYS_LOB0009030171C00036$$';
select * from dba_lobs where segment_name='SYS_LOB0026113678C00013$$';

select count(*) from WF_QUEUE_TEMP_EVT_TABLE;
select count(*) from WF_BPEL_QTAB;

select * from WF_BPEL_QTAB;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(enq_time, 'YEAR') year, count(*) from WF_BPEL_QTAB a 
group by trunc(enq_time, 'YEAR') order by trunc(enq_time, 'YEAR') desc;
select /*+ FULL(a) parallel(a,8) */ trunc(enq_time, 'YEAR') year, count(*) from WF_QUEUE_TEMP_EVT_TABLE a 
group by trunc(enq_time, 'YEAR') order by trunc(enq_time, 'YEAR') desc;

select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0009030171C00036$$';
select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0026113678C00013$$';
select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0002693761C00040$$';
set linesize 300
@tbs

@o WF_QUEUE_TEMP_EVT_TABLE
@o wf_queue_temp_jms_table
select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'WF_QUEUE_TEMP_JMS_TABLE';
select USERNAME, TEMPORARY_TABLESPACE, DEFAULT_TABLESPACE from dba_users where username='APPS';

select * from dba_tables where table_name in ('WF_QUEUE_TEMP_EVT_TABLE','WF_QUEUE_TEMP_JMS_TABLE');



select * from dba_lobs where table_name='WF_QUEUE_TEMP_EVT_TABLE';
select /*+ FULL(a) parallel(a,8) */ count(*) from WF_QUEUE_TEMP_EVT_TABLE a;
-- 20370000
select * from dba_lobs where table_name='WF_QUEUE_TEMP_JMS_TABLE';
select count(*) from WF_QUEUE_TEMP_JMS_TABLE;

APPS	WF_QUEUE_TEMP_EVT_TABLE	"USER_DATA"."PARAMETER_LIST"	SYS_LOB0026117050C00010$$
APPS	WF_QUEUE_TEMP_EVT_TABLE	"USER_DATA"."EVENT_DATA"	SYS_LOB0026117050C00013$$
select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'SYS_LOB0026117050C00013$$';
select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0026117050C00010$$';
select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'SYS_LOB0026113670C00014$$';
select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'SYS_LOB0026113670C00017$$';

select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'WF_BPEL_QTAB';
--33517

--org
select * from dba_lobs where table_name='WF_BPEL_QTAB';
select /*+ FULL(a) parallel(a,8) */ count(*) from WF_BPEL_QTAB a;
--19756998
select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments 
where segment_name = 'SYS_LOB0009030171C00036$$';
-- 356453
select segment_name ,bytes/1024/1024 from dba_segments where segment_name like '%BPEL%';

select /*+ FULL(p) parallel(p,8) FULL(c) parallel(c,8) */ c.item_type child, decode(c.end_date,null,'OPEN','CLOSED') c_status, 
c.parent_item_type parent, decode(c.parent_item_type,null,'NOPARENT', 
decode(p.end_date,null,'OPEN','CLOSED')) p_status, 
count (*) 
from wf_items p , wf_items c 
where p.item_type(+) = c.parent_item_type 
and p.item_key(+) = c.parent_item_key 
and (c.begin_date < to_date('01-JUN-2014','DD-MON-YYYY') or p.begin_date < to_date('01-JUN-2014','DD-MON-YYYY')) 
group by c.item_type, decode(c.end_date,null,'OPEN','CLOSED'), 
c.parent_item_type , decode(c.parent_item_type,null,'NOPARENT', 
decode(p.end_date,null,'OPEN','CLOSED')) 
order by c.item_type , c.parent_item_type; 

select /*+ FULL(a) parallel(a,8) */ count(*)
from wf_items a
where end_date is null
and begin_date < sysdate - 365;

select * from XXXX_APPS.XXXX_WF_ACTIVITIES_LOG order by creation_date desc;

select * from dba_lobs where segment_name='SYS_LOB0009030171C00036$$';

select * from dba_lobs where segment_name='SYS_LOB0019483571C00002$$';

select segment_name, round((bytes)/1024/1024) SIZE_MB from dba_segments 
where segment_name = 'SYS_LOB0019483571C00002$$';

select count(*) from XX_SOA_DEBUG_LOG;

select * from dba_tables where table_name in ('CMX_LOG_ERROS');

@i CMX_LOG_ERROS

select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('CMX_LOG_ERROS','CMX_LOG_ERROS_PK','CMX_EVENTOS_LOGERROS_IDX');

select * from ECOMEX.CMX_LOG_ERROS where LOG_ERROS_ID = 1104996884;

select * from ORDER_CHECKLIST_ATTACHMENTS;

alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(change_date, 'YEAR'), count(*) 
from ORDER_CHECKLIST_ATTACHMENTS a group by trunc(change_date, 'YEAR')
order by trunc(change_date, 'YEAR') desc;

@i ORDER_CHECKLIST_ATTACHMENTS
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('ORDER_CHECKLIST_ATTACHMENTS','ORDER_CHECKLIST_ATTACH_N99','SYS_C0024246112','SYS_LOB0019483571C00002$$');

select * from ORDER_LINE_LOG ;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(send_date, 'YEAR'), count(*) 
from ORDER_LINE_LOG a group by trunc(send_date, 'YEAR')
order by trunc(send_date, 'YEAR') desc;

@i ORDER_LINE_LOG
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('ORDER_LINE_LOG','ORDER_LINE_LOG_N1','XXXX_ORDER_LINE_LOG_N99');

select * from MTL_MATERIAL_TRANSACTIONS;
select /*+ FULL(a) parallel(a,8) */ trunc(creation_date, 'YEAR'), count(*) 
from MTL_MATERIAL_TRANSACTIONS a group by trunc(creation_date, 'YEAR')
order by trunc(creation_date, 'YEAR') desc;

@i MTL_MATERIAL_TRANSACTIONS
select distinct index_name from all_ind_columns where table_name=upper('MTL_MATERIAL_TRANSACTIONS') order by index_name;

select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('MTL_MATERIAL_TRANSACTIONS','XXXX_MTL_MATL_TRANS_N95','XXXX_MTL_MATL_TRANS_N96','XXXX_MTL_MATL_TRANS_N98','XXXX_MTL_MATL_TRANS_N99','MTL_MATERIAL_TRANSACTIONS_N1','MTL_MATERIAL_TRANSACTIONS_N10','MTL_MATERIAL_TRANSACTIONS_N11','MTL_MATERIAL_TRANSACTIONS_N12','MTL_MATERIAL_TRANSACTIONS_N13','MTL_MATERIAL_TRANSACTIONS_N14','MTL_MATERIAL_TRANSACTIONS_N15','MTL_MATERIAL_TRANSACTIONS_N16','MTL_MATERIAL_TRANSACTIONS_N17','MTL_MATERIAL_TRANSACTIONS_N18','MTL_MATERIAL_TRANSACTIONS_N19','MTL_MATERIAL_TRANSACTIONS_N2','MTL_MATERIAL_TRANSACTIONS_N20','MTL_MATERIAL_TRANSACTIONS_N21','MTL_MATERIAL_TRANSACTIONS_N22','MTL_MATERIAL_TRANSACTIONS_N23','MTL_MATERIAL_TRANSACTIONS_N24','MTL_MATERIAL_TRANSACTIONS_N25','MTL_MATERIAL_TRANSACTIONS_N26','MTL_MATERIAL_TRANSACTIONS_N27','MTL_MATERIAL_TRANSACTIONS_N28','MTL_MATERIAL_TRANSACTIONS_N3','MTL_MATERIAL_TRANSACTIONS_N4','MTL_MATERIAL_TRANSACTIONS_N5','MTL_MATERIAL_TRANSACTIONS_N6','MTL_MATERIAL_TRANSACTIONS_N7','MTL_MATERIAL_TRANSACTIONS_N8','MTL_MATERIAL_TRANSACTIONS_N9','MTL_MATERIAL_TRANSACTIONS_U1','MTL_MATERIAL_TRANSACTIONS_U2','MTL_MATERIAL_TRANSACTIONS_UPDR','MTL_MTL_TRXN_WSM2102605');

@i WF_BPEL_QTAB
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('WF_BPEL_QTAB','SYS_LOB0009030171C00036$$','SYS_C008872847');

select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('WF_ITEM_ATTRIBUTE_VALUES','WF_ITEM_ATTRIBUTE_VALUES_N1','WF_ITEM_ATTRIBUTE_VALUES_PK');

@i FND_LOBS
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('FND_LOBS','FND_LOBS_U1','FND_LOBS_N1','FND_LOBS_CTX');

@i XLA_AE_LINES
select distinct index_name from all_ind_columns where table_name=upper('XLA_AE_LINES') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('XLA_AE_LINES','XLA_AE_LINES_N1','XLA_AE_LINES_N4','XLA_AE_LINES_N5','XLA_AE_LINES_N99','XLA_AE_LINES_U1');
select * from XLA_AE_LINES;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(creation_date, 'YEAR'), count(*) 
from XLA_AE_LINES a group by trunc(creation_date, 'YEAR')
order by trunc(creation_date, 'YEAR') desc;

@i XLA_DISTRIBUTION_LINKS  
select distinct index_name from all_ind_columns where table_name=upper('XLA_DISTRIBUTION_LINKS') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('XLA_DISTRIBUTION_LINKS','XLA_DISTRIBUTION_LINKS_N1','XLA_DISTRIBUTION_LINKS_N3','XLA_DISTRIBUTION_LINKS_U1');

@o MTL_SYSTEM_ITEMS_B
select * from MTL_SYSTEM_ITEMS_B;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(creation_date, 'YEAR'), count(*) 
from MTL_SYSTEM_ITEMS_B a group by trunc(creation_date, 'YEAR')
order by trunc(creation_date, 'YEAR') desc;
select distinct index_name from all_ind_columns where table_name=upper('MTL_SYSTEM_ITEMS_B') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('MTL_SYSTEM_ITEMS_B','XXXX_MTL_SYSTEM_ITEMS_B_N96','XXXX_MTL_SYSTEM_ITEMS_B_N97','MTL_SYSTEM_ITEMS_B_N1','MTL_SYSTEM_ITEMS_B_N10','MTL_SYSTEM_ITEMS_B_N11','MTL_SYSTEM_ITEMS_B_N12','MTL_SYSTEM_ITEMS_B_N13','MTL_SYSTEM_ITEMS_B_N14','MTL_SYSTEM_ITEMS_B_N15','MTL_SYSTEM_ITEMS_B_N16','MTL_SYSTEM_ITEMS_B_N17','MTL_SYSTEM_ITEMS_B_N2','MTL_SYSTEM_ITEMS_B_N3','MTL_SYSTEM_ITEMS_B_N4','MTL_SYSTEM_ITEMS_B_N5','MTL_SYSTEM_ITEMS_B_N6','MTL_SYSTEM_ITEMS_B_N7','MTL_SYSTEM_ITEMS_B_N8','MTL_SYSTEM_ITEMS_B_N9','MTL_SYSTEM_ITEMS_B_U1');

@i ECX_DOCLOGS
select * from dba_lobs where segment_name='SYS_LOB0001518322C00019$$';
SYS_LOB0001518322C00019$$
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('SYS_LOB0001518322C00019$$','ECX_DOCLOGS','ECX_DOCLOGS_N4','ECX_DOCLOGS_N1','ECX_DOCLOGS_N2','ECX_DOCLOGS_N3','ECX_DOCLOGS_U1');
select * from ECX_DOCLOGS;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(time_stamp, 'YEAR'), count(*) 
from ECX_DOCLOGS a group by trunc(time_stamp, 'YEAR')
order by trunc(time_stamp, 'YEAR') desc;


@o XXXX_PP_FADB_COPY_ARCHIVE
@i WRH$_ACTIVE_SESSION_HISTORY
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('WRH$_ACTIVE_SESSION_HISTORY','WRH$_ACTIVE_SESSION_HISTORY_PK');

@i MTL_TRANSACTION_ACCOUNTS 
select distinct index_name from all_ind_columns where table_name=upper('MTL_TRANSACTION_ACCOUNTS') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('MTL_TRANSACTION_ACCOUNTS','MTL_TRANSACTION_ACCOUNTS_N1','MTL_TRANSACTION_ACCOUNTS_N2','MTL_TRANSACTION_ACCOUNTS_N3','MTL_TRANSACTION_ACCOUNTS_N4','MTL_TRANSACTION_ACCOUNTS_N5','MTL_TRANSACTION_ACCOUNTS_N6','MTL_TRANSACTION_ACCOUNTS_N7');
select * from MTL_TRANSACTION_ACCOUNTS ;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(creation_date, 'YEAR'), count(*) 
from MTL_TRANSACTION_ACCOUNTS a group by trunc(creation_date, 'YEAR')
order by trunc(creation_date, 'YEAR') desc;

@i GL_JE_LINES_OLD

@i CST_PERIOD_CLOSE_SUMMARY 
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('CST_PERIOD_CLOSE_SUMMARY','CST_PERIOD_CLOSE_SUMMARY_N1','CST_PERIOD_CLOSE_SUMMARY_N2');
select * from CST_PERIOD_CLOSE_SUMMARY;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(creation_date, 'YEAR'), count(*) 
from CST_PERIOD_CLOSE_SUMMARY a group by trunc(creation_date, 'YEAR')
order by trunc(creation_date, 'YEAR') desc;

@i OE_ORDER_LINES_ALL
select distinct index_name from all_ind_columns where table_name=upper('OE_ORDER_LINES_ALL') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('OE_ORDER_LINES_ALL','XXXX_OE_ORDER_LINES_ALL_N93','XXXX_OE_ORDER_LINES_ALL_N94','XXXX_OE_ORDER_LINES_ALL_N95','XXXX_OE_ORDER_LINES_ALL_N96','XXXX_OE_ORDER_LINES_ALL_N97','XXXX_OE_ORDER_LINES_ALL_N98','XXXX_OE_ORDER_LINES_N94','XXXX_ONT_ORDER_LINES_N99','XX_OE_ORDER_LINES_ALL_N89','OE_ORDER_LINES_N1','OE_ORDER_LINES_N10','OE_ORDER_LINES_N11','OE_ORDER_LINES_N12','OE_ORDER_LINES_N13','OE_ORDER_LINES_N14','OE_ORDER_LINES_N15','OE_ORDER_LINES_N16','OE_ORDER_LINES_N17','OE_ORDER_LINES_N18','OE_ORDER_LINES_N19','OE_ORDER_LINES_N2','OE_ORDER_LINES_N20','OE_ORDER_LINES_N3','OE_ORDER_LINES_N5','OE_ORDER_LINES_N6','OE_ORDER_LINES_N7','OE_ORDER_LINES_N9','OE_ORDER_LINES_U1');
select * from ONT.OE_ORDER_LINES_ALL;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(tax_date, 'YEAR'), count(*) 
from OE_ORDER_LINES_ALL a group by trunc(tax_date, 'YEAR')
order by trunc(tax_date, 'YEAR') desc;

@i GL_BALANCES
select * from GL_BALANCES;
select distinct index_name from all_ind_columns where table_name=upper('GL_BALANCES') order by index_name;
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in 
('GL_BALANCES','XXXX_GL_BALANCES_N99','XXXX_GL_BALANCES_N99','GL_BALANCES_N1','GL_BALANCES_N2','GL_BALANCES_N3','GL_BALANCES_N4');
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(last_update_date, 'YEAR'), count(*) 
from GL_BALANCES a group by trunc(last_update_date, 'YEAR')
order by trunc(last_update_date, 'YEAR') desc;

select * from dba_tables where owner = 'PREPRO';
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in (select table_name from dba_tables where owner = 'PREPRO' );

select * from dba_tables where table_name like '%_OLD';
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in (select table_name from dba_tables where table_name like '%_OLD' );
select round(sum(bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name in ('IC_CTMS_CLS_OLD','SO_LOOKUP_TYPES_OLD','PAY_PDT_BATCH_EXCEPTIONS_OLD','IC_TAXN_CLS_OLD','IC_COST_CLS_OLD','IC_FRGT_CLS_OLD','RA_SALESREPS_ALL_OLD','CR_SQDT_CLS_OLD','WRI$_ALERT_THRESHOLD','RG_LOOKUPS_OLD','RCV_ROUTING_HEADERS_OLD','XXXX_GAB_ITEM_STAXX_OLD','IC_PRCE_CLS_OLD','AR_LOOKUP_TYPES_OLD','JA_IN_INSTALL_CHECK_INFO_OLD','CS_COUNTER_PROP_VALUES_OLD','IC_INVN_CLS_OLD','AR_LOC_COMBINATIONS_OLD','PAY_PDT_BATCH_CHECKS_OLD','PAY_JP_PRE_TAX_OLD','PAY_PDT_LINE_ERRORS_OLD','CS_COUNTERS_OLD','PAY_PDT_BATCH_HEADERS_OLD','IC_SHIP_CLS_OLD','CS_SYSTEMS_ALL_B_OLD','PS_PLNG_CLS_OLD','PA_PROJECT_PLAYERS_OLD','PA_LOOKUPS_OLD','AP_EXPENSE_REPORTS_OLD','QC_HRES_MST_OLD','QC_ACTN_MST_OLD','IC_PRCH_CLS_OLD','AR_LOCATION_VALUES_OLD','AP_LOOKUP_CODES_OLD','AS_LOOKUPS_OLD','SO_LOOKUPS_OLD','AP_PAYMENT_KEY_IND_OLD','CN_LOOKUPS_ALL_OLD','AP_INVOICE_KEY_IND_OLD','AR_LOOKUPS_OLD','CS_CUSTOMER_PRODUCTS_ALL_OLD','CS_CUST_PRODUCT_STATUSES_OLD','FND_USER_RESP_GROUPS_OLD','CN_LOOKUP_TYPES_ALL_OLD','CS_COUNTER_VALUES_OLD','CS_SYSTEMS_ALL_TL_OLD','WF_LOCAL_ROLES_OLD','IC_STOR_CLS_OLD','CS_CTR_ASSOCIATIONS_OLD','PAY_ACTION_PARAMETERS_OLD','AP_VENDOR_KEY_IND_OLD','CE_LOOKUPS_OLD','CS_COUNTER_PROPERTIES_OLD','AP_LOOKUP_TYPES_OLD','XXXX_FIN_STAT_DRL_DOWN_BKPHOLD','AS_LOOKUP_TYPES_OLD','PAY_PDT_BATCH_LINES_OLD','IC_ALLC_CLS_OLD','IC_SALE_CLS_OLD','XXXX_FIN_STAT_DRILL_DOWN_HOLD','PA_LOOKUP_TYPES_OLD','WF_LOCAL_USER_ROLES_OLD','XXXX_GAB_CHANGED_RECORDS_OLD','IMP_PO_CRONOGRAMA_OLD','AR_LOCATION_RATES_OLD','PO_ACCRUAL_RECONCILE_TEMP_OLD','IC_GLED_CLS_OLD','GL_LOOKUPS_OLD','FND_USER_RESPONSIBILITY_OLD','NACIONALIZACAO_DE_OLD');


@i WF_BPEL_QTAB
select * from WF_BPEL_QTAB;
select * from WF_BPEL_QTAB ;
alter session set NLS_DATE_FORMAT = "YYYY";
select /*+ FULL(a) parallel(a,8) */ trunc(enq_time, 'YEAR'), count(*) 
from WF_BPEL_QTAB a group by trunc(enq_time, 'YEAR')
order by trunc(enq_time, 'YEAR') desc;

@o WF_BPEL_Q
select * from WF_BPEL_Q;

select * from dba_queues where name like '%BPEL%';
OWNER	NAME	QUEUE_TABLE	QID	QUEUE_TYPE	MAX_RETRIES	RETRY_DELAY	ENQUEUE_ENABLED	DEQUEUE_ENABLED	RETENTION	USER_COMMENT	NETWORK_NAME
APPS	AQ$_WF_BPEL_QTAB_E	WF_BPEL_QTAB	9030191	EXCEPTION_QUEUE	0	0	  NO  	  NO  	0	exception queue	
APPS	WF_BPEL_Q	WF_BPEL_QTAB	9030193	NORMAL_QUEUE	5	0	  YES  	  YES  	86400		

select * from aq$wf_bpel_qtab_s;

select /*+ FULL(a) parallel(a,8) */ state, count(*) 
from WF_BPEL_QTAB a group by state
order by state desc;



select * from AQ$WF_BPEL_QTAB where rownum < 5;
-- takes forever, errors out with cannot extend TEMP
