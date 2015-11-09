REM HEADER
REM   $Header: atg_supp_fnd_purge.sql v5.0 AXGONZAL $
REM   
REM MODIFICATION LOG:
REM 30-DEC-2008 axgonzal included summary query
REM 30-DEC-2008 gggrant Included totals and removed 
REM                     some categories as data in wf_item_types
REM 31-DEC-2008		Added column status meanings
REM 02-JAN-2009		Added Unref Notifications and changed syntax to
REM			wf_purge.total so wf_purge.directory will be called and 
REM			did some minor syntax clean up so it can be copied to run.
REM 05-JAN-2009		Added wf_purge.totalperm for permanent persistence and reorg
REM			summary table so high purgeable are listed first.
REM			Added a color coded informational table for after purge.
REM			
REM   atg_supp_fnd_purge.sql
REM     
REM   	This script was created to collect the required information
REM   	to determine the number of purgeable records
REM
REM   How to run it?
REM   
REM   sqlplus apps/<password>
REM
REM   @atg_supp_fnd_purge.sql
REM
REM  Parameter:
REM
REM   
REM   
REM   Output file 
REM   
REM  wf_purge.html
REM
REM
REM   Created: Nov 11nd, 2008
REM   Last Updated: Jan 5th, 2008


set arraysize 1
set heading off
set feedback off
set verify off
SET CONCAT ON
SET CONCAT .

set lines 120
set pages 9999

def outputfile = "wf_purge.html"
spool &&outputfile

prompt <FONT SIZE=3 FACE=ARIAL>

alter session set NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';



prompt </FONT>

prompt <HTML>
prompt <HEAD>
prompt <TITLE>Queries to determine elegible items to be purged </TITLE>
prompt <STYLE TYPE="text/css">
prompt <!-- TD {font-size: 8pt; font-family: arial; font-style: normal} -->
prompt </STYLE>
prompt </HEAD>
prompt <BODY>


prompt <P><P>
prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=6 BGCOLOR==BLUE><FONT COLOR=WHITE FACE=ARIAL>
prompt <B>Workflow Process Information To Determine Data Growth
prompt <BR>Quick Links to Tables</B></TD></TR>
prompt <TR>
prompt <TD><A HREF="#wfit">Summary By Item Type</A></TD>
prompt <TD><A HREF="#wfitt">Summary TOTALS By Status</A></TD>
prompt <TD><A HREF="#wfiav">WF_ITEM_ATTRIBUTE_VALUES</A></TD>
prompt <TD><A HREF="#wfiavt">WF_ITEM_ATTRIBUTE_VALUES Total</A></TD>
prompt <TD><A HREF="#wfas">WF_ITEM_ACTIVITY_STATUSES</A></TD>
prompt <TD><A HREF="#wfast">WF_ITEM_ACTIVITY_STATUSES Totals</A></TD>
prompt </TR>
prompt <TR>
prompt <TD><A HREF="#wfierropen">Open WFERROR in WF_ITEMS</A></TD>
prompt <TD><A HREF="#wfierrclosed">Closed WFERROR in WF_ITEMS</A></TD>
prompt <TD><A HREF="#wfexec">Purge Workflow Process API</A></TD>
prompt <TD><A HREF="#wfnunref">Closed/Purgeable Unreferenced Notifications</A></TD>
prompt <TD><A HREF="#wfntfexec"> PURGE Unreferenced Notifications API</A></TD>
prompt <TD><A HREF="#pkg">PACKAGE_VERSIONS</A></TD>
prompt </TR>
prompt </TABLE><P><P>

prompt </FONT>


REM
REM ******* WF_ITEM_TYPES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfitt"> Meaning of Workflow Statuses</A></B></TD></TR>
prompt <TR>
prompt <TD><B>ACTIVE</B></TD>
prompt <TD><B>COMPLETED</B></TD>
prompt <TD><B>PURGEABLE</B></TD>
prompt <TD><B>ERRORED</B></TD>
prompt <TD><B>DEFERRED</B></TD>
prompt <TD><B>SUSPENDED</B></TD>
select  
'<TR><TD><B><font color=brown face=arial>Open Workflow Item Types</B></TD>'||chr(10)||
'<TD><B><font color=brown face=arial>Closed Workflow Item Types</B></TD>'||chr(10)||
'<TD><B><font color=brown face=arial>Workflows that can be purged</B></TD>'||chr(10)||
'<TD><B><font color=brown face=arial>Workflows that are in error</B></TD>'||chr(10)||
'<TD><B><font color=brown face=arial>Workflows deferred to the background engine</B></TD>'||chr(10)||
'<TD><B><font color=brown face=arial>Workflows that are suspended</B></TD></TR>'
from (select 1 from dual where rownum < 7);
prompt </TABLE><P><P>


REM
REM ******* WF_ITEM_TYPES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=10 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfit"> SUMMARY Of Workflow Processes By Item Type</A></B></TD></TR>
prompt <TR>
prompt <TD><B>ITEM_NAME</B></TD>
prompt <TD><B>DISPLAY_NAME</B></TD>
prompt <TD><B>PERSISTENCE_TYPE</B></TD>
prompt <TD><B>PERSISTENCE_DAYS</B></TD>
prompt <TD><B>ACTIVE</B></TD>
prompt <TD><B>COMPLETED</B></TD>
prompt <TD><B>PURGEABLE</B></TD>
prompt <TD><B>ERRORED</B></TD>
prompt <TD><B>DEFERRED</B></TD>
prompt <TD><B>SUSPENDED</B></TD>
select  
'<TR><TD>'||WIT.NAME||'</TD>'||chr(10)||
'<TD>'||DISPLAY_NAME||'</TD>'||chr(10)||
'<TD>'||PERSISTENCE_TYPE||'</TD>'||chr(10)||
'<TD>'||PERSISTENCE_DAYS||'</TD>'||chr(10)||
'<TD>'||NUM_ACTIVE||'</TD>'||chr(10)||
'<TD>'||NUM_COMPLETE||'</TD>'||chr(10)||
'<TD>'||NUM_PURGEABLE||'</TD>'||chr(10)||
'<TD>'||NUM_ERROR||'</TD>'||chr(10)||
'<TD>'||NUM_DEFER||'</TD>'||chr(10)||
'<TD>'||NUM_SUSPEND||'</TD></TR>'
from wf_item_types    wit,
     wf_item_types_tl wtl
where wit.name like ('%')
AND wtl.name = wit.name
AND wtl.language = userenv('LANG')
AND wit.NUM_ACTIVE is not NULL
AND wit.NUM_ACTIVE <>0 
order by NUM_PURGEABLE desc;
prompt </TABLE><P><P>

REM
REM ******* WF_ITEM_TYPES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfitt"> TOTALS By Status</A></B></TD></TR>
prompt <TR>
prompt <TD><B>ACTIVE</B></TD>
prompt <TD><B>COMPLETED</B></TD>
prompt <TD><B>PURGEABLE</B></TD>
prompt <TD><B>ERRORED</B></TD>
prompt <TD><B>DEFERRED</B></TD>
prompt <TD><B>SUSPENDED</B></TD>
select  
'<TR><TD>'||SUM(NUM_ACTIVE)||'</TD>'||chr(10)||
'<TD>'||SUM(NUM_COMPLETE)||'</TD>'||chr(10)||
'<TD>'||SUM(NUM_PURGEABLE)||'</TD>'||chr(10)||
'<TD>'||SUM(NUM_ERROR)||'</TD>'||chr(10)||
'<TD>'||SUM(NUM_DEFER)||'</TD>'||chr(10)||
'<TD>'||SUM(NUM_SUSPEND)||'</TD></TR>'
from wf_item_types    wit
where wit.NUM_ACTIVE is not NULL
AND wit.NUM_ACTIVE <>0;
prompt </TABLE><P><P>



REM
REM ******* WF_ITEM_ATTRIBUTE_VALUES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfiav">WF_ITEM_ATTRIBUTE_VALUES Table By Item Types</A></B></TD></TR>
prompt <TR>
prompt <TD><B>ITEM_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  /*+ parallel(WFIAV,8) */ 
'<TR><TD>'||ITEM_TYPE||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from WF_ITEM_ATTRIBUTE_VALUES WFIAV
group by item_type
order by COUNT(*) desc;
prompt </TABLE><P><P>

REM
REM ******* WF_ITEM_ATTRIBUTE_VALUES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfiavt">WF_ITEM_ATTRIBUTE_VALUES Table Total</A></B></TD></TR>
prompt <TR>
prompt <TD><B>COUNT</B></TD>
select /*+ FULL(WFIAV) parallel(WFIAV,8) */
'<TR><TD>'||COUNT(*)||'</TD></TR>'
from WF_ITEM_ATTRIBUTE_VALUES WFIAV;
prompt </TABLE><P><P>

REM
REM ******* WF_ITEM_ACTIVITY_STATUSES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfas">WF_ITEM_ACTIVITY_STATUSES Table By Item Types</A></B></TD></TR>
prompt <TR>
prompt <TD><B>ITEM_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  /*+ parallel(WFIAS,8) */ 
'<TR><TD>'||ITEM_TYPE||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from WF_ITEM_ACTIVITY_STATUSES WFIAS
group by item_type
order by COUNT(*) desc;
prompt </TABLE><P><P>


REM
REM ******* WF_ITEM_ACTIVITY_STATUSES *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfast">WF_ITEM_ACTIVITY_STATUSES Table Totals</A></B></TD></TR>
prompt <TR>
prompt <TD><B>COUNT</B></TD>
select /*+ parallel(WFIAS,8) */ 
'<TR><TD>'||COUNT(*)||'</TD></TR>'
from WF_ITEM_ACTIVITY_STATUSES WFIAS;
prompt </TABLE><P><P>


REM
REM ******* OPEN WFERROR from WF_ITEMS *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfierropen">Open WFERROR in WF_ITEMS Table</A></B></TD></TR>
prompt <TR>
prompt <TD><B>PARENT_ITEM_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  
'<TR><TD>'||decode(PARENT_ITEM_TYPE,null,'NOPARENT',PARENT_ITEM_TYPE)||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from wf_items
where item_type = 'WFERROR'
and end_date is null
group by decode(PARENT_ITEM_TYPE,null,'NOPARENT',PARENT_ITEM_TYPE)
order by COUNT(*) desc;
prompt </TABLE><P><P>


REM
REM ******* CLOSED WFERROR from WF_ITEMS *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfierrclosed">Closed WFERROR in WF_ITEMS Table</A></B></TD></TR>
prompt <TR>
prompt <TD><B>PARENT_ITEM_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  
'<TR><TD>'||decode(PARENT_ITEM_TYPE,null,'NOPARENT',PARENT_ITEM_TYPE)||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from wf_items
where item_type = 'WFERROR'
and end_date is not null
group by decode(PARENT_ITEM_TYPE,null,'NOPARENT',PARENT_ITEM_TYPE)
order by COUNT(*) desc;
prompt </TABLE><P><P>


REM
REM ******* Purging closed items with Purge API *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=12 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfexec"> Purge  Temporary Persistence Workflow Processes API </A></B></TD></TR>
select '<TR><TD>exec WF_PURGE.TOTAL('''|| wit.name ||''',NULL,SYSDATE,FALSE,FALSE);' purge
from wf_item_types    wit,
     wf_item_types_tl wtl
where wit.name like ('%')
AND wtl.name = wit.name
AND wtl.language = userenv('LANG')
AND num_purgeable <> 0
AND PERSISTENCE_TYPE='TEMP'
order by num_purgeable desc; 
prompt </TABLE><P><P>

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=2 BGCOLOR=Beige><font color=maroon face=arial>
prompt Run the <B>Workflow Work Items Statistics Concurrent Program (FNDWFWITSTATCC)</B><br>
prompt to refresh the workflow process tables after purging to confirm that the purgeable<br> 
prompt items were purged.</TD></TR>
prompt </TABLE><P><P>

REM
REM ******* Purging closed items with Purge API *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=12 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfexec"> Purge  Permanent Persistence Workflow Processes API </A></B></TD></TR>
select '<TR><TD>exec WF_PURGE.TOTALPERM('''|| wit.name ||''',NULL,SYSDATE,FALSE,FALSE);' purge
from wf_item_types    wit,
     wf_item_types_tl wtl
where wit.name like ('%')
AND wtl.name = wit.name
AND wtl.language = userenv('LANG')
AND num_purgeable <> 0
AND PERSISTENCE_TYPE='PERM'
order by num_purgeable desc; 
prompt </TABLE><P><P>


prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=2 BGCOLOR=Beige><font color=maroon face=arial>
prompt Run the <B>Workflow Work Items Statistics Concurrent Program (FNDWFWITSTATCC)</B><br>
prompt to refresh the workflow process tables after purging to confirm that the purgeable<br> 
prompt items were purged.</TD></TR>
prompt </TABLE><P><P>

REM
REM ******* Notifications not linked to a Workflow Process *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfnunref">Open Non Workflow Process(Unreferenced) Notifications</A></B></TD></TR>
prompt <TR>
prompt <TD><B>MESSAGE_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  
'<TR><TD>'||MESSAGE_TYPE||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from wf_notifications wn 
WHERE NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses wias
           WHERE  wias.notification_id = wn.group_id)
        AND NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses_h wiash
           WHERE  wiash.notification_id = wn.group_id)
        AND wn.end_date is null
    group by message_type
order by COUNT(*) desc;
prompt </TABLE><P><P>



REM
REM ******* Notifications not linked to a Workflow Process *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfnunref">Closed/Purgeable Non Workflow Process(Unreferenced) Notifications</A></B></TD></TR>
prompt <TR>
prompt <TD><B>MESSAGE_TYPE</B></TD>
prompt <TD><B>COUNT</B></TD>
select  
'<TR><TD>'||MESSAGE_TYPE||'</TD>'||chr(10)||
'<TD>'||COUNT(*)||'</TD></TR>'
from wf_notifications wn 
WHERE NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses wias
           WHERE  wias.notification_id = wn.group_id)
        AND NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses_h wiash
           WHERE  wiash.notification_id = wn.group_id)
        AND wn.end_date is not null
    group by message_type
order by COUNT(*) desc;
prompt </TABLE><P><P>



REM
REM ******* Purging closed unreferenced notifications with Purge API *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=12 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="wfntfexec"> PURGE Unreferenced Notifications API </A></B></TD></TR>
select '<TR><TD>exec WF_PURGE.NOTIFICATIONS('''|| MESSAGE_TYPE || ''',SYSDATE,FALSE);</TR></TD>' purge
from (select distinct message_type from wf_notifications wn 
WHERE NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses wias
           WHERE  wias.notification_id = wn.group_id)
        AND NOT EXISTS
          (SELECT NULL
           FROM   wf_item_activity_statuses_h wiash
           WHERE  wiash.notification_id = wn.group_id)
        AND wn.end_date is not null)
    order by message_type;
prompt </TABLE><P><P>


REM
REM ******* PACKAGE_VERSIONS *******
REM

prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=12 BGCOLOR=BLUE><font color=white face=arial>
prompt <B><A NAME="pkg"> Package Versions </A></B></TD></TR>
prompt <TD><B>PACKAGE_NAME</B></TD>
prompt <TD><B>TEXT</B></TD></TR>
select 
'<TR><TD>'||NAME||'</TD>'||chr(10)|| 
'<TD>'||TEXT||'</TD>'||chr(10)||'</TD></TR>'
from dba_source
where name in ('WF_PURGE')
and line = 2;
prompt </TABLE><P><P>


spool off
set heading on
set feedback on
set verify on
exit

