REM HEADER
REM   $Header: atg_supp_patches.sql v7.0 GGGRANT $
REM   
REM MODIFICATION LOG:
REM	
REM	GGGRANT 
REM	
REM	Consolidated script to obtain the list of ATG/WF Major Patches applied from OWF G to R12.0.4
REM	Added the EBS Version and did some minor cleanup.
REM	
REM	Added 12.0.6 AU and ATG
REM	Added 12.1.1 Maintenance Pack
REM
REM	Added 11i.ATG_PF.H.RUP7
REM
REM	Added Oracle Applications Technology Release Update Pack 2 for 12.1 (R12.ATG_PF.B.DELTA.2)
REM	Added Oracle E-Business Suite 12.1.2 Release Update Pack (RUP2)
REM
REM     Added 12.1.3 Delta & Rup: 8919491, 9239090.
REM
REM   atg_supp_patches.sql
REM     
REM   	This script was created to collect the required information
REM   	to determine the which important ATG patches have been applied.
REM
REM
REM   How to run it?
REM   
REM   	sqlplus apps/<password>
REM
REM   	@atg_supp_patches.sql
REM
REM  Parameter:
REM
REM   	
REM   
REM   Output file 
REM   
REM	atg_wf_applied_patches.html
REM
REM
REM     Created: Oct 17, 2008
REM     Last Updated: Dec 31st, 2009
REM
REM

set arraysize 1
set heading off
set feedback off  
set verify off
SET CONCAT ON
SET CONCAT .

set lines 120
set pages 9999

def outputfile = "atg_wf_applied_patches.html"
spool &&outputfile


alter session set NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';

prompt </FONT>

prompt <HTML>
prompt <HEAD>
prompt <TITLE>Applied ATG Patches</TITLE>
prompt <STYLE TYPE="text/css">
prompt <!-- TD {font-size: 8pt; font-family: arial; font-style: normal} -->
prompt </STYLE>
prompt </HEAD>
prompt <BODY>


REM
REM ******* Ebusiness Suite Version *******
REM


prompt <TABLE BORDER=1>
prompt <TR><TD COLSPAN=9 BGCOLOR=BLUE><font color=white face=arial>
prompt <B>Ebusiness Suite Version</B></TD></TR>
prompt <TR>
prompt <TD>RELEASE_NAME</TD>
select  
'<TR><TD>'||RELEASE_NAME||'</TD></TR>'
from fnd_product_groups;
prompt </TABLE><P><P>


REM
REM ******* Applied ATG Patches *******
REM


prompt <TABLE BORDER=1> 
prompt <TR><TD COLSPAN=12 BGCOLOR=BLUE><font color=white face=arial> 
prompt <B>Applied ATG/WF Patches</B></TD></TR> 
prompt <TR> 
prompt <TD>BUG_NUMBER</TD> 
prompt <TD>LAST_UPDATE_DATE</TD> 
prompt <TD>PATCH</TD>
prompt <TD>ARU_RELEASE_NAME</TD>
select 
'<TR><TD>'||BUG_NUMBER||'</TD>'||chr(10)|| 
'<TD>'||LAST_UPDATE_DATE||'</TD>'||chr(10)|| 
'<TD>'||decode(bug_number,2728236, 'OWF.G INCLUDED IN 11.5.9',
3031977, 'POST OWF.G ROLLUP 1 - 11.5.9.1',
3061871, 'POST OWF.G ROLLUP 2 - 11.5.9.2',
3124460, 'POST OWF.G ROLLUP 3 - 11.5.9.3',
3126422, '11.5.9 Oracle E-Business Suite Consolidated Update 1',
3171663, '11.5.9 Oracle E-Business Suite Consolidated Update 2',
3316333, 'POST OWF.G ROLLUP 4 - 11.5.9.4.1',
3314376, 'POST OWF.G ROLLUP 5 - 11.5.9.5',
3409889, 'POST OWF.G ROLLUP 5 Consolidated Fixes For OWF.G RUP 5', 3492743, 'POST OWF.G ROLLUP 6 - 11.5.9.6',
3868138, 'POST OWF.G ROLLUP 7 - 11.5.9.7',
3262919, 'FMWK.H',
3262159, 'FND.H INCLUDE OWF.H',
3258819, 'OWF.H INCLUDED IN 11.5.10',
3438354, '11i.ATG_PF.H INCLUDE OWF.H',
3140000, 'ORACLE APPLICATIONS RELEASE 11.5.10 MAINTENANCE PACK',
3240000, '11.5.10 ORACLE E-BUSINESS SUITE CONSOLIDATED UPDATE 1',
3460000, '11.5.10 ORACLE E-BUSINESS SUITE CONSOLIDATED UPDATE 2',
3480000, 'ORACLE APPLICATIONS RELEASE 11.5.10.2 MAINTENANCE PACK',
4017300 , 'ATG_PF:11.5.10 Consolidated Update (CU1) for ATG Product Family',
4125550 , 'ATG_PF:11.5.10 Consolidated Update (CU2) for ATG Product Family',
5121512, 'AOL USER RESPONSIBILITY SECURITY FIXES VERSION 1',
6008417, 'AOL USER RESPONSIBILITY SECURITY FIXES 2b',
6047864, 'REHOST JOC FIXES (BASED ON JOC 10.1.2.2) FOR APPS 11i',
4334965, '11i.ATG_PF.H RUP3',
4676589, '11i.ATG_PF.H.RUP4',
5473858, '11i.ATG_PF.H.RUP5',
5903765, '11i.ATG_PF.H.RUP6',
6241631, '11i.ATG_PF.H.RUP7',
4440000, 'Oracle Applications Release 12 Maintenance Pack',
5082400, '12.0.1 Release Update Pack (RUP1)',
5484000, '12.0.2 Release Update Pack (RUP2)',
6141000, '12.0.3 Release Update Pack (RUP3)',
6435000, '12.0.4 RELEASE UPDATE PACK (RUP4)',
5907545, 'R12.ATG_PF.A.DELTA.1',
5917344, 'R12.ATG_PF.A.DELTA.2',
6077669, 'R12.ATG_PF.A.DELTA.3',
6272680, 'R12.ATG_PF.A.DELTA.4', 
7237006, 'R12.ATG_PF.A.DELTA.6',
6728000, '12.0.6 RELEASE UPDATE PACK (RUP6)', 
7303030, '12.1.1 Maintenance Pack',
7651091, 'Oracle Applications Technology Release Update Pack 2 for 12.1 (R12.ATG_PF.B.DELTA.2)',
7303033, 'Oracle E-Business Suite 12.1.2 Release Update Pack (RUP2)',
9239089, 'Oracle Applications DBA 12.1.3 Product Release Update Pack',
8919491, 'Oracle Applications Technology 12.1.3 Product Family Release Update Pack',
9239090, 'ORACLE E-BUSINESS SUITE 12.1.3 RELEASE UPDATE PACK',
bug_number)||'</TD>'||chr(10)|| 
'<TD>'||ARU_RELEASE_NAME||'</TD></TR>' 
from AD_BUGS b 
where b.BUG_NUMBER in ('2728236', '3031977','3061871','3124460','3126422','3171663','3316333','3314376','3409889', '3492743', '3262159', '3262919', '3868138', '3258819','3438354','3240000', '3460000', '3140000','3480000','4017300', '4125550', '6047864', '6008417','5121512', '4334965', '4676589', '5473858', '5903765', '6241631', '4440000','5082400','5484000','6141000','6435000', 
'5907545','5917344','6077669','6272680','7237006','6728000','7303030', '7651091', '7303033', '9239089', '8919491', '9239090')
order by BUG_NUMBER,LAST_UPDATE_DATE,ARU_RELEASE_NAME; 
prompt </TABLE><P><P> 


spool off
set heading on
set feedback on  
set verify on
exit
;
