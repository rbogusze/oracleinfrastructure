REM   PURPOSE:	Helthcheck/analyzer for specific issues as identified by OTL support.
REM   PRODUCT:		  Oracle Time and Labor
REM   PLATFORM:  	  Generic
REM   =======================================================
REM   USAGE: 	This script should be run in SQLplus in APPS Schema
REM   How to run it? Follow the directions found in the Note 1580490.1

REM ANALYZER_BUNDLE_START 
REM 
REM COMPAT: 12.0 12.1 12.2
REM 
REM MENU_TITLE: HCM: Oracle Time and Labor (OTL) Analyzer 
REM MENU_START
REM
REM SQL: Run Oracle Time and Labor (OTL) Analyzer 
REM FNDLOAD: Load Oracle Time and Labor (OTL) Analyzer for R12 as a Concurrent Program 
REM 
REM MENU_END 
REM
REM HELP_START  
REM 
REM  HCM: Oracle Time and Labor (OTL) Analyzer Help [Doc ID: 1580490.1]
REM
REM  Compatible: 12.0 12.1 12.2
REM 
REM  Explanation of available options:
REM
REM    (1) Run Time and Labor [OTL] Analyzer
REM        o Runs otl_analyzer.sql as APPS
REM        o Creates an HTML report file in MENU/output/ 
REM
REM    (2) Install Time and Labor [OTL] Analyzer as a Concurrent Program 
REM	    (Doc ID: 1589250.1)
REM        o Runs FNDLOAD as APPS 
REM        o Defines the analyzer as a concurrent executable/program 
REM        o Adds the analyzer to the request group: 
REM          "OTLR Reports and Processes"
REM
REM HELP_END 
REM 
REM FNDLOAD_START 
REM
REM PROD_TOP: HXT_TOP
REM PROG_NAME: OTL_ANALYZE
REM DEF_REQ_GROUP: OTLR Reports and Processes
REM PROG_TEMPLATE: otl_prog.ldt
REM APP_NAME: Time and Labor
REM CP_FILE: otl_analyzer_cp.sql
REM PROD_SHORT_NAME: HXT 
REM
REM FNDLOAD_END 
REM
REM DEPENDENCIES_START 
REM 
REM DEPENDENCIES_END
REM  
REM RUN_OPTS_START
REM
REM RUN_OPTS_END 
REM
REM OUTPUT_TYPE: STDOUT 
REM
REM ANALYZER_BUNDLE_END

set echo off
undefine v_headerinfo
Define   v_headerinfo     = '$Id: otl_analyzer.sql 200.30'
undefine v_queries_ver
Define   v_queries_ver    = '01-Sep-2016'
undefine v_scriptlongname
Define   v_scriptlongname = 'OTL Analyzer'

REM  ==============SQL PLUS Environment setup===================
set serveroutput on size 1000000
set autoprint off
set verify off
set echo off
SET ESCAPE OFF
SET ESCAPE '\'

undefine v_nls
undefine v_version
clear columns
variable v_nls		varchar2(50);
variable v_version	varchar2(17);
VARIABLE TEST		      VARCHAR2(240);
VARIABLE n		        NUMBER;
VARIABLE HOST        	VARCHAR2(80);
VARIABLE SID         	VARCHAR2(20);
VARIABLE PLATFORM   VARCHAR2(100);
VARIABLE APPS_REL VARCHAR2(50);
VARIABLE e1 number;
VARIABLE e2 number;
VARIABLE e3 number;
VARIABLE e4 number;
VARIABLE e5 number;
VARIABLE e6 number;
VARIABLE w1 number;
VARIABLE w2 number;
VARIABLE w3 number;
VARIABLE w4 number;
VARIABLE w5 number;
VARIABLE w6 number;
VARIABLE rup_level_n varchar2(50);
VARIABLE rup_date varchar2(20);
VARIABLE hxc_status varchar2(50);
VARIABLE hxt_status varchar2(50);
VARIABLE hxc_patch varchar2(50);
VARIABLE hxt_patch varchar2(50);

set head off feedback off

--Verify RDBMS version

DECLARE

BEGIN
				
select max(version)
into :v_version
from v$instance;

:v_version := substr(:v_version,1,9);

if :v_version < '10.2.0.5.0' and :v_version > '4' then
  dbms_output.put_line(chr(10));
  dbms_output.put_line('RDBMS Version = '||:v_version);
  dbms_output.put_line('ERROR - The Script requires RDBMS version 10.2.0 or higher');
  dbms_output.put_line('ACTION - Type Ctrl-C <Enter> to exit the script.');
  dbms_output.put_line(chr(10));
end if;

null;

exception
  when others then
    dbms_output.put_line(chr(10));
    dbms_output.put_line('ERROR  - RDBMS Version error: '|| sqlerrm);
    dbms_output.put_line('ACTION - Please report the above error to Oracle Support Services.'  || chr(10) ||
                         '         Type Ctrl-C <Enter> to exit the script.');
    dbms_output.put_line(chr(10));
END;
/

--Verify NLS Character Set

DECLARE

BEGIN

select value
into :v_nls
from v$nls_parameters
where parameter = 'NLS_CHARACTERSET';

if :v_version < '8.1.7.4.0' and :v_version > '4' and :v_nls = 'UTF8' then
  dbms_output.put_line(chr(10));
  dbms_output.put_line('RDBMS Version = '||:v_version);
  dbms_output.put_line('NLS Character Set = '||:v_nls);
  dbms_output.put_line('ERROR - The HTML functionality of this script is incompatible with this Character Set for RDBMS version 8.1.7.3 and lower');
  dbms_output.put_line('ACTION - Please report the above error to Oracle Support Services.');
  dbms_output.put_line(chr(10));
end if;

exception
  when others then
    dbms_output.put_line(chr(10));
    dbms_output.put_line('ERROR  - NLS Character Set error: '|| sqlerrm);
    dbms_output.put_line('ACTION - Please report the above error to Oracle Support Services.'  || chr(10) ||
                         '         Type Ctrl-C <Enter> to exit the script.'  || chr(10) );
    dbms_output.put_line(chr(10));
END;
/




variable st_time 	varchar2(100);
variable et_time 	varchar2(100);


set term on

ACCEPT 1 prompt 'Do you want to output your OTL Product Technical Information? (y/n): '
ACCEPT 2 prompt 'Do you want to output your OTL Setup Analyzer? (y/n): '
ACCEPT 3 prompt 'Do you want to output an HXC (Self Service, Timekeeper, API) Timecard Data? (y/n): '
ACCEPT 4 prompt '        Provide Person ID of the affected Timecard (if not needed 0): '
ACCEPT 5 prompt '        Provide Start Date of the affected Timecard (use format 12-MAR-2013) (if not needed 0): '
ACCEPT 6 prompt 'Do you want to output also the Timecard Owner''s Preferences? (y/n): '
ACCEPT 7 prompt 'Do you want to output an HXT (OTLR/PUI) Timecard Data? Choose Y only if OTLR is enabled (y/n): '
ACCEPT 8 prompt '        Provide tim_id(hxt_timecards_f.id) of the affected Timecard (if not needed 0): '
ACCEPT 9 prompt 'Do you want to output a specific Batch Information? (y/n):  '
ACCEPT 10 prompt '        Provide batch_id of the required Batch (if not needed 0): '

		
REM ============ Spooling the output file====================

Prompt
Prompt Running... Please wait ...
Prompt


COLUMN host_name NOPRINT NEW_VALUE hostname
SELECT host_name from v$instance;
COLUMN instance_name NOPRINT NEW_VALUE instancename
SELECT instance_name from v$instance;
COLUMN sysdate NOPRINT NEW_VALUE when
select to_char(sysdate, 'Mon-DD-HH-MI') "sysdate" from dual;
SPOOL otl_&&instancename._&&4._&&5._&&8._&&10._&&when..html



set termout off

begin
	select to_char(sysdate,'hh24:mi:ss') into :st_time from dual;
	select upper(instance_name), host_name into :sid, :host 
						  from   v$instance;
						  
							
	SELECT SUBSTR(REPLACE(REPLACE(pcv1.product, 'TNS for '), ':' )||pcv2.status, 1, 80)
							INTO :platform
								FROM product_component_version pcv1,
								   product_component_version pcv2
							 WHERE UPPER(pcv1.product) LIKE '%TNS%'
							   AND UPPER(pcv2.product) LIKE '%ORACLE%'
							   AND ROWNUM = 1;							   
	 
end;
/

REM ================= Pl/SQL api start ========================================
set termout off
prompt <html lang="en,us"><head><!--
REM
REM ##########################################################################
REM ##########################################################################
REM Change History
REM   05-JUN-2002 ALUMPE Modified Display_SQL so that headers print only
REM                      if rows are returned
REM   02-JUL-2002 ALUMPE 1) Added Column_Exists API
REM                      2) Added Show_Invalids API
REM                      3) Added Feedback option and Number of rows option
REM                         To Run_SQL and Display_SQL API's
REM                      4) Modified Get_DB_Patch_List to give appropriate
REM                         feedback if no rows retrieved
REM                      5) Added CheckFinPeriod API
REM                      6) Added CheckKeyFlexfield API
REM                      7) Fixed font inconsistencies with Tab0Print
REM   05-AUG-2002 ALUMPE Added Init_Block and End_Block API's to enable
REM                      multi-block script without reprinting header info
REM   14-AUG-2002 ALUMPE Added NoticePrint API.
REM   30-AUG-2002 ALUMPE Modified Display_profiles to use the _VL views
REM                      rather than the _TL tables with a language condition
REM                      as userenv('LANG') = 'US' but language = 'AMERICAN'
REM                      on some 10.7 instances
REM   07-NOV-2002 ALUMPE Modified Display_SQL/Run_SQL to allow for indenting
REM                      of the table output.
REM   06-DEC-2002 ALUMPE Modified Display_SQL to convert chr(10) to html
REM                      <BR> in text values
REM   02-JAN-2003 ALUMPE Modified Display_SQL to fix bug with dates displaying
REM                      in DD-MON-  format on certain DB versions.
REM   05-FEB-2003 ALUMPE Modified Compare_Pkg_Version to handle branched
REM                      code versions
REM   17-FEB-2003 ALUMPE Fixed bug in ActionWarningLink "spanclass" corrected
REM                      to "span class" to get correct text color.
REM   26-FEB-2003 ALUMPE Fixed issue with Show_Invalids.  Error storing
REM                      variable was not being initialized for each object
REM   08-APR-2003 ALUMPE Modified CheckProfile to act like java api
REM                      Added parameter to include filename in
REM                        get_package_version/spec/body apis
REM                      Added global variable to control date format in SQL
REM   17-JUN-2003 ALUMPE Removed unused code and simplified display_sql
REM                      additionally added check to remove chr(0) where
REM                      found in text columns.
REM   20-NOV-2003 CMDRAKE Modified Display_SQL so that headers longer than 10
REM                      characters are broken at underscores
REM   21-NOV-2003 IGOVAERT Modified Display_SQL so that headers do not always
REM                      appear in InitCap
REM                      Modified Display_sql/Run_sql to allow to create a
REM                      See SQL link
REM   21-NOV-2013 SIIONESC Changed to analyzer
REM                      included warnings, errors, advices
REM                      included scan analyzer
REM                      changed format with buttons

set serveroutput on size 1000000
set feedback off
set verify off
set echo off
set long 2000000000
set linesize 32767
set longchunksize 32767
--set wrap off
set pagesize 0
set timing off
set trimout on
set trimspool on
set heading off
set autoprint off

undefine nbsp
define nbsp = ''
column lnbsp new_value nbsp noprint
select chr(38) || 'nbsp' lnbsp from dual;

undefine p_id
define p_id = ''
column lp_id new_value p_id noprint
select chr(38) || 'p_id' lp_id from dual;

undefine lt
define lt = ''
column llt new_value lt noprint
select chr(38) || 'lt' llt from dual;

undefine gt
define gt = ''
column lgt new_value gt noprint
select chr(38) || 'gt' lgt from dual;

undefine AMPER
define AMPER = ''
column lAMPER new_value AMPER noprint
select chr(38) lAMPER from dual;

undefine T_VARCHAR2
undefine T_ROWID
undefine T_NUMBER
undefine T_LONG
undefine T_DATE
undefine T_CHAR
undefine T_CLOB

variable g_hold_output clob;
variable g_curr_loc number;
variable issuep number;

declare
-- Display lines in HTML format
procedure l_o (text varchar2) is
   l_ptext      varchar2(32767);
   l_hold_num   number;
   l_ptext2      varchar2(32767);
   l_hold_num2   number;
begin
   l_hold_num := mod(:g_curr_loc, 32767);
   
   l_hold_num2 := mod(:g_curr_loc, 14336);
   if l_hold_num2 + length(text) > 14000 then
      l_ptext2 := '                                                                                                                                                                                              ';
      dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
   end if;
   
   l_hold_num2 := mod(:g_curr_loc, 18204);
   if l_hold_num2 + length(text) > 17900 then
      l_ptext2 := '                                                                                                                                                                                              ';
      dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);	 
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);	
   end if;
   
   if l_hold_num + length(text) > 32759 then
      l_ptext := '<!--' || rpad('*', 32761-l_hold_num,'*') || '-->';
      dbms_lob.write(:g_hold_output, length(l_ptext), :g_curr_loc, l_ptext);
      :g_curr_loc := :g_curr_loc + length(l_ptext);
	  dbms_lob.write(:g_hold_output, length(l_ptext), :g_curr_loc, l_ptext);
      :g_curr_loc := :g_curr_loc + length(l_ptext);
   end if;
   dbms_lob.write(:g_hold_output, length(text)+1, :g_curr_loc, text || chr(10));
   :g_curr_loc := :g_curr_loc + length(text)+1;
   
   --dbms_lob.write(:g_hold_output, length(text), :g_curr_loc, text );
   --:g_curr_loc := :g_curr_loc + length(text);
   
end l_o;


-- Procedure Name: Insert_Style_Sheet
-- Inserts a Style Sheet into the output
procedure Insert_Style_Sheet is
begin
   l_o('<TITLE>OTL Analyzer</TITLE>');
   l_o('<STYLE TYPE="text/css">');
   l_o('<!--');
    l_o('.divTitle {-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;');
  l_o('font-family: Calibri;background-color: #152B40;border: 1px solid #003399;padding: 9px;');
  l_o('margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;color: #F4F4F4;font-size: x-large;font-weight: bold;}');
  l_o('.divSection {-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;font-family: Calibri;background-color: #CCCCCC;');
  l_o('border: 1px solid #DADADA;padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;}');
   l_o('.divSectionTitle {');
	l_o('width: 98.5%;font-family: Calibri;font-size: x-large;font-weight: bold;background-color: #152B40;color: #FFFFFF;padding: 9px;margin: 0px;');
	l_o('box-shadow: 3px 3px 3px #AAAAAA;-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;height: 30px;overflow:hidden;}');
  l_o('.columns       { ');
	l_o('width: 98.5%; font-family: Calibri;font-weight: bold;background-color: #254B72;color: #FFFFFF;padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;');
	l_o('-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;height: 30px;}');
	l_o('div.divSectionTitle div   { height: 30px; float: left; }');
	l_o('div.left          { width: 80%; background-color: #152B40; font-size: x-large; border-radius: 6px; }');
	l_o('div.right         { width: 20%; background-color: #152B40; font-size: medium; border-radius: 6px;}');
	l_o('div.clear         { clear: both; }');
l_o('.divItem {-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;font-family: Calibri;');
  l_o('background-color: #F4F4F4;border: 1px solid #EAEAEA;padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;}');
l_o('.divItemTitle {font-family: Calibri;font-size: medium;font-weight: bold;color: #336699;border-bottom-style: solid;border-bottom-width: medium;');
  l_o('border-bottom-color: #3973AC;margin-bottom: 9px;padding-bottom: 2px;margin-left: 3px;margin-right: 3px;}');
	l_o('.divwarn {-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;font-family: Calibri;');
	l_o('color: #333333;background-color: #FFEF95;border: 0px solid #FDC400;padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;font-size: 11pt;}');
	l_o('.diverr {font-family: Calibri;font-size: 11pt;font-weight: bold;color: #333333; background-color: #ffd8d8;');
	l_o('  box-shadow: 3px 3px 3px #AAAAAA; -moz-border-radius: 6px; -webkit-border-radius: 6px;border-radius: 6px;padding: 9px;margin: 0px;}');
	l_o('.graph {font-family: Arial, Helvetica, sans-serif;font-size: small;}');
	l_o('.graph tr {font-family: Arial, Helvetica, sans-serif;font-size: small;background-color: transparent;}');
	l_o('.graph td {font-family: Arial, Helvetica, sans-serif;font-size: small;background-color: transparent;border: 0px transparent;}');
	l_o('.TitleBar, .TitleImg{display:table-cell;width:95%;vertical-align: middle;--border-radius: 6px;font-family: Calibri;background-color: #152B40;');
	l_o('padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;color: #F4F4F4;font-size: xx-large;font-size: 4 vw;font-weight: bold;overflow:hidden;}');
	l_o('.TitleImg{}');
	l_o('.TitleBar > div{height:25px;}');
	l_o('.TitleBar .Title2{font-family: Calibri;background-color: #152B40;padding: 9px;margin: 0px;color: #F4F4F4;font-size: medium;font-size: 4 vw;}');
	l_o('.divok {border: 1px none #00CC99;font-family: Calibri;font-size: 11pt;font-weight: normal;');
	l_o('  background-color: #ECFFFF;color: #333333;padding: 9px;margin: 0px; box-shadow: 3px 3px 3px #AAAAAA;-moz-border-radius: 6px;');
	l_o('  -webkit-border-radius: 6px;border-radius: 6px;}');
	l_o('.divok1 {border: 1px none #00CC99;font-family: Calibri;font-size: 11pt;font-weight: normal;background-color: #9FFFCF;color: #333333;');
	l_o('padding: 9px;margin: 0px;box-shadow: 3px 3px 3px #AAAAAA;-moz-border-radius: 6px;-webkit-border-radius: 6px;border-radius: 6px;}');
	l_o('.divSum {font-family: Calibri;background-color: #F4F4F4;}');
    l_o('.divSumTitle {font-family: Calibri;font-size: medium;color: #336699;}');
	l_o('A {	COLOR: #0066cc}');
	l_o('A:visited {	COLOR: #0066cc}');
	l_o('A:hover {	COLOR: #0099cc}');
	l_o('A:active {	COLOR: #0066cc}');
	l_o('.detail {	TEXT-DECORATION: none}');
   l_o('.ind1 {margin-left: .25in}');
   l_o('.ind2 {margin-left: .50in}');
   l_o('.ind3 {margin-left: .75in}');
   l_o('.tab0 {font-size: 10pt; font-weight: normal}');
   l_o('.tab1 {text-indent: .25in; font-size: 10pt; font-weight: normal}');
   l_o('.tab2 {text-indent: .5in; font-size: 10pt; font-weight: normal}');
   l_o('.tab3 {text-indent: .75in; font-size: 10pt; font-weight: normal}');
   l_o('.error {color: #cc0000; font-size: 10pt; font-weight: normal}');
   l_o('.errorbold {font-weight: bold; color: #cc0000; font-size: 10pt}');
   l_o('.warning {font-weight: normal; color: #336699; font-size: 10pt}');
   l_o('.warningbold {font-weight: bold; color: #336699; font-size: 10pt}');
   l_o('.notice {font-weight: normal; font-style: italic; color: #663366; font-size: 10pt}');
   l_o('.noticebold {font-weight: bold; font-style: italic; color: #663366; font-size: 10pt}');
   l_o('.section {font-weight: normal; font-size: 10pt}');  
   l_o('.sectionred {font-weight: normal; color: #FF0000; font-size: 11pt; font-weight: bold}');
   l_o('.sectionblue {font-weight: normal; color: #0000FF; font-size: 11pt; font-weight: bold}');
   l_o('.sectionblue1 {font-weight: normal; color: #0000FF; font-size: 11pt; font-weight: bold}');
   l_o('.sectionorange {font-weight: normal; color: #AA4422; font-size: 11pt; font-weight: bold}');
   l_o('.sectionbold {font-weight: bold; font-size: 14pt}');
   l_o('.sectiondb {font-weight: normal; color: #884400; font-size: 11pt; font-weight: bold}');
   l_o('.toctable {background-color: #F4F4F4;}');
   l_o('.sectionb {font-weight: normal; color: #884400; font-size: 11pt; font-weight: bold}');
   l_o('.sectionblack {font-weight: normal; color: #000000; font-size: 11pt; font-weight: bold}');
   l_o('.BigPrint {font-weight: bold; font-size: 14pt}');
   l_o('.SmallPrint {font-weight: normal; font-size: 8pt}');
   l_o('.BigError {color: #cc0000; font-size: 12pt; font-weight: bold}');
   l_o('.code {font-weight: normal; font-size: 8pt; font-family: Courier New}');
   l_o('span.errbul {color: #EE0000;font-size: large;font-weight: bold;text-shadow: 1px 1px #AAAAAA;}');
   l_o('span.warbul {color: #FFAA00;font-size: large;font-weight: bold;text-shadow: 1px 1px #AAAAAA;}');
   l_o('.legend {font-weight: normal;color: #0000FF;font-size: 9pt; font-weight: bold}');
   l_o('.btn {border: #000000;border-style: solid;border-width: 2px;width:190;height:50;border-radius: 6px;background: linear-gradient(#FFFFFF, #B0B0B0);font-weight: bold;color: blue;margin-top: 5px;margin-bottom: 5px;margin-right: 5px;margin-left: 5px;vertical-align: middle;}');  
   l_o('body {background-color: white; font: normal 12pt Ariel;}');
   l_o('table {background-color: #000000 color:#000000; font-size: 10pt; font-weight: bold; line-height:1.5; padding:2px; text-align:left}');
   l_o('h1, h2, h3, h4 {color: #00000}');
   l_o('h3 {font-size: 16pt}');
   l_o('td {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; border-style: solid; border-width: 1; border-color: #DEE6EF; white-space: nowrap}');
   l_o('tr {background-color: #f7f7e7; color: #000000; font-weight: normal; font-size: 9pt; white-space: nowrap}');
   l_o('th {background-color: #DEE6EF; color: #000000; height: 20; border-style: solid; border-width: 2; border-color: #f7f7e7;  white-space: nowrap}');
   l_o('th.rowh {background-color: #CCCC99; color: #336699; height: 20; border-style: solid; border-width: 1; border-top-color: #f7f7e7; border-bottom-color: #f7f7e7; border-left-width: 0; border-right-width: 0; white-space: nowrap}');
   l_o('-->');
   l_o('</style>');
end;



-- Procedure Name: Show_Header
-- Displays Standard Header Information
-- Examples: Show_Header('139684.1', 'Oracle Applications Current Patchsets Comparison to applptch.txt', 'Version 1.0');
procedure Show_Header(p_note varchar2, p_title varchar2, p_ver varchar2, p_queries_ver varchar2) is
   l_instance_name   varchar2(16) := null;
   l_host_name   varchar2(64) := null;
   l_version   varchar2(17) := null;
   l_multiorg   varchar2(4) := null;
   l_user   varchar2(100) := null;
   v_date varchar2(200);
begin
   DBMS_LOB.CREATETEMPORARY(:g_hold_output,TRUE,DBMS_LOB.SESSION);
   select instance_name
        , host_name
        , version
     into l_instance_name
        , l_host_name
        , l_version
     from v$instance;

   select decode (multi_org_flag, 'Y', 'Yes', 'No') into l_multiorg from fnd_product_groups;

   select user
     into l_user
     from dual;

  l_o('-->');
-- Add the ability to display a popup text window
  l_o('<script language="JavaScript" type="text/javascript">');
  l_o('function popupText(pText){');
  l_o('var frog = window.open("","SQL","width=800,height=500,top=100,left=300,location=0,status=0,scrollbars=1,resizable=1")');
  l_o('var html = "<html><head><"+"/head><body>"+ pText +"<"+"/body><"+"/html>";');
  l_o('frog.document.open();');
  l_o('frog.document.write(html);');
  l_o('frog.document.close();');
  l_o('}');
  	l_o('function opentabs() {');
    l_o(' var tabCtrl = document.getElementById(''tabCtrl''); ');      
    l_o('   for (var i = 0; i < tabCtrl.childNodes.length; i++) {');
    l_o('       var node = tabCtrl.childNodes[i];');
	l_o(' if (node.nodeType == 1)  {');
	l_o('	   if (node.toString() != ''[object HTMLScriptElement]'') { node.style.display =  ''block'' ; ');
     l_o('      }  }   }  }');
   
    l_o('function closetabs() {');
    l_o(' var tabCtrl = document.getElementById(''tabCtrl'');  ');     
    l_o('   for (var i = 0; i < tabCtrl.childNodes.length; i++) {');
    l_o('       var node = tabCtrl.childNodes[i];');
    l_o('       if (node.nodeType == 1) { /* Element */');
    l_o('           node.style.display =  ''none'' ;  }    }   }');
	
  l_o('function activateTab(pageId) {');
	l_o('     var tabCtrl = document.getElementById(''tabCtrl'');');
	l_o('       var pageToActivate = document.getElementById(pageId);');
	l_o('       for (var i = 0; i < tabCtrl.childNodes.length; i++) {');
	l_o('           var node = tabCtrl.childNodes[i];');
	l_o('           if (node.nodeType == 1) { /* Element */');
	l_o('               node.style.display = (node == pageToActivate) ? ''block'' : ''none'';');
	l_o('           }');
	l_o('        }');
	l_o('   }');
	l_o(' function displayItem(e, itm_id) {');
    l_o(' var tbl = document.getElementById(itm_id);');
    l_o(' if (tbl.style.display == ""){');
    l_o('    e.innerHTML =');
    l_o('       e.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));    ');    
    l_o('    tbl.style.display = "none"; }');
    l_o(' else {');
    l_o('     e.innerHTML =');
    l_o('       e.innerHTML.replace(String.fromCharCode(9654),String.fromCharCode(9660)); ');        
    l_o('     tbl.style.display = ""; }');
    l_o('}');
	
	l_o('function activateTab2(pageId) {');
	l_o('     var tabCtrl = document.getElementById(''tabCtrl'');');
	l_o('       var pageToActivate = document.getElementById(pageId);');
	l_o('       for (var i = 0; i < tabCtrl.childNodes.length; i++) {');
	l_o('           var node = tabCtrl.childNodes[i];');
	l_o('           if (node.nodeType == 1) { /* Element */');
	l_o('               node.style.display = (node == pageToActivate) ? ''block'' : ''none'';');
	l_o('           } }');
	l_o('        tabCtrl = document.getElementById(''ExecutionSummary2'');');
	l_o('        tabCtrl.style.display = "none";');
	l_o('        tabCtrl = document.getElementById(''ExecutionSummary1'');');
    l_o('        tabCtrl.innerHTML = tabCtrl.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
	l_o('   }');
	
	l_o('function displayItem2(e, itm_id) {');
    l_o(' var tbl = document.getElementById(itm_id);');
    l_o(' if (tbl.style.display == ""){');
    l_o('    e.innerHTML =');
    l_o('       e.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
    l_o('    e.innerHTML = e.innerHTML.replace("Hide","Show");');
    l_o('    tbl.style.display = "none"; }');
    l_o(' else {');
    l_o('     e.innerHTML =');
    l_o('       e.innerHTML.replace(String.fromCharCode(9654),String.fromCharCode(9660));');
    l_o('     e.innerHTML = e.innerHTML.replace("Show","Hide");');
    l_o('     tbl.style.display = ""; }');
    l_o('}');
	
		l_o('function openall()');
	l_o('{var txt = "s1sql";');
	l_o('var i;                                                                    ');
	l_o('var x=document.getElementById(''s1sql0'');                                      ');
	l_o('for (i=0;i<91;i++)                                                               ');
	l_o('{			   x=document.getElementById(txt.concat(i.toString()));                                             ');
	l_o('		   if (!(x == null )){document.getElementById(txt.concat(i.toString())).style.display = ''''; 	');
	l_o('			x = document.getElementById(txt.concat(i.toString(),''b''));  ');
	l_o('			if (!(x == null )){x.innerHTML = x.innerHTML.replace(String.fromCharCode(9654),String.fromCharCode(9660));');
	l_o('			               x.innerHTML = x.innerHTML.replace("Show","Hide"); }  ');
	l_o('              }  	}');	
	l_o('		  }   ');
	
	l_o('function closeall()');
	l_o('{var txt = "s1sql";');
	l_o('var i;                                                                    ');
	l_o('var x=document.getElementById(''s1sql0'');                                      ');
	l_o('for (i=0;i<91;i++)                                                               ');
	l_o('{			   x=document.getElementById(txt.concat(i.toString()));                                             ');
	l_o('		   if (!(x == null )){document.getElementById(txt.concat(i.toString())).style.display = ''none'';   ');
	l_o('			x = document.getElementById(txt.concat(i.toString(),''b''));  ');
	l_o('			if (!(x == null )){x.innerHTML = x.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
	l_o('			               x.innerHTML = x.innerHTML.replace("Hide","Show"); }  ');
	l_o('              }  	}');	
	l_o('txt = "s1sql100";                                                                                       ');
	l_o('for (i=1;i<300;i++)                                                                                   ');
	l_o('{			   x=document.getElementById(txt.concat(i.toString()));                                      ');	
	l_o('		   if (!(x == null )){document.getElementById(txt.concat(i.toString())).style.display = ''none''; ');
	l_o('			x = document.getElementById(txt.concat(i.toString(),''b''));  ');
	l_o('			if (!(x == null )){x.innerHTML = x.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
	l_o('			               x.innerHTML = x.innerHTML.replace("Hide","Show"); }  ');
	l_o('			}');
	l_o('		   }	     ');
		l_o('txt = "s1sql200";                                                                                       ');
	l_o('for (i=1;i<300;i++)                                                                                   ');
	l_o('{			   x=document.getElementById(txt.concat(i.toString()));                                      ');	
	l_o('		   if (!(x == null )){document.getElementById(txt.concat(i.toString())).style.display = ''none''; ');
	l_o('			x = document.getElementById(txt.concat(i.toString(),''b''));  ');
	l_o('			if (!(x == null )){x.innerHTML = x.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
	l_o('			               x.innerHTML = x.innerHTML.replace("Hide","Show"); }  ');
	l_o('			}');
	l_o('		   }	}     ');
	
	l_o('    function hideRow(target)');
    l_o('    {var row = document.getElementById(target);');
   	l_o('    row.style.display = ''none'';');
	l_o('    row = document.getElementById(target.concat(''b''));');
	l_o('    row.scrollIntoView();');
	l_o('    row.innerHTML = row.innerHTML.replace(String.fromCharCode(9660),String.fromCharCode(9654));');
    l_o('     }');	
	l_o('</script>');
	l_o('<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>');
	l_o('<script>');
	l_o('$(document).ready(function(){');
	l_o('var src = $(''img#error_ico'').attr(''src'');');
	l_o('$(''img.error_ico'').attr(''src'', src);');
	l_o('var src = $(''img#warn_ico'').attr(''src'');');
	l_o('$(''img.warn_ico'').attr(''src'', src);');
	l_o('var src = $(''img#check_ico'').attr(''src'');');
	l_o('$(''img.check_ico'').attr(''src'', src);');
	l_o('});</script>');

	Insert_Style_Sheet;
	l_o('</head><body>');
	--error icon
	l_o('<div style="display: none;">');
	l_o('<img id="error_ico" src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAANbY1E9YMgAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAANYSURBVHjaYvz//z8DDBQwMor+ZWDw+8fA4PKHgcEUiOWB+CEQnwbiPb8ZGDat+///NQMSAAggRpgBQM3OQI25XiGe/jr2Ngwi6hoMbHz8DF/v3mR4dO4cw/HjZxjWHru4C2hQ3+7//3fCDAAIILABhUDNUnJS/UHZSbpKcuIMDCf3Mvy9fo7h7/OnDP+FxRj+i8sx/BOXZTh8+xnDosPnb936/L3yzP//60AGAAQQYwEDA8jZs/M7a/yVvz9n+LdxAcP/v38Z/gId9g/oJBD9F0wzAj2kzrDn43+G7pM3j7xkYEh5+P//TYAAYgL5GeRskM3/Ni1gYEyrZWCcsx9FM9fC/Qzs2fUMP4Heseb6z+AgzmfDycAQw8jIyAYQQExAP7mA/Axy9r8/QOOM7RmYTB0YWOfvBxsA0sxi5gDE9kDD/jP8e/2KQZeXlYGJgcEe6AMJgABiSGNguPN919r/v93l/v/UZfj/XYfh/59T+/+DwO+TEPrnif3/nygy/H8oz/D/niLr/yMawv+1GBieAw0wAgggkAvk2fgFGf6/eMrwD+rkb3GODH9OHQDb/OvkAYbXkY6QcADiP79+Mwj8/c0AVCoKNEAAIIBABjz8dvcGwz8hMbABIMwJdTZIM5u5A4Pwsv0Mf4Caf4Mw0PHPvv4C0gyg9MAFEEAgA04/PHeW4b+EHNgGzgUIzW+ANv88cYCBw8KBQXLlfrD8v/9MDFe//QEZcBtowDeAAAIZsOfEsTPguAZF1e+TB+Ga/wBd8yzMkeH78QMMX48dBBvwGyh25vtfhh8MDBeABnwACCDGQKBfgJwlBT42bmZ/3jL8unOD4S8w+EGaQZHyBxqdIPZfRmaGjV8ZGOZ+/nvyFQPDFKC+QwABxARK20Dn9C0EprC9n4BOVFBn+McvBFTMyvCHgZHhD1DTX0YWht/MrGDNG77+vfuFgWELUPNNoAteAAQQPC+YMjIGAdNaoZOkgI0eLxuDAhsDg9DfPwxPvv5kuPrlF8Ppb38ZDv/4dxKk+R0Dw0GglutAvW8AAogROTfKMzKqg1IYKJEADVMFRRUotEEBBvLzRwaGU1Cb74M0g/QABBCKAWABYPIEpzAGBhFQPIOiChTaoAADYpCmF0A9v2DqAQIMAAqQl7ObLOmtAAAAAElFTkSuQmCC" alt="error_ico">');
	 --warning icon
	l_o('<img title="warning" id="warn_ico" src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAANbY1E9YMgAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJHSURBVHjaYvz//z8DNjAhlnHdv38MgUC8vmT5/yAGHAAggBhABqDj/hgG7+OLvP+DwJEF3v+jLRgKsKkDYYAAYsJiMzMDI0uHkV87A8NpRgYJ9q0MSqIMBQJcjFLYHAAQQBgGAJ2c7BaZpMP26ziYr6zMwGBhwiDvb8BQxAgE6OoBAgjFOb1RDDwTE3mf/v3+5H9nCvf/FEfG/51JjP+fb2T4X+3F8EZFlEEL3QsAAcSEZnuRX3KhFNO7uQxnL3xjuPuQgeHsJQYGCVEGBjtLBmFbFYZyoCNYkPUABBDcgJ5IRmluQZkyeZM0Bobn3QziohBxcRGQyQwMVsZANi9DmKk8gyWyAQABxIRke3VgZhU344tWIOcLg4c9JHo9bIH0XwYGHg4GBjcbBg49SbArOGD6AAKIEeSPrnBGLSFp7UsprauYGa7qAQ34C9YEshlMQ/G/PwwM5V0M/048YAg+fO//BpABAAHEBLW9KzS/k5nhSRlc88K1DAwxJYwMC9cjDGACGujvwMCkIcpQBXQFL0gvQAAxdYQy2hvb23vzC/EwMLzbCrd591FGhmevgPRxRoQrgC6w0WVg0FdkMHVSZogGGQAQQExA20stA0rBAcfwH+FsV4v/DFLAgHQ1+w/XDDPISpuBQU6AIRnoCmGAAGIBGmDCeNuHgYEDyc9AOt4biD3QNP+ByKlKMjCwMzGogNIZQACBDNjS08+QDKQZ8GFQnkOmP/5gOA00QAAggMCxAHSKPpAjx0A6eAQQQIy4sjOxACDAAOXOBcGE78mYAAAAAElFTkSuQmCC" alt="warn_ico">');
	  --check icon
	l_o('<img id="check_ico" src="data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAANbY1E9YMgAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAELSURBVHjaYvz//z8DJQAggJhIUcyYwNjAGMP4nzGcsQEmBhBADCAXEIMZ4hkaGKIZ/h//dvw/QyDDfwZnhskgcYAAIl3zKQYI9mIA+V0dIIDI12zOsAxogC9AAEEUpQIVpQIFgTSG5ig8moEuAAgguObjv4//RzYExeYL2DWD1AEEEANc82uG/1Ufq/4zJAMVBTNMhtt8EarZE1MzCAMEEML5rxkQhhBhMwwDBBAiDEA2PwXie0BDXlURtBmGAQIIwYA6m+E6A0KzF37NIAwQQKgcb6AhgcRrBmGAAMIUAKYwYjWDMEAAMWLLTIyMjOpASg2IbwHlb+LLHwABxEhpbgQIICYGCgFAgAEAGJx1TwQYs20AAAAASUVORK5CYII=" alt="check_ico">');
	l_o('</div>');

	l_o('<div class="TitleBar"><div class="Title1">OTL Analyzer</div>');
	l_o('<div class="Title2">Compiled using version 200.30 / Latest version: ');
	l_o('<a href="https://support.oracle.com/oip/faces/secure/km/DownloadAttachment.jspx?attachid=1580490.1:SCRIPT">');
	l_o('<img border="0" src="https://blogs.oracle.com/ebs/resource/Proactive/hcm_otl_latest_version.gif" title="Click here to download the latest version of analyzer" alt="Latest Version Icon"></a></div></div>');
	l_o('<div class="TitleImg"><a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=432.1" target="_blank"><img src="https://blogs.oracle.com/ebs/resource/Proactive/PSC_Logo.jpg" title="Click here to see other helpful Oracle Proactive Tools" alt="Proactive Services Banner" border="0" height="60" width="180"></a></div><br>');	

	l_o('<div class="divSection">');
	l_o('<div class="divItem">');
	l_o('<div class="divItemTitle">Report Information</div>');
	l_o('<span class="legend">Legend: &nbsp;&nbsp;<img class="error_ico"> Error &nbsp;&nbsp;<img class="warn_ico"> Warning &nbsp;&nbsp;<img class="check_ico"> Passed Check</span>');
 	
	
  SELECT RELEASE_NAME into :apps_rel from FND_PRODUCT_GROUPS; 
  select to_char(sysdate, 'Dy Month DD, YYYY hh24:mi:ss') into v_date from dual;  
	
   l_o('<table width="100%" class="graph"><tbody><tr class="top"><td width="33%">');
  l_o('<A class=detail onclick="displayItem(this,''s1sqlexec'');" href="javascript:;">&#9654; Execution Details</A>') ; 
  l_o('<TABLE style="DISPLAY: none" id=s1sqlexec><TBODY>');
  l_o('<TR><TH>Apps Version </TH>');
  l_o('<TD>'||:apps_rel||'</TD></TR>');
  l_o('<TR><TH>Calling From </TH><TD>SQL Script</TD></TR>');
  l_o('<TR><TH>Description </TH>');
  l_o('<TD>The OTL Analyzer (<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?\&id=1580490.1" target="_blank">Doc ID 1580490.1</a>) is a self-service<br>health-check script that reviews the overall footprint, ');
  l_o('analyzes<br>current configurations and settings for the environment and<br> provides feedback and recommendations on best practices.<br>Your application data is not altered in any way when you run<br>this analyzer.</TD></TR>');
  l_o('<TR><TH>Execution Date </TH>');
  l_o('<TD>'||v_date||'</TD></TR>');
  l_o('<TR><TH>File name </TH><TD>otl_analyzer.sql</TD></TR>');
  l_o('<TR><TH>File version </TH><TD>200.30</TD></TR>');
  l_o('<TR><TH>Host</TH>');
  l_o('<TD>'||:host||'</TD></TR>');
  l_o('<TR><TH>Instance </TH>');
  l_o('<TD>'||:sid||'</TD></TR>');  
   l_o('</TBODY></TABLE></td>');
  l_o('<td width="33%"><A class=detail onclick="displayItem(this,''s1sqlparam'');" href="javascript:;">&#9654; Parameters</A>');
  l_o('<TABLE style="DISPLAY: none" id=s1sqlparam >');
  l_o('<TBODY><TR>');
  l_o('<TH>Output Technical Information</TH>');
  l_o('<TD>'||'&&1');
  l_o('</TD></TR>');
   l_o('<TH>Output setup scan</TH>');
  l_o('<TD>'||'&&2');
  l_o('</TD></TR>');
   l_o('<TH>Output an HXC (Self Service, Timekeeper, API) Timecard Data</TH>');
  l_o('<TD>'||'&&3');
  l_o('</TD></TR>');
   l_o('<TH>Person ID of the affected Timecard</TH>');
  l_o('<TD>'||'&&4');
  l_o('</TD></TR>');
   l_o('<TH>Start Date of the affected Timecard</TH>');
  l_o('<TD>'||'&&5');
  l_o('</TD></TR>');
   l_o('<TH>Output the Timecard Owner''s Preferences</TH>');
  l_o('<TD>'||'&&6');
  l_o('</TD></TR>');
   l_o('<TH>Output an HXT (OTLR/PUI) Timecard Data</TH>');
  l_o('<TD>'||'&&7');
  l_o('</TD></TR>');
   l_o('<TH>Tim_id(hxt_timecards_f.id) of the affected Timecard</TH>');
  l_o('<TD>'||'&&8');
  l_o('</TD></TR>');
   l_o('<TH>Output a specific Batch Information</TH>');
  l_o('<TD>'||'&&9');
  l_o('</TD></TR>');
   l_o('<TH>Batch_id of the required Batch</TH>');
  l_o('<TD>'||'&&10');
  l_o('</TD></TR>');
 
    l_o('</TBODY></TABLE></td>');
	l_o('<td width="33%"><div id="ExecutionSummary1"><a class="detail" href="javascript:;" onclick="displayItem(this,''ExecutionSummary2'');"><font color="#0066CC">&#9654; Execution Summary</font></a> </div>');
    l_o('<div id="ExecutionSummary2" style="display:none"></div>');
    l_o('</td></tr></table>');	

	l_o('</div><br/>');
	l_o('<div class="divItem" id="toccontent">');
	l_o('<div class="divItemTitle">Sections In This Report</div></div>');
	l_o('<div align="center">');
	l_o('<a class="detail" onclick="opentabs();" href="javascript:;"><font color="#0066CC"><br>Show All Sections</font></a> / ');
	l_o('<a class="detail" onclick="closetabs();" href="javascript:;"><font color="#0066CC">Hide All Sections</font></a></div>');
	l_o('</div><br></div>');


end Show_Header;


-- Display table of contents
procedure table_contents is
			v_problems number;
			begin
					  l_o('<table width="95%" border="0"> <tr> <td class="toctable" width="50%">');
					  l_o('<a href="#sum"><b>Instance Overview</b></a> <br>');
					  l_o('<blockquote>');
						  l_o('<a href="#sum"><b>Instance Summary</b></a> <br>');
						  l_o('<a href="#db"><b>Database Details</b></a> <br>');
						  l_o('<a href="#apps"><b>Application Details</b></a> <br>');		  
						  l_o('<a href="#products"><b>Products Status</b></a> <br>');
						  l_o('<a href="#nls"><b>Languages Installed</b></a> <br>');          
						  l_o('<a href="#rup"><b>Patching</b></a> <br>');						
					  l_o('</blockquote>');
					  
					  l_o('<a href="#packages"><b>Versions</b></a> <br>');
					  l_o('<blockquote><a href="#packages"><b>Packages Versions</b></a> <br>');
					  l_o('<a href="#java"><b>Java Classes Versions</b></a> <br>');   
					  l_o('<a href="#forms"><b>Forms Versions</b></a> <br>'); 					  
					  l_o('<a href="#reports"><b>Reports and XML Versions</b></a> <br>');
					  l_o('<a href="#ldt"><b>Ldt Versions</b></a> <br>');
					  l_o('<a href="#odf"><b>Odf Versions</b></a> <br>');
					  l_o('<a href="#sql"><b>Sql Versions</b></a> <br>');
					  l_o('<a href="#workflow"><b>Workflow Versions</b></a> <br>');
					  l_o('</blockquote>');					  
					  l_o('</td><td class="toctable" width="50%">');
					  l_o('<a href="#db_init_ora"><b>Performance</b></a> <br>');
					  l_o('<blockquote><a href="#db_init_ora"><b>Database Initialization Parameters</b></a> <br>');
					  l_o('<a href="#gather"><b>Gather Schema Statistics</b></a> <br>');
					  
					  l_o('</blockquote>');
					  
					  l_o('<a href="#purge"><b>Workflow</b></a> <br>');
					  l_o('<blockquote><a href="#purge"><b>Purgeable Obsolete Workflow</b></a> <br>');
					  l_o('<a href="#stuck"><b>Workflows with Errors</b></a> <br>');
					  l_o('</blockquote>');

					  
					  l_o('<a href="#invalids"><b>Database Issues</b></a> <br>');
					  l_o('<blockquote>');
					  select count(1) into v_problems
							 from sys.obj$ do, sys.dependency$ d, sys.obj$ po
							 where p_obj#=po.obj#(+)
							 and d_obj#=do.obj#
							 and do.status=1 
							 and po.status=1 
							 and po.stime!=p_timestamp 
							 and do.type# not in (28,29,30) 
							 and po.type# not in (28,29,30) ;
					  if v_problems>0 then
						l_o('<a href="#timestamp"><b>Dependency timestamp discrepancies between the database objects</b></a> <br>');
					  end if;
					  l_o('<a href="#invalids"><b>Invalid Objects</b></a> <br>');
					  l_o('<a href="#triggers"><b>Disabled Triggers</b></a> <br>');					  
					  l_o('</blockquote>');
									  
					  l_o('</td></tr></table>');
					
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Overview: Database, Application, HCM products status			
procedure overview is
				db_charset V$NLS_PARAMETERS.value%type;
				db_lang V$NLS_PARAMETERS.value%type;
				multiOrg FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%type;
				multiCurr FND_PRODUCT_GROUPS.MULTI_CURRENCY_FLAG%type;				
				database_version V$VERSION.banner%type;
				v_appl fnd_application_all_view.application_name%type; 
				v_appls fnd_application_all_view.application_short_name%type; 
				v_applid varchar2(20);
				v_status fnd_lookups.meaning%type;
				v_patch fnd_product_installations.patch_level%type;
				rup_level varchar2(20);				
				v_rows number;
				v_wfVer WF_RESOURCES.TEXT%type:='';
				v_crtddt V$DATABASE.CREATED%type;
				hr_status varchar2(20);
				pay_status varchar2(20);				
				cursor legislations is
				SELECT DECODE(legislation_code
							   ,null,'Global'
							   ,legislation_code)  leg              
					   , DECODE(application_short_name
							   , 'PER', 'Human Resources'
							   , 'PAY', 'Payroll'
							   , 'GHR', 'Federal Human Resources'
							   , 'CM',  'College Data'
							   , application_short_name) application         
				  FROM hr_legislation_installations
				  WHERE status = 'I'
				  ORDER BY legislation_code;
				cursor products is
				select t.application_name , b.application_short_name
					, to_char(t.application_id)
					, l.meaning
					, decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)
					from fnd_application b, fnd_application_tl t, fnd_product_installations i,  fnd_lookup_values l
					where (t.application_id = i.application_id)
					AND b.application_id = t.application_id
					 and (b.application_id in ('0', '50', '178', '201','203', '275', '426', '453', '800', '801', '802', '803', '804', '805', '808', '809', '810', '821', '8301', '8302', '8303','8403'))
					and (l.lookup_type = 'FND_PRODUCT_STATUS')
					and (l.lookup_code = i.status )
					AND t.language = 'US' AND l.language = 'US' order by upper(t.application_name);	
				begin
					  :n := dbms_utility.get_time;
						select VALUE into db_lang FROM V$NLS_PARAMETERS WHERE parameter = 'NLS_LANGUAGE';
					    select VALUE into db_charset FROM V$NLS_PARAMETERS WHERE parameter = 'NLS_CHARACTERSET';		  
						select banner into database_version from V$VERSION WHERE ROWNUM = 1;
						SELECT MULTI_ORG_FLAG,MULTI_CURRENCY_FLAG into multiOrg, multiCurr FROM FND_PRODUCT_GROUPS;
						select count(1) into v_rows FROM V$DATABASE;
						if v_rows=1 then	
						SELECT CREATED into v_crtddt FROM V$DATABASE;
						end if;
						select count(1) into v_rows FROM WF_RESOURCES  WHERE TYPE = 'WFTKN'  AND NAME = 'WF_VERSION'  AND LANGUAGE = 'US';
						if v_rows=1 then
						SELECT TEXT into v_wfVer  FROM WF_RESOURCES  WHERE TYPE = 'WFTKN'  AND NAME = 'WF_VERSION'  AND LANGUAGE = 'US';	
						end if;
						SELECT L.MEANING  into hr_status  FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
							  WHERE (b.APPLICATION_ID = I.APPLICATION_ID) AND b.application_id = t.application_id
								AND (b.APPLICATION_ID = '800') AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS') AND (L.LOOKUP_CODE = I.Status) AND t.language = 'US'	AND l.language = 'US';
							  SELECT L.MEANING  into pay_status  FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
							  WHERE (b.APPLICATION_ID = I.APPLICATION_ID) AND b.application_id = t.application_id
								AND (b.APPLICATION_ID = '801') AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS') AND (L.LOOKUP_CODE = I.Status)
								AND t.language = 'US'	AND l.language = 'US';						
						select  count(1) into v_rows FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
								  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
									AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
									AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US';
						if v_rows=1 then
							SELECT L.MEANING,decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into :hxt_status,:hxt_patch  FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
								  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
									AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
									AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US';							
						end if;
						select  count(1) into v_rows FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
								  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
									AND (b.APPLICATION_ID = '809')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
									AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US';
						if v_rows=1 then
							SELECT L.MEANING,decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into :hxc_status,:hxc_patch  FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L
								  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
									AND (b.APPLICATION_ID = '809')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
									AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US';
							if :APPS_REL like '12.%'  then
							:hxc_patch:=' ';
							end if;
						end if;
					
	if :apps_rel like '12.2%' then
			SELECT max(to_number(adb.bug_number)) into rup_level FROM ad_bugs adb
            WHERE adb.bug_number in ('21507777','20000400','19193000','17909898','17050005','17001123','16169935','14040707','10124646')	;
			 SELECT DECODE(bug_number
                  ,'17001123', 'R12.HR_PF.C.delta.3'    
                  , '16169935', 'R12.HR_PF.C.delta.2'
                  ,'14040707', 'R12.HR_PF.C.delta.1'
                  ,'10124646', 'R12.HR_PF.C'
				  ,'17050005', 'R12.HR_PF.C.Delta.4'
				  ,'17909898', 'R12.HR_PF.C.delta.5'
				  ,'19193000', 'R12.HR_PF.C.Delta.6'
				  ,'20000400', 'R12.HR_PF.C.Delta.7'
				  ,'21507777', 'R12.HR_PF.C.Delta.8'
                   ) 
                , LAST_UPDATE_DATE   
                  into :rup_level_n, :rup_date
                  FROM ad_bugs 
                  WHERE BUG_NUMBER =rup_level and rownum < 2;
				  
    elsif :apps_rel like '12.1%' then
                       
            select max(to_number(bug_number)) into rup_level from ad_bugs 
            WHERE BUG_NUMBER IN ('16000686','13418800','10281212','9114911','8337373', '7446767', '6603330','18004477','20000288','21980909');            
                 
           SELECT DECODE(BUG_NUMBER
				  ,'21980909','R12.HR_PF.B.Delta.9'
				  ,'20000288','R12.HR_PF.B.delta.8'
				  ,'18004477', 'R12.HR_PF.B.delta.7'
                  ,'16000686', 'R12.HR_PF.B.delta.6'    
                  , '13418800', 'R12.HR_PF.B.delta.5'
                  ,'10281212', 'R12.HR_PF.B.delta.4'
                  ,'9114911', 'R12.HR_PF.B.delta.3'
                  ,'8337373', 'R12.HR_PF.B.delta.2'
                  ,'7446767', 'R12.HR_PF.B.delta.1'
                  ,'6603330', 'R12.HR_PF.B'
                   ) 
                , LAST_UPDATE_DATE   
                  into :rup_level_n, :rup_date
                  FROM ad_bugs 
                  WHERE BUG_NUMBER =rup_level and rownum < 2;            

            
       elsif :apps_rel like '12.0%' then
            select max(to_number(bug_number)) into rup_level from ad_bugs 
            WHERE BUG_NUMBER IN ('16077077','13774477','10281209','9301208','7577660', '7004477', '6610000', '6494646', '6196269', '5997278', '5881943', '4719824');
            
           SELECT DECODE(BUG_NUMBER
                  , '16077077', 'R12.HR_PF.A.delta.11'
                  , '13774477', 'R12.HR_PF.A.delta.10'
                  , '10281209', 'R12.HR_PF.A.delta.9'
                  , '9301208', 'R12.HR_PF.A.delta.8'
                  , '7577660', 'R12.HR_PF.A.delta.7'
                  , '7004477', 'R12.HR_PF.A.delta.6'
                  , '6610000', 'R12.HR_PF.A.delta.5'
                  , '6494646', 'R12.HR_PF.A.delta.4'
                  , '6196269', 'R12.HR_PF.A.delta.3'
                  , '5997278', 'R12.HR_PF.A.delta.2'
                  , '5881943', 'R12.HR_PF.A.delta.1'
                  , '4719824', 'R12.HR_PF.A')
                  , LAST_UPDATE_DATE  
                  into :rup_level_n, :rup_date
                  FROM ad_bugs 
                  WHERE BUG_NUMBER =rup_level and rownum < 2;
                 
            
       elsif   :apps_rel like '11.5%' then   
            select count(1) into v_rows from ad_bugs 
            WHERE BUG_NUMBER IN ('2803988','2968701','3116666','3233333','3127777','3333633',
           '3500000','5055050','5337777','6699770','7666111','9062727','10015566','12807777','14488556','17774746');
            
            if v_rows>0 then         
				   select max(to_number(bug_number)) into rup_level from ad_bugs 
							WHERE BUG_NUMBER IN ('2803988','2968701','3116666','3233333','3127777','3333633',
						   '3500000','5055050','5337777','6699770','7666111','9062727','10015566','12807777','14488556','17774746');                    
								 
				   SELECT DECODE(BUG_NUMBER
                           , '2803988', 'HRMS_PF.E'
                           , '2968701', 'HRMS_PF.F'
                           , '3116666', 'HRMS_PF.G'
                           , '3233333', 'HRMS_PF.H'
                           , '3127777', 'HRMS_PF.I'
                           , '3333633', 'HRMS_PF.J'
                           , '3500000', 'HRMS_PF.K'
                           , '5055050', 'HR_PF.K.RUP.1'
                           , '5337777', 'HR_PF.K.RUP.2'
                           , '6699770', 'HR_PF.K.RUP.3'
                           , '7666111', 'HR_PF.K.RUP.4'
                           , '9062727', 'HR_PF.K.RUP.5'
                           , '10015566', 'HR_PF.K.RUP.6'
                           , '12807777', 'HR_PF.K.RUP.7'
                           , '14488556', 'HR_PF.K.RUP.8'
						   , '17774746', 'HR_PF.K.RUP.9'
                            )  
                        , LAST_UPDATE_DATE  
                          into :rup_level_n, :rup_date
                          FROM ad_bugs 
                          WHERE BUG_NUMBER =rup_level and rownum < 2;
						
				end if;   
      end if;
	
					
					if :APPS_REL like '11.%' then
					select max(to_number(bug_number)) into rup_level from ad_bugs 
										WHERE BUG_NUMBER IN  ('2398780','2613123' ,'2614545' ,'2821443' ,'2716711' ,'3042947' ,'3056938' ,'3438088' ,'3604603' ,'3621576'
										,'3634044' ,'3664795' ,'3686163' ,'3763776' ,'3838434' ,'3803131' ,'3939443' ,'3285055' ,'3561162' ,'3623577' ,'3634007' ,'3664800' ,'3718653'
										,'3838319'  ,'3803130' ,'3882104' ,'4042676' ,'4067571' ,'4105173'  ,'4220319' ,'4298433' ,'4373216' ,'3530830' ,'4057588' ,'4045358' ,'4373214'
										 ,'4544887' ,'4653019' ,'4773290' ,'4188854' ,'4228080' ,'4373296' ,'4544911' ,'4653027' ,'4773293' ,'5066353' ,'4428056' ,'4634379' ,'4544879'
										 ,'5066320' ,'7226660' ,'8888888' ,'9062727' ,'10015566'  ,'12807777', '14488556','17774746' );
										 SELECT decode(bug_number
											,'2398780', 'HXT.D'
											,'2613123', 'HXT.D.1'
											,'2614545', 'HXT.D.2'
											,'2821443', 'HXT.D.3'
											,'2716711', 'HXT.E'
											,'3042947', 'HXT.F'
											,'3056938', 'HXT.F Cons#1'
											,'3438088', 'HXT.F Rollup 2'
											,'3604603', 'HXT.F Rollup 3'
											,'3621576', 'HXT.F Rollup 4'
											,'3634044', 'HXT.F Rollup 5'
											,'3664795', 'HXT.F Rollup 6'
											,'3686163', 'HXT.F Rollup 7/8'
											,'3763776', 'HXT.F Rollup 9'
											,'3838434', 'HXT.F Rollup 10'
											,'3803131', 'HXT.F Rollup 11'
											,'3939443', 'HXT.F Rollup 12'
											,'3285055', 'HXT.G'
											,'3561162', 'HXT.G Rollup 1'
											,'3623577', 'HXT.G Rollup 2'
											,'3634007', 'HXT.G Rollup 3'
											,'3664800', 'HXT.G Rollup 4'
											,'3718653', 'HXT.G Rollup 5'
											,'3838319', 'HXT.G Rollup 6'
											,'3803130', 'HXT.G Rollup 7'
											,'3882104', 'HXT.G Rollup 8'
											,'4042676', 'HXT.G Rollup 9'
											,'4067571', 'HXT.G Rollup 10'
											,'4105173', 'HXT.G Rollup 11'
											,'4220319', 'HXT.G Rollup 12'
											,'4298433', 'HXT.G Rollup 13'
											,'4373216', 'HXT.G Rollup 14'
											,'3530830', 'HXT.H'
											,'4057588', 'HXT.H Rollup 1'
											,'4045358', 'HXT.H Rollup 2'
											,'4373214', 'HXT.H Rollup 3'
											,'4544887', 'HXT.H Rollup 4'
											,'4653019', 'HXT.H Rollup 5'
											,'4773290', 'HXT.H Rollup 6'
											,'4188854', 'HXT.I'
											,'4228080', 'HXT.I Rollup 1'
											,'4373296', 'HXT.I Rollup 2'
											,'4544911', 'HXT.I Rollup 3'
											,'4653027', 'HXT.I Rollup 4'
											,'4773293', 'HXT.I Rollup 5'
											,'5066353', 'HXT.I Rollup 6'
											,'4428056', 'HXT.J'
											,'4634379', 'HXT.J Rollup 1'
											,'4544879', 'HXT.11i Rollup 1'
											,'5066320', 'HXT.11i Rollup 2'
											,'7226660', 'HXT.11i Rollup 3'
											,'8888888', 'HXT.11i Rollup 4'
											,'9062727', 'HRMS RUP5'
										 ,'10015566', 'HRMS RUP6'
										 ,'12807777', 'HRMS RUP7'
										 ,'14488556', 'HRMS RUP8'
										 ,'17774746', 'HRMS RUP9'
											)  
										  into :hxt_patch
										  FROM ad_bugs 
										  WHERE BUG_NUMBER =rup_level and rownum < 2;
					end if;				
					 if upper('&&1') = 'Y' then
					    	l_o('<DIV class=divItem><a name="sum"></a>');
							l_o('<DIV id="s1sql0b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql0'');" href="javascript:;">&#9654; Instance Summary</A></DIV>');

							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql0" style="display:none" >');
							l_o(' <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF">');
							l_o('   <TH COLSPAN=5 bordercolor="#DEE6EF"><font face="Calibri">');
							l_o('     <B>Instance Summary</B></font></TD></TR>');
							l_o('<TR><TD>Instance Name = '||:sid||'<br>');
							l_o('Instance Creation Date = '||v_crtddt||'<br>');
							l_o('Server/Platform = '||:platform||'<br>');
							l_o('Language/Characterset = '||db_lang||' / '||db_charset||'<br>');
							l_o('Database = '||database_version||'<br>');
							l_o('Applications = '||:apps_rel||'<br>');
							l_o('Workflow = '||v_wfVer||'<br>');
							l_o('PER '||hr_status||'<br>');
							l_o('PAY '||pay_status||'<br>');
							l_o('HXT '||:hxt_status||' '||:hxt_patch||'<br>');
							l_o('HXC '||:hxc_status||' '||:hxc_patch||'<br><br>');
							l_o(:rup_level_n|| ' applied on ' || :rup_date ||'<br>');
							l_o('<br>Installed legislations<br>');
							l_o('Code   Application');
							l_o('<br>-------------------<br>');
							for l_rec in legislations loop
							l_o(l_rec.leg||'   '||l_rec.application||'<br>');
							end loop;
							
							l_o(' </TABLE> </div> ');
							
							l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						
						l_o('<DIV class=divItem><a name="db"></a>');
						l_o('<DIV id="s1sql1b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql1'');" href="javascript:;">&#9654; Database Details</A></DIV>');	

						l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql1" style="display:none" ><TR>');						
						l_o('   <TH COLSPAN=5 bordercolor="#DEE6EF"><font face="Calibri">');
						l_o('     <B>Database details</B></font></TD>');
						l_o('     <TH bordercolor="#DEE6EF">');
						l_o('<A class=detail id="s1sql2b" onclick="displayItem2(this,''s1sql2'');" href="javascript:;">&#9654; Show SQL Script</A>');
						l_o('   </TD>');
						l_o(' </TR>');
						l_o(' <TR id="s1sql2" style="display:none">');
						l_o('    <TD colspan="5" height="60">');
						l_o('       <blockquote><p align="left">');
					    l_o('          SELECT upper(instance_name), host_name<br>');
						l_o('          	FROM   fnd_product_groups, v$instance;<br>');
						l_o('        SELECT SUBSTR(REPLACE(REPLACE(pcv1.product, ''TNS for ''), '':'' )||pcv2.status, 1, 80)<br>');
						l_o('            	FROM product_component_version pcv1,<br>');
						l_o('                   product_component_version pcv2<br>');
						l_o('             	WHERE UPPER(pcv1.product) LIKE ''%TNS%''<br>');
						l_o('               	AND UPPER(pcv2.product) LIKE ''%ORACLE%''<br>');
						l_o('               	AND ROWNUM = 1;<br>');
						l_o('        SELECT banner from V$VERSION WHERE ROWNUM = 1;<br>');
						l_o('        SELECT value FROM V$NLS_PARAMETERS WHERE parameter in (''NLS_LANGUAGE'',''NLS_CHARACTERSET'');');
					    l_o('          </blockquote><br>');
						l_o('     </TD>');
						l_o('   </TR>');
						l_o(' <TR>');
						l_o(' <TH><B>Hostname</B></TD>');
						l_o(' <TH><B>Platform</B></TD>');
						l_o(' <TH><B>Sid</B></TD>');
						l_o(' <TH><B>Database version</B></TD>');
						l_o(' <TH><B>Language</B></TD>');
					    l_o(' <TH><B>Character set</B></TD>');
						l_o('<TR><TD>'||:host||'</TD>'||chr(10)||'<TD>'||:platform||'</TD>'||chr(10));
					    l_o('<TD>'||:sid||'</TD>'||chr(10)||'<TD>'||database_version||'</TD>'||chr(10)||'<TD>'||db_lang||'</TD>'||chr(10)||'<TD>'||db_charset ||'</TD></TR>'||chr(10));	 	
					    :n := (dbms_utility.get_time - :n)/100;
						l_o(' <TR><TH COLSPAN=5 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE> </div> ');
						if :apps_rel like '11.5%' and (database_version like '9.2%' or database_version like '10.1%' or database_version like '10.2.0.2%' or database_version like '10.2.0.3%' or database_version like '11.1.0.6%') then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Minimum Requirements: Database 10.2.0.4 or 11.1.0.7!<br>');
							l_o('Review <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=883202.1" target="_blank">Doc ID 883202.1</a> Patch Requirements for Sustaining Support for Oracle E-Business Suite Release 11.5.10<br>');
							l_o('</div><br><br>');
							:w1:=:w1+1;
						elsif :apps_rel like '12.0%' and (database_version like '9.2%' or database_version like '10.1%' or database_version like '10.2.0.2%' or database_version like '10.2.0.3%' or database_version like '10.2.0.4%' or database_version like '11.1.0.6%' or database_version like '11.2.0.1%') then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Minimum Requirements: Oracle Database 10.2.0.5, 11.1.0.7, or 11.2.0.2!<br>');
							l_o('Review <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1334562.1" target="_blank">Doc ID 1334562.1</a> Minimum Patch Requirements for Extended Support of Oracle E-Business Suite Human Capital Management (HCM) Release 12.0<br>');
							l_o('</div><br><br>');
							:w1:=:w1+1;
						end if;
	
						l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
					end if;
					  
					  :n := dbms_utility.get_time;  
					  
						
					if upper('&&1') = 'Y' then		   
					    l_o('<DIV class=divItem><a name="apps"></a>');
						l_o('<DIV id="s1sql3b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql3'');" href="javascript:;">&#9654; Application Details</A></DIV>');
	
						l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql3" style="display:none" ><TR>');
						l_o('   <TH COLSPAN=2 bordercolor="#DEE6EF">');
						l_o('     <B>Application details</B></font></TD>');
						l_o('     <TH bordercolor="#DEE6EF">');
						l_o('<A class=detail id="s1sql4b" onclick="displayItem2(this,''s1sql4'');" href="javascript:;">&#9654; Show SQL Script</A>');
						l_o('   </TD>');
						l_o(' </TR>');
						l_o(' <TR id="s1sql4" style="display:none">');
						l_o('    <TD colspan="2" height="60">');
						l_o('       <blockquote><p align="left">');
					    l_o('          SELECT RELEASE_NAME from FND_PRODUCT_GROUPS;<br>');
					    l_o('          SELECT MULTI_ORG_FLAG,MULTI_CURRENCY_FLAG FROM FND_PRODUCT_GROUPS;<br>');
					    l_o('          SELECT V.APPLICATION_ID, L.MEANING  <br>');
					    l_o('              FROM FND_APPLICATION_ALL_VIEW V, FND_PRODUCT_INSTALLATIONS I, FND_LOOKUPS L<br>');
					    l_o('              WHERE (V.APPLICATION_ID = I.APPLICATION_ID)<br>');
					    l_o('                AND (V.APPLICATION_ID in (''800'',''801'',''808'',''809''))<br>');
					    l_o('                AND (L.LOOKUP_TYPE = ''FND_PRODUCT_STATUS'')<br>');
					    l_o('               AND (L.LOOKUP_CODE = I.Status);<br>');
					    l_o('          </blockquote><br>');
						l_o('     </TD>');
						l_o('   </TR>');
						l_o(' <TR>');
						l_o(' <TH><B>Release</B></TD>');
						l_o(' <TH><B>MultiOrg Flag</B></TD>');
						l_o(' <TH><B>MultiCurrency Flag</B></TD>');						
						l_o('<TR><TD>'||:APPS_REL||'</TD>'||chr(10)||'<TD>'||multiOrg||'</TD>'||chr(10));
						l_o('<TD>'||multiCurr||'</TD></TR>'||chr(10));	 	
						:n := (dbms_utility.get_time - :n)/100;						
						l_o(' <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE> </div> ');
						if :apps_rel like '11.5%' then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Please note that statutory legislative support expired on November 30th 2013');
							l_o(', please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1384995.1" target="_blank">Doc ID 1384995.1</a> ');
							l_o(' When Is Statutory Legislative Support for Payroll Going To End For Release 11i<br></div>');
							:w1:=:w1+1;
						end if;
						l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
					end if;	
						
					if upper('&&1') = 'Y' then
						l_o('<DIV class=divItem><a name="products"></a>');
						l_o('<DIV id="s1sql5b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql5'');" href="javascript:;">&#9654; Products Status</A></DIV>');

						l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql5" style="display:none" ><TR>');
						l_o('   <TH COLSPAN=4 bordercolor="#DEE6EF">');
						l_o('     <B>Applications Status</B></font></TD>');
						l_o('     <TH bordercolor="#DEE6EF">');
						l_o('<A class=detail id="s1sql6b" onclick="displayItem2(this,''s1sql6'');" href="javascript:;">&#9654; Show SQL Script</A>');
						l_o('   </TD>');
						l_o(' </TR>');
						l_o(' <TR id="s1sql6" style="display:none">');
						l_o('    <TD colspan="4" height="60">');
						l_o('       <blockquote><p align="left">');
						l_o('        select v.application_name , v.application_short_name  <br>');     
						l_o('        , to_char(v.application_id) <br>');
						l_o('        , l.meaning    <br>');             
						l_o('        , decode(i.patch_level, null, ''11i.'' || v.application_short_name || ''.?'', i.patch_level) <br>');
						l_o('        from fnd_application_all_view v, fnd_product_installations i, fnd_lookups l<br>');
						l_o('        where (v.application_id = i.application_id)<br>');
						l_o('        and (v.application_id in <br>');
						l_o('         (''0'', ''50'', ''178'', ''275'', ''426'', ''453'', ''800'', ''801'', ''802'', ''803'', ''804'', ''805'', ''808'', ''809'', ''810'', ''8301'', ''8302'', ''8303''))<br>');
						l_o('        and (l.lookup_type = ''FND_PRODUCT_STATUS'')<br>');
						l_o('        and (l.lookup_code = i.status )');
						l_o('        order by upper(v.application_name);');
						l_o('          </blockquote><br>');
						l_o('     </TD>');
						l_o('   </TR>');
						l_o(' <TR>');
						l_o(' <TH><B>Application</B></TD>');
						l_o(' <TH><B>Short Name</B></TD>');
						l_o(' <TH><B>Code</B></TD>');
						l_o(' <TH><B>Status</B></TD>');
						l_o(' <TH><B>Patchset</B></TD>');
							
						:n := dbms_utility.get_time;
						open products;
						loop
							  fetch products into v_appl,v_appls,v_applid,v_status,v_patch;
							  EXIT WHEN  products%NOTFOUND;
							  l_o('<TR><TD>'||v_appl||'</TD>'||chr(10)||'<TD>'||v_appls||'</TD>'||chr(10));
							  
							  if v_appls='HXC' and :APPS_REL like '12.%'  then
									l_o('<TD>'||v_applid||'</TD>'||chr(10)||'<TD>'||v_status||'</TD>'||chr(10)||'<TD>-</TD> </TR>'||chr(10));
							  elsif v_appls='HXT' and :APPS_REL like '11.%'  then
									l_o('<TD>'||v_applid||'</TD>'||chr(10)||'<TD>'||v_status||'</TD>'||chr(10)||'<TD>'||:hxt_patch||'</TD> </TR>'||chr(10));
							  else
									l_o('<TD>'||v_applid||'</TD>'||chr(10)||'<TD>'||v_status||'</TD>'||chr(10)||'<TD>'||v_patch||'</TD> </TR>'||chr(10));
							  end if;				  
							  
						end loop;
						close products;
						
						:n := (dbms_utility.get_time - :n)/100;
						l_o(' <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE> </div> ');
						
						if upper(:hxt_status)<>'INSTALLED' then
								l_o('<div class="diverr" id="sig1"><img class="error_ico"><font color="red">Error:</font> Product "Time and Labor" (HXT) is not installed at your instance. Please ask your DBA to use License Manager to install the product to avoid many potential issues in the application.<br></div>');
								:e1:=:e1+1;
						end if;	
							
						l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
					end if;
	  
EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
					end;
					
-- Display languages installed (NLS)
procedure languages is
				lang number;
				v_lang_code FND_LANGUAGES.LANGUAGE_CODE%type;
				v_flag varchar2(25);
				v_language FND_LANGUAGES.NLS_LANGUAGE%type;
				cursor languages is
				SELECT LANGUAGE_CODE ,  
						 decode(INSTALLED_FLAG ,'B','Base language','I','Installed language'),
						 NLS_LANGUAGE
				  FROM FND_LANGUAGES 
				  where INSTALLED_FLAG in ('B','I')
				  order by LANGUAGE_CODE;
				begin
						select count(1) into lang from FND_LANGUAGES 
						where INSTALLED_FLAG in ('B','I') ;
    
                                  l_o('<DIV class=divItem><a name="nls"></a>');
								  l_o('<DIV id="s1sql27b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql27'');" href="javascript:;">&#9654; Installed Languages</A></DIV>');
                                  l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql27" style="display:none" >');
                                  l_o('   <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
                                  l_o('     <B>Languages:</B></font></TD>');
                                  l_o('     <TH bordercolor="#DEE6EF">');
                                  l_o('<A class=detail id="s1sql28b" onclick="displayItem2(this,''s1sql28'');" href="javascript:;">&#9654; Show SQL Script</A>');
                                  l_o('   </TD>');
                                  l_o(' </TR>');
                                  l_o(' <TR id="s1sql28" style="display:none">');
                                  l_o('    <TD colspan="2" height="60">');
                                  l_o('       <blockquote><p align="left">');
                                  l_o('          SELECT LANGUAGE_CODE , <br>');                                   
                                  l_o('                 decode(INSTALLED_FLAG ,''B'',''Base language'',''I'',''Installed language''),<br>'); 
                                  l_o('                 NLS_LANGUAGE<br>'); 
                                  l_o('                FROM FND_LANGUAGES <br>'); 
                                  l_o('                where INSTALLED_FLAG in (''B'',''I'')<br>'); 
                                  l_o('                order by LANGUAGE_CODE;<br>'); 
                                  l_o('          </blockquote><br>');
                                  l_o('     </TD>');
                                  l_o('   </TR>');
                                  l_o(' <TR>');
                                  l_o(' <TH><B>Code</B></TD>');
                                  l_o(' <TH><B>Flag</B></TD>');
                                  l_o(' <TH><B>Language</B></TD>');
	
                                  :n := dbms_utility.get_time;
                              
                                  open languages;
                                  loop
                                        fetch languages into v_lang_code, v_flag, v_language;
                                        EXIT WHEN  languages%NOTFOUND;
                                        l_o('<TR><TD>'||v_lang_code||'</TD>'||chr(10)||'<TD>'||v_flag||'</TD>'||chr(10)||'<TD>'||v_language||'</TD></TR>'||chr(10));
                                  end loop;
                                  close languages;
                                  
                                 
                                  :n := (dbms_utility.get_time - :n)/100;
                                  l_o(' <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
                                  l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
                                  l_o(' </TABLE> </div> ');
						if lang>1 then                         
                                  l_o('<div class="divok">');    
								  l_o('<span class="sectionblue1">Advice: </span> Periodically check if you NLS level is in sync with US level:<br>');
                                  l_o('Follow <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=252422.1" target="_blank" >Doc ID 252422.1</a> ');
								  l_o('Requesting Translation Synchronization Patches<br>');
                                  l_o('-> this will synchronize your languages with actual US level<br>');
                                  l_o('Note! This is just an advice. This does not mean your NLS is not synchronized! Follow this step ONLY if you have translation issues.<br>');								  
								  l_o('</div>');
						end if;

						l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display Patching status: HRMS RUP				
procedure patching is
				rup_level varchar2(20);
				v_date ad_bugs.LAST_UPDATE_DATE%type;
				v_exists number;
				begin
					  :issuep:=0;
					  l_o(' <a name="patching"></a>'); 
					  l_o('<a name="rup"></a>');
					  l_o('<a name="pj"></a>');
					  l_o('<a name="atg"></a>');

					  l_o('<a name="hrglobal"></a>');
					  
					l_o('<DIV class=divItem>');
					l_o('<DIV id="s1sql29b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql29'');" href="javascript:;">&#9654; Patching Status</A></DIV>');
                      l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql29" style="display:none" >');
					  
					  l_o(' <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF"><th><b>Section</b></td><th><b>Status and advices</b></td></tr>');
					  
					  l_o(' <TR><td>HRMS</td><td>');
					  
					if :apps_rel like '12.2%' then
							SELECT max(to_number(adb.bug_number)) into rup_level FROM ad_bugs adb
							WHERE adb.bug_number in ('21507777','20000400','19193000','17909898','17050005','17001123','16169935','14040707','10124646');            
								 
							if rup_level='21507777' then
								  
								  l_o('Patch 21507777 R12.HR_PF.C.delta.8 <br><br>');
								
								  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=2113772.1" target="_blank"> Doc ID 2113772.1</a> ');
								   l_o('Known Issues on Top of Patch 21507777 - R12.HR_PF.C.DELTA.8 (HRMS 12.2 RUP8) <br><br>');
								 	l_o('</span>');
							else
								   SELECT DECODE(bug_number
								  ,'17001123', 'R12.HR_PF.C.delta.3'    
								  , '16169935', 'R12.HR_PF.C.delta.2'
								  ,'14040707', 'R12.HR_PF.C.delta.1'
								  ,'10124646', 'R12.HR_PF.C'
								  ,'17050005', 'R12.HR_PF.C.Delta.4'
								  ,'17909898', 'R12.HR_PF.C.delta.5'
								  ,'19193000', 'R12.HR_PF.C.Delta.6'
								  ,'20000400', 'R12.HR_PF.C.Delta.7'
								   ) 
								, LAST_UPDATE_DATE    
								  into :rup_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =rup_level and rownum < 2;
								  
								  l_o('Patch ' || rup_level || ' ' || :rup_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<div class="divwarn" id="sig6">');
								  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=21507777">');
								  l_o('Patch 21507777</a>R12.HR_PF.C.delta.8<br>');
								  l_o('</div>');
								  :issuep:=1;
								  :w1:=:w1+1;											  
								  
							end if;
							select decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into rup_level
										FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L							
										  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
											AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
											AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US' and rownum < 2;
							l_o(' </td></tr><TR><td>OTL</td><td>');
							l_o(rup_level||'<br>');
					
							
					  elsif :apps_rel like '12.1%' then
									   
							select max(to_number(bug_number)) into rup_level from ad_bugs 
							WHERE BUG_NUMBER IN ('21980909','20000288','18004477','16000686','13418800','10281212','9114911','8337373', '7446767', '6603330');             
								 
							if rup_level='21980909' then
								  
								  l_o('Patch 21980909 R12.HR_PF.B.delta.9<br><br>');
								  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=2113768.1" target="_blank"> Doc ID 2113768.1</a> ');
								  l_o('Known Issues on Top of Patch 21980909 - R12.HR_PF.B.DELTA.9 (HRMS 12.1 RUP9)<br><br>');
								  select count(1) into v_exists from ad_bugs where bug_number='21792239';
								  if v_exists=0 then
									  :issuep:=1;
									  :w1:=:w1+1;
									  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please apply Patch 21792239 XFER FROM OTL TO BEE DOES NOT PROCESS SUSPENDED ASSIGNMENTS');
								  end if;
								  select count(1) into v_exists from ad_bugs where bug_number='21756000';
								  if v_exists=0 then
									  :issuep:=1;
									  :w1:=:w1+1;
									  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please apply Patch 21756000 ATMPTNG TO OPN PUI TC: ERR: APP-HXT-39163: FRM - 40105');
								  end if;
																  
							else
								  SELECT DECODE(BUG_NUMBER
								  ,'18004477', 'R12.HR_PF.B.delta.7'
								  ,'16000686', 'R12.HR_PF.B.delta.6'    
								  , '13418800', 'R12.HR_PF.B.delta.5'
								  ,'10281212', 'R12.HR_PF.B.delta.4'
								  ,'9114911', 'R12.HR_PF.B.delta.3'
								  ,'8337373', 'R12.HR_PF.B.delta.2'
								  ,'7446767', 'R12.HR_PF.B.delta.1'
								  ,'6603330', 'R12.HR_PF.B'
								   ) 
								, LAST_UPDATE_DATE   
								  into :rup_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =rup_level and rownum < 2;
								  
								  l_o('Patch ' || rup_level || ' ' || :rup_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<div class="divwarn" id="sig6">');
								  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=21980909">Patch 21980909</a> R12.HR_PF.B.delta.9<br>');
								  l_o('</div>');
								  :issuep:=1;
								  :w1:=:w1+1;
							end if; 
							select decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into rup_level
										FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L								
										  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
											AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
											AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US' and rownum < 2;
							l_o(' </td></tr><TR><td>OTL</td><td>');
							l_o(rup_level||'<br>');
							
					   elsif :APPS_REL like '12.0%' then
							select max(to_number(bug_number)) into rup_level from ad_bugs 
							WHERE BUG_NUMBER IN ('16077077','13774477','10281209','9301208','7577660', '7004477', '6610000', '6494646', '6196269', '5997278', '5881943', '4719824');
							
							if rup_level='16077077' then
								 
								  l_o('Patch 16077077 R12.HR_PF.A.delta.11<br><br>');
								 
								  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1538635.1" target="_blank"> Doc ID 1538635.1</a> ');
								  l_o('Known Issues on Top of Patch 16077077 - r12.hr_pf.a.delta.11<br>');
							else
								  SELECT DECODE(BUG_NUMBER
								  , '16077077', 'R12.HR_PF.A.delta.11'
								  , '13774477', 'R12.HR_PF.A.delta.10'
								  , '10281209', 'R12.HR_PF.A.delta.9'
								  , '9301208', 'R12.HR_PF.A.delta.8'
								  , '7577660', 'R12.HR_PF.A.delta.7'
								  , '7004477', 'R12.HR_PF.A.delta.6'
								  , '6610000', 'R12.HR_PF.A.delta.5'
								  , '6494646', 'R12.HR_PF.A.delta.4'
								  , '6196269', 'R12.HR_PF.A.delta.3'
								  , '5997278', 'R12.HR_PF.A.delta.2'
								  , '5881943', 'R12.HR_PF.A.delta.1'
								  , '4719824', 'R12.HR_PF.A')
								  , LAST_UPDATE_DATE  
								  into :rup_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =rup_level and rownum < 2;
								  
								  l_o('Patch ' || rup_level || ' ' || :rup_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<div class="divwarn" id="sig6">');
								  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=16077077">Patch 16077077</a> R12.HR_PF.A.delta.11<br>');
								  l_o('</div>');
								  :issuep:=1;
								  :w1:=:w1+1;
							end if;   
							select decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into rup_level
										FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L							
										  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
											AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
											AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US' and rownum < 2;
							l_o(' </td></tr><TR><td>OTL</td><td>');
							l_o(rup_level||'<br>');
							
							
					   elsif   :APPS_REL like '11.5%' then   
							select count(1) into v_exists from ad_bugs 
							WHERE BUG_NUMBER IN ('2803988','2968701','3116666','3233333','3127777','3333633',
						   '3500000','5055050','5337777','6699770','7666111','9062727','10015566','12807777','14488556','17774746');
							
							if v_exists=0 then
									:e1:=:e1+1;
									l_o('<div class="diverr"  id="sig6">');
									l_o('<img class="error_ico"><font color="red">Error:</font> No RUP patch applied!<br><br>');
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=17774746">Patch 17774746</a> HR_PF.K.RUP.9<br>');
									l_o('</div>');
							else        
									select max(to_number(bug_number)) into rup_level from ad_bugs 
									WHERE BUG_NUMBER IN ('2803988','2968701','3116666','3233333','3127777','3333633',
								   '3500000','5055050','5337777','6699770','7666111','9062727','10015566','12807777','14488556','17774746');
									if rup_level='17774746' then
										 
										  l_o('Patch 17774746 HR_PF.K.RUP.9<br><br>');
										  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
										  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1636768.1" target="_blank"> Doc ID 1636768.1</a> ');
										  l_o('Known Issues on Top of Patch 17774746 - 11i.hr_pf.k.delta.9 (HRMS 11i RUP9)');                    
										  
									else
										  SELECT DECODE(BUG_NUMBER
										   , '2803988', 'HRMS_PF.E'
										   , '2968701', 'HRMS_PF.F'
										   , '3116666', 'HRMS_PF.G'
										   , '3233333', 'HRMS_PF.H'
										   , '3127777', 'HRMS_PF.I'
										   , '3333633', 'HRMS_PF.J'
										   , '3500000', 'HRMS_PF.K'
										   , '5055050', 'HR_PF.K.RUP.1'
										   , '5337777', 'HR_PF.K.RUP.2'
										   , '6699770', 'HR_PF.K.RUP.3'
										   , '7666111', 'HR_PF.K.RUP.4'
										   , '9062727', 'HR_PF.K.RUP.5'
										   , '10015566', 'HR_PF.K.RUP.6'
										   , '12807777', 'HR_PF.K.RUP.7'
										   , '14488556', 'HR_PF.K.RUP.8'
										   , '17774746', 'HR_PF.K.RUP.9'
											)  
										, LAST_UPDATE_DATE  
										  into :rup_level_n, v_date
										  FROM ad_bugs 
										  WHERE BUG_NUMBER =rup_level and rownum < 2;
										  
										  l_o('Patch ' || rup_level || ' ' || :rup_level_n || ' applied on ' || v_date || '<br><br>');
										  l_o('<div class="divwarn"  id="sig6">');
										  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=17774746">Patch 17774746</a> HR_PF.K.RUP.9<br>');
										  l_o('</div>');
										  :issuep:=1;
										  :w1:=:w1+1;
									end if;                   
							end if;   
							select max(to_number(bug_number)) into rup_level from ad_bugs 
									WHERE BUG_NUMBER IN  ('2398780','2613123' ,'2614545' ,'2821443' ,'2716711' ,'3042947' ,'3056938' ,'3438088' ,'3604603' ,'3621576'
									,'3634044' ,'3664795' ,'3686163' ,'3763776' ,'3838434' ,'3803131' ,'3939443' ,'3285055' ,'3561162' ,'3623577' ,'3634007' ,'3664800' ,'3718653'
									,'3838319'  ,'3803130' ,'3882104' ,'4042676' ,'4067571' ,'4105173'  ,'4220319' ,'4298433' ,'4373216' ,'3530830' ,'4057588' ,'4045358' ,'4373214'
									 ,'4544887' ,'4653019' ,'4773290' ,'4188854' ,'4228080' ,'4373296' ,'4544911' ,'4653027' ,'4773293' ,'5066353' ,'4428056' ,'4634379' ,'4544879'
									 ,'5066320' ,'7226660' ,'8888888' ,'9062727' ,'10015566'  ,'12807777', '14488556','17774746' );
									 SELECT decode(bug_number
											,'2398780', 'HXT.D'
											,'2613123', 'HXT.D.1'
											,'2614545', 'HXT.D.2'
											,'2821443', 'HXT.D.3'
											,'2716711', 'HXT.E'
											,'3042947', 'HXT.F'
											,'3056938', 'HXT.F Cons#1'
											,'3438088', 'HXT.F Rollup 2'
											,'3604603', 'HXT.F Rollup 3'
											,'3621576', 'HXT.F Rollup 4'
											,'3634044', 'HXT.F Rollup 5'
											,'3664795', 'HXT.F Rollup 6'
											,'3686163', 'HXT.F Rollup 7/8'
											,'3763776', 'HXT.F Rollup 9'
											,'3838434', 'HXT.F Rollup 10'
											,'3803131', 'HXT.F Rollup 11'
											,'3939443', 'HXT.F Rollup 12'
											,'3285055', 'HXT.G'
											,'3561162', 'HXT.G Rollup 1'
											,'3623577', 'HXT.G Rollup 2'
											,'3634007', 'HXT.G Rollup 3'
											,'3664800', 'HXT.G Rollup 4'
											,'3718653', 'HXT.G Rollup 5'
											,'3838319', 'HXT.G Rollup 6'
											,'3803130', 'HXT.G Rollup 7'
											,'3882104', 'HXT.G Rollup 8'
											,'4042676', 'HXT.G Rollup 9'
											,'4067571', 'HXT.G Rollup 10'
											,'4105173', 'HXT.G Rollup 11'
											,'4220319', 'HXT.G Rollup 12'
											,'4298433', 'HXT.G Rollup 13'
											,'4373216', 'HXT.G Rollup 14'
											,'3530830', 'HXT.H'
											,'4057588', 'HXT.H Rollup 1'
											,'4045358', 'HXT.H Rollup 2'
											,'4373214', 'HXT.H Rollup 3'
											,'4544887', 'HXT.H Rollup 4'
											,'4653019', 'HXT.H Rollup 5'
											,'4773290', 'HXT.H Rollup 6'
											,'4188854', 'HXT.I'
											,'4228080', 'HXT.I Rollup 1'
											,'4373296', 'HXT.I Rollup 2'
											,'4544911', 'HXT.I Rollup 3'
											,'4653027', 'HXT.I Rollup 4'
											,'4773293', 'HXT.I Rollup 5'
											,'5066353', 'HXT.I Rollup 6'
											,'4428056', 'HXT.J'
											,'4634379', 'HXT.J Rollup 1'
											,'4544879', 'HXT.11i Rollup 1'
											,'5066320', 'HXT.11i Rollup 2'
											,'7226660', 'HXT.11i Rollup 3'
											,'8888888', 'HXT.11i Rollup 4'
											,'9062727', 'HRMS RUP5'
										 ,'10015566', 'HRMS RUP6'
										 ,'12807777', 'HRMS RUP7'
										 ,'14488556', 'HRMS RUP8'
										 ,'17774746', 'HRMS RUP9'
											)
										, LAST_UPDATE_DATE  
										  into :rup_level_n, v_date
										  FROM ad_bugs 
										  WHERE BUG_NUMBER =rup_level and rownum < 2;
							l_o(' </td></tr><TR><td>OTL</td><td>');
							l_o('Patch ' || rup_level || ' ' || :rup_level_n || ' applied on ' || v_date || '<br><br>');
							if to_number(rup_level) < 7226660 then
										  l_o('<div class="divwarn">');
										  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> As per E-Business Suite 11.5.10 Minimum Patch Level and Extended Support Information Center ');
										  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1199724.1" target="_blank"> Doc ID 1199724.1</a>,<br> ');
										  l_o('the OTL 11.5.10 Extended Support and Production Severity 1 issues minimum baseline requirement is HXT.11i.Rollup3 (Patch.7226660).<br> ');  
										  l_o('Additionally, we strongly encourage that you go to OTL''s latest best code provided by us which is included in HRMS Rup9 (Patch 17774746).<br>');
										  l_o('</div>');
										  :issuep:=1;
										  :w1:=:w1+1;
							 end if;             
					  elsif   :APPS_REL like '12.2%' then 		
						  select decode(i.patch_level, null, '11i.' || b.application_short_name || '.?', i.patch_level)  into rup_level
										FROM fnd_application b, fnd_application_tl t, FND_PRODUCT_INSTALLATIONS I, fnd_lookup_values L								
										  WHERE (b.APPLICATION_ID = I.APPLICATION_ID)  AND b.application_id = t.application_id
											AND (b.APPLICATION_ID = '808')	AND (L.LOOKUP_TYPE = 'FND_PRODUCT_STATUS')
											AND (L.LOOKUP_CODE = I.Status)	AND t.language = 'US'	AND l.language = 'US' and rownum < 2;
							l_o(' -</td></tr><TR><td>OTL</td><td>');
							l_o(rup_level||'<br>');
					   
					  end if;
					  l_o('</td></tr>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display Projects patching level				
procedure projects_paching is
				pj_level varchar2(20);
				pj_level_n varchar2(50);
				v_date ad_bugs.LAST_UPDATE_DATE%type;
				v_exists number;
				begin
					  l_o(' <TR><td>Projects</td><td>');
					 if :APPS_REL like '12.2%' then
							select max(to_number(bug_number)) into pj_level from ad_bugs 
							WHERE BUG_NUMBER IN ('16188964','17027643','17934640','19677790');            
							
							
							if pj_level='19677790' then                 
									 l_o('<img class="check_ico">OK! You are at latest level: Patch 19677790 (R12.PJ_PF.C.DELTA.5) Projects Upd Pack 5.<br><br>');							  
								  
							else
								  SELECT DECODE(BUG_NUMBER,
								 '16188964', 'R12.PJ_PF.C.DELTA.2',
								'17027643', 'R12.PJ_PF.B.DELTA.3',
								'17934640', 'R12.PJ_PF.B.DELTA.4',
							   '19677790', 'R12.PJ_PF.B.DELTA.5')
								, LAST_UPDATE_DATE   
								  into pj_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =pj_level and rownum < 2;
								  
								  l_o('Patch ' || pj_level || ' ' || pj_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('Latest PJ level is: <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=19677790">Patch 19677790</a> R12.PJ_PF.C.DELTA.5<br>');
								  
							end if; 					 
					  elsif :APPS_REL like '12.1%' then
									   
							select max(to_number(bug_number)) into pj_level from ad_bugs 
							WHERE BUG_NUMBER IN ('7456340','8504800','9147711','12378114','14162290','17839156','22687240');            
							
							
							if pj_level='22687240' then                 
									 l_o('<img class="check_ico">OK! You are at latest level: Patch 22687240 (R12.PJ_PF.B.DELTA.7) Projects Upd Pack 7 for 12.1.<br><br>');							  
								  
							else
								  SELECT DECODE(BUG_NUMBER,
								 '7456340', '(R12.PJ_PF.B.DELTA.1) Projects Upd Pack 1 for 12.1',
								'8504800', '(R12.PJ_PF.B.DELTA.2) Projects Upd Pack 2 for 12.1',
								'9147711', '(R12.PJ_PF.B.DELTA.3) Projects Upd Pack 3 for 12.1',
							   '12378114', '(R12.PJ_PF.B.DELTA.4) Projects Upd Pack 4 for 12.1',
							   '14162290', '(R12.PJ_PF.B.DELTA.5) Projects Upd Pack 5 for 12.1',
							   '17839156', '(R12.PJ_PF.B.DELTA.6) Projects Upd Pack 6 for 12.1')
								, LAST_UPDATE_DATE   
								  into pj_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =pj_level and rownum < 2;
								  
								  l_o('Patch ' || pj_level || ' ' || pj_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('Latest PJ level is: <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=22687240">Patch 22687240</a> R12.PJ_PF.B.DELTA.7<br>');
								  
							end if; 
							
					   elsif :APPS_REL like '12.0%' then
							select max(to_number(bug_number)) into pj_level from ad_bugs 
							WHERE BUG_NUMBER IN ('6022657','6266113','6512963','7292354');
							
							if pj_level='7292354' then                  
										  l_o('<img class="check_ico">OK! You are at latest level: Patch 7292354 R12.PJ_PF.A.DELTA.6.<br>');						  
												  
							else
								  SELECT DECODE(BUG_NUMBER,
								 '6022657', '(R12.PJ_PF.A.DELTA.2) Projects Update Pack 2',
								'6266113', '(R12.PJ_PF.A.DELTA.3) Projects Update Pack 3',
								'6512963', '(R12.PJ_PF.A.DELTA.4) Projects Update Pack 4',
								'7292354', '(R12.PJ_PF.A.DELTA.6) Projects Update Pack 6')
								  , LAST_UPDATE_DATE  
								  into pj_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =pj_level and rownum < 2;
								
								  l_o('Patch ' || pj_level || ' ' || pj_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('Latest PJ level is:  <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=7292354">Patch 7292354</a> R12.PJ_PF.A.DELTA.6<br>');
								  
							end if;   
							
					   elsif   :APPS_REL like '11.5%' then   
							select count(1) into v_exists from ad_bugs 
							WHERE BUG_NUMBER IN ('3438354','4017300','4125550','4334965','4676589','5473858','5903765','6241631');
							
							if v_exists=0 then
									
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> No PJ patch applied!<br><br>');
									l_o('Latest PJ level is: <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=5644830">Patch 5644830</a> (11i.PJ_PF.M) Rollup 4<br>');
									:issuep:=1;
									:w1:=:w1+1;
									
							else        
									select max(to_number(bug_number)) into pj_level from ad_bugs 
									WHERE BUG_NUMBER IN ('2342093','2484626','3074777','3397153','4027334','4285356','4667949','3485155','4461989','4997599','5105878','5644830');
									if pj_level='5644830' then                          
										   l_o('<img class="check_ico">OK! You are at latest level: Patch 5644830 (11i.PJ_PF.M) Rollup 4.<br><br>');							 
																				   
									else
										  SELECT DECODE(BUG_NUMBER,
										 '2342093', 'PJ_PF:CONSOLIDATED 11.5.7 UPGRADE FIXES FOR PROJECT ACCOUNTING PRODUCT FAMILY',
										'2484626',  'FAMILY PACK 11i.PJ_PF.K',    
										'3074777',  'FAMILY PACK 11i.PJ_PF.L',        
										'3397153', '(11i.PJ_PF.L10) Projects Family Pack L10',
										'4027334', '(11.5.10) Projects Consolidated Patch for CU1',
										'4285356', '(11.5.10) Projects Consolidated Patch for CU2',
										'4667949', '(11i.PJ_PF.L10) Rollup 1',
										'3485155', '(11i.PJ_PF.M) Projects Family Pack M',
										'4461989', '(11i.PJ_PF.M) Rollup',
										'4997599', '(11i.PJ_PF.M) Rollup 2',
										'5105878', '(11i.PJ_PF.M) Rollup 3',
										'5644830', '(11i.PJ_PF.M) Rollup 4')
										, LAST_UPDATE_DATE  
										  into pj_level_n, v_date
										  FROM ad_bugs 
										  WHERE BUG_NUMBER =pj_level and rownum < 2;
										 
										  l_o('Patch ' || pj_level || ' ' || pj_level_n || ' applied on ' || v_date || '<br><br>');
										  l_o('Latest PJ level is: <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=5644830">Patch 5644830</a> (11i.PJ_PF.M) Rollup 4<br>');
										  
					   
									end if;                   
							end if;   
					  end if;      
					l_o('</td></tr>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display ATG patching level				
procedure atg_patching is
				atg_level varchar2(20);
				atg_level_n varchar2(50);
				v_date ad_bugs.LAST_UPDATE_DATE%type;
				v_exists number;
				begin
					  l_o(' <TR><td>ATG</td><td>');
					  
					  if :apps_rel like '12.2%' then
							SELECT max(to_number(adb.bug_number)) into atg_level FROM ad_bugs adb
							WHERE adb.bug_number in ('10110982','14222219','15890638','17007206','17909318','19245366');
							if atg_level='19245366' then                  
								  l_o('<b>Actual level:</b> Patch 19245366 R12.ATG_PF.C.delta.5<br><br>'); 
							else
								SELECT DECODE(BUG_NUMBER
								 , '10110982', 'R12.ATG_PF.C'
								 , '14222219', 'R12.ATG_PF.C.delta.1'
								 , '15890638', 'R12.ATG_PF.C.delta.2'
								 , '17007206', 'R12.ATG_PF.C.delta.3','17909318', 'R12.ATG_PF.C.delta.4','19245366','R12.ATG_PF.C.delta.5')
									, LAST_UPDATE_DATE   
									  into atg_level_n, v_date
									  FROM ad_bugs 
									  WHERE BUG_NUMBER =atg_level and rownum < 2;
								 l_o('<b>Actual level:</b> Patch ' || atg_level || ' ' || atg_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<div class="divwarn"  id="sig7">');
								  l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=19245366">Patch 19245366</a> ');
								  l_o('R12.ATG_PF.C.delta.5<br></div>');
								  :issuep:=1;
								  :w1:=:w1+1;
							end if;	  
					  elsif :APPS_REL like '12.1%' then
									   
							select max(to_number(bug_number)) into atg_level from ad_bugs 
							WHERE BUG_NUMBER IN ('6430106','7307198','7651091','8919491');            
								 
							if atg_level='8919491' then
								  
								  l_o('Patch 8919491 R12.ATG_PF.B.delta.3<br><br>');
								  
								  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1273640.1" target="_blank"> Doc ID 1273640.1</a> ');
								  l_o('Known ATG issues on Top of 12.1.3 - r12.atg_pf.b.delta.3, Patch 8919491');
								  
							else
								  SELECT DECODE(BUG_NUMBER
								 , '6430106', 'R12.ATG_PF.B'
								 , '7307198', 'R12.ATG_PF.B.delta.1'
								 , '7651091', 'R12.ATG_PF.B.delta.2'
								 , '8919491', 'R12.ATG_PF.B.delta.3')
								, LAST_UPDATE_DATE   
								  into atg_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =atg_level and rownum < 2;
								  
								  l_o('Patch ' || atg_level || ' ' || atg_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<img class="warn_ico"  id="sig7"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=8919491">Patch 8919491</a> R12.ATG_PF.B.delta.3<br>');
								  :issuep:=1;
								  :w1:=:w1+1;
							end if; 
							
					   elsif :APPS_REL like '12.0%' then
							select max(to_number(bug_number)) into atg_level from ad_bugs 
							WHERE BUG_NUMBER IN ('4461237','5907545','5917344','6077669','6272680','6594849','7237006');
							
							if atg_level='7237006' then
								  
								  
										  l_o('Patch 7237006 R12.ATG_PF.A.delta.6<br>');
										  l_o('<img class="check_ico">OK! You are at latest level available: Patch 7237006 R12.ATG_PF.A.delta.6.<br>');
							
							else
								  SELECT DECODE(BUG_NUMBER
								 , '4461237', 'R12.ATG_PF.A'
								 , '5907545', 'R12.ATG_PF.A.delta.1'
								 , '5917344', 'R12.ATG_PF.A.delta.2'
								 , '6077669', 'R12.ATG_PF.A.delta.3'
								 , '6272680', 'R12.ATG_PF.A.delta.4'
								 , '6594849', 'R12.ATG_PF.A.delta.5'
								 , '7237006', 'R12.ATG_PF.A.delta.6')
								  , LAST_UPDATE_DATE  
								  into atg_level_n, v_date
								  FROM ad_bugs 
								  WHERE BUG_NUMBER =atg_level and rownum < 2;
								  
								  l_o('Patch ' || atg_level || ' ' || atg_level_n || ' applied on ' || v_date || '<br><br>');
								  l_o('<img class="warn_ico"  id="sig7"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=7237006">Patch 7237006</a> R12.ATG_PF.A.delta.6<br>');
								  :issuep:=1;
								  :w1:=:w1+1;
							end if;   
							
					   elsif   :APPS_REL like '11.5%' then   
							select count(1) into v_exists from ad_bugs 
							WHERE BUG_NUMBER IN ('3438354','4017300','4125550','4334965','4676589','5473858','5903765','6241631');
							
							if v_exists=0 then
									l_o('<img class="error_ico"><font color="red">Error:</font> No ATG RUP patch applied!<br><br>');
									l_o('<img class="warn_ico"  id="sig7"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=6241631">Patch 6241631</a> 11i.ATG_PF.H RUP7<br>');
							else        
									select max(to_number(bug_number)) into atg_level from ad_bugs 
									WHERE BUG_NUMBER IN ('3438354','4017300','4125550','4334965','4676589','5473858','5903765','6241631');
									if atg_level='6241631' then
										  
										 
										  l_o('Patch 6241631 11i.ATG_PF.H RUP7<br><br>');
										  
										  l_o('<span class="sectionblue1">Advice:</span> Ensure you applied patches to fix known issues (note periodically updated): ');
										  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=858801.1" target="_blank"> Doc ID 858801.1</a> ');
										  l_o('Known Issues On Top of 11i.atg_pf.h.delta.7 (RUP7) - 6241631');                    
										  
									else
										  SELECT DECODE(BUG_NUMBER
										 , '3438354', '11i.ATG_PF.H'
										 , '4017300', '11i.ATG_PF.H RUP1'
										 , '4125550', '11i.ATG_PF.H RUP2'
										 , '4334965', '11i.ATG_PF.H RUP3'
										 , '4676589', '11i.ATG_PF.H RUP4'
										 , '5473858', '11i.ATG_PF.H RUP5'
										 , '5903765', '11i.ATG_PF.H RUP6'
										 , '6241631', '11i.ATG_PF.H RUP7')
										, LAST_UPDATE_DATE  
										  into atg_level_n, v_date
										  FROM ad_bugs 
										  WHERE BUG_NUMBER =atg_level and rownum < 2;
										  
										  l_o('Patch ' || atg_level || ' ' || atg_level_n || ' applied on ' || v_date || '<br><br>');
										  l_o('<img class="warn_ico"  id="sig7"><span class="sectionorange">Warning: </span> Please plan to install <a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num=6241631">Patch 6241631</a> 11i.ATG_PF.H RUP7<br>');
										  :issuep:=1;
										  :w1:=:w1+1;
										  
									end if;                   
							end if;   
					  end if;
					  l_o('</td></tr>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display hrglobal version				
procedure hrglobal is
				v_exists number;
				v_hrglobal_date ad_patch_runs.end_date%type;
				v_hrglobal_patch_opt ad_patch_runs.PATCH_ACTION_OPTIONS%type;
				v_hrglobal_patch ad_applied_patches.patch_name%type;
				begin
					  l_o(' <TR><td>Hrglobal</td><td>');
					  
					  if   :APPS_REL like '12%' then
							SELECT count(1) into v_exists
							FROM ad_patch_runs pr
							WHERE pr.PATCH_TOP LIKE '%/per/12.0.0/patch/115/driver'
							  AND pr.SUCCESS_FLAG = 'Y'
							  AND pr.end_date =(
							   SELECT MAX(pr.end_date)
							   FROM ad_patch_runs pr
							   WHERE pr.PATCH_TOP LIKE '%/per/12.0.0/patch/115/driver'
								 AND pr.SUCCESS_FLAG = 'Y');
					  else
							SELECT count(1) into v_exists
							FROM ad_patch_runs pr
							WHERE pr.PATCH_TOP LIKE '%/per/11.5.0/patch/115/driver'
							  AND pr.SUCCESS_FLAG = 'Y'
							  AND pr.end_date =(
							   SELECT MAX(pr.end_date)
							   FROM ad_patch_runs pr
							   WHERE pr.PATCH_TOP LIKE '%/per/11.5.0/patch/115/driver'
								 AND pr.SUCCESS_FLAG = 'Y');
					  end if;
					  
					  if v_exists>0 then
							  if   :APPS_REL like '12%' then
									  SELECT pr.end_date 
										   , pr.PATCH_ACTION_OPTIONS 
									  into v_hrglobal_date, v_hrglobal_patch_opt 
									  FROM ad_patch_runs pr
									  WHERE pr.PATCH_TOP LIKE '%/per/12.0.0/patch/115/driver'
										AND pr.SUCCESS_FLAG = 'Y'
										AND pr.end_date =(
										 SELECT MAX(pr.end_date)
										 FROM ad_patch_runs pr
										 WHERE pr.PATCH_TOP LIKE '%/per/12.0.0/patch/115/driver'
										   AND pr.SUCCESS_FLAG = 'Y');
							else
										SELECT pr.end_date 
										   , pr.PATCH_ACTION_OPTIONS 
									  into v_hrglobal_date, v_hrglobal_patch_opt 
										FROM ad_patch_runs pr
										WHERE pr.PATCH_TOP LIKE '%/per/11.5.0/patch/115/driver'
										  AND pr.SUCCESS_FLAG = 'Y'
										  AND pr.end_date =(
										   SELECT MAX(pr.end_date)
										   FROM ad_patch_runs pr
										   WHERE pr.PATCH_TOP LIKE '%/per/11.5.0/patch/115/driver'
											 AND pr.SUCCESS_FLAG = 'Y');
							end if;	 
								 
							  select ap.patch_name  patchnumber into v_hrglobal_patch
									from ad_applied_patches ap
									   , ad_patch_drivers pd
									   , ad_patch_runs pr
									   , ad_patch_run_bugs prb
									   , ad_patch_run_bug_actions prba
									   , ad_files f
									where f.file_id                  = prba.file_id
									  and prba.executed_flag         = 'Y'
									  and prba.patch_run_bug_id      = prb.patch_run_bug_id  
									  and prb.patch_run_id           = pr.patch_run_id
									  and pr.patch_driver_id         = pd.patch_driver_id
									  and pd.applied_patch_id        = ap.applied_patch_id
									  and f.filename = 'hrglobal.drv'
									  and pr.end_date = (select max(pr.end_date)
																 from ad_applied_patches ap
																	, ad_patch_drivers pd
																	, ad_patch_runs pr
																	, ad_patch_run_bugs prb
																	, ad_patch_run_bug_actions prba
																	, ad_files f
																  where f.file_id                  = prba.file_id
																	and prba.executed_flag         = 'Y'
																	and prba.patch_run_bug_id      = prb.patch_run_bug_id  
																	and prb.patch_run_id           = pr.patch_run_id
																	and pr.patch_driver_id         = pd.patch_driver_id
																	and pd.applied_patch_id        = ap.applied_patch_id
																	and f.filename = 'hrglobal.drv');

								l_o('Your date of last succesfull run of hrglobal.drv was with patch '||v_hrglobal_patch|| ' ' || v_hrglobal_patch_opt ||' on ' || v_hrglobal_date   ||'<br><br>' );
								l_o(' To identify the version please run: strings -a $PER_TOP/patch/115/driver/hrglobal.drv | grep Header <br><br>');
								l_o('<span class="sectionblue1">Advice:</span> Please periodically review (note periodically updated): ');
								if   :apps_rel like '12.2%' then
									l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1469456.1" target="_blank"> Doc ID 1469456.1</a> ');
									l_o('DATAINSTALL AND HRGLOBAL APPLICATION: 12.2 SPECIFICS<br>'); 
								else
									l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=145837.1" target="_blank"> Doc ID 145837.1</a> ');
									l_o('Latest Oracle HRMS Legislative Data Patch Available (HR Global / hrglobal)<br>');
								end if; 
					  end if;
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Data Installed issues				
procedure datainstalled is
				v_exists number;
				v_leg_code varchar2(7);
				v_apps hr_legislation_installations.application_short_name%type;
				v_action hr_legislation_installations.action%type;
				  cursor datainstaller_actions is
					  select decode(hli.legislation_code
							   ,null,'global'
							   ,hli.legislation_code) 
					   , hli.application_short_name                  
					   , hli.action                                 
				  from user_views uv
					 , hr_legislation_installations hli
				  where uv.view_name in (select view_name from hr_legislation_installations)
				  and uv.view_name = hli.view_name
				  order by legislation_code desc, application_short_name asc;
				  begin
					select count(1) into v_exists
					  from user_views uv
						 , hr_legislation_installations hli
					  where uv.view_name in (select view_name from hr_legislation_installations)
					  and uv.view_name = hli.view_name;
					  
					  if v_exists>0 then
												  :e1:=:e1+1;
												  :issuep:=1;
												   l_o('<br><A class=detail onclick="displayItem(this,''s1sql31'');" href="javascript:;"><font size="+0.5">&#9654; DataInstaller Actions - Legislations selected for Install</font></A>');
                                  				
												  l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql31" style="display:none" >');
												  l_o('   <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
												  l_o('     <B>DataInstaller Actions - Legislations selected for Install:</B></font></TD>');
												  l_o('     <TH bordercolor="#DEE6EF">');
												  l_o('<A class=detail id="s1sql32b" onclick="displayItem2(this,''s1sql32'');" href="javascript:;">&#9654; Show SQL Script</A>');
												  l_o('   </TD>');
												  l_o(' </TR>');
												  l_o(' <TR id="s1sql32" style="display:none">');
												  l_o('    <TD colspan="4" height="60">');
												  l_o('       <blockquote><p align="left">');
												  l_o('          select decode(hli.legislation_code <br>');   
												  l_o('                   ,null,''global''<br>');
												  l_o('                   ,hli.legislation_code) <br>');           
												  l_o('           , hli.application_short_name <br>');   
												  l_o('           , hli.action<br>');                  
												  l_o('      from user_views uv<br>');
												  l_o('         , hr_legislation_installations hli<br>');
												  l_o('      where uv.view_name in (select view_name from hr_legislation_installations)<br>');
												  l_o('      and uv.view_name = hli.view_name<br>');
												  l_o('      order by legislation_code desc, application_short_name asc;<br>');
												  l_o('          </blockquote><br>');
												  l_o('     </TD>');
												  l_o('   </TR>');
												  l_o(' <TR>');
												  l_o(' <TH><B>Legislation Code</B></TD>');
												  l_o(' <TH><B>Application Name</B></TD>');
												  l_o(' <TH><B>Action</B></TD>');
					
												  :n := dbms_utility.get_time;
											  
												  open datainstaller_actions;
												  loop
														fetch datainstaller_actions into  v_leg_code,v_apps ,v_action;
														EXIT WHEN  datainstaller_actions%NOTFOUND;
														l_o('<TR><TD>'||v_leg_code||'</TD>'||chr(10)||'<TD>'||v_apps||'</TD>'||chr(10)||'<TD>'||v_action||'</TD></TR>'||chr(10));
												  end loop;
												  close datainstaller_actions;
												  
												  
												  :n := (dbms_utility.get_time - :n)/100;
												  l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
												  l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
												  l_o(' </TABLE></div> ');
												  
												  l_o('<div class="diverr" id="sig2">');
												  l_o('<img class="error_ico"><font color="red">Error:</font> You have legislations currently selected for install by the DataInstall.');
												  l_o(' Please resolve hrglobal issues ');
												  l_o('in order to install/upgrade all legislative data selected during DataInstaller.<br>');
												  l_o('Please review: <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=140511.1" target="_blank" >Doc ID 140511.1</a> ');
												  l_o('How to Install HRMS Legislative Data Using Data Installer and hrglobal.drv</div><br><br>');
						 end if;             
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;
				  
-- Statutory exceptions
procedure statutory is
				cursor statutory is
				select table_name
					   , surrogate_id 
					   , true_key
					   , exception_text
				  from hr_stu_exceptions;
				v_table_name hr_stu_exceptions.table_name%type;
				v_surrogate_id hr_stu_exceptions.surrogate_id%type;
				v_true_key hr_stu_exceptions.true_key%type;
				v_exception_text hr_stu_exceptions.exception_text%type;
				v_exists number;
				begin
					select count(1) into v_exists
					  from hr_stu_exceptions;      
					 
					  if v_exists>0 then
												  :e1:=:e1+1;
												  :issuep:=1;
												   l_o('<A class=detail onclick="displayItem(this,''s1sql33'');" href="javascript:;"><font size="+0.5">&#9654; Statutory Exceptions</font></A>');
                                 											  
												  l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql33" style="display:none" >');
												  l_o('  <TR> <TH COLSPAN=4 bordercolor="#DEE6EF">');
												  l_o('     <B>Statutory exceptions:</B></font></TD>');
												  l_o('     <TH bordercolor="#DEE6EF">');
												  l_o('<A class=detail id="s1sql34b" onclick="displayItem2(this,''s1sql34'');" href="javascript:;">&#9654; Show SQL Script</A>');
												  l_o('   </TD>');
												  l_o(' </TR>');
												  l_o(' <TR id="s1sql34" style="display:none">');
												  l_o('    <TD colspan="4" height="60">');
												  l_o('       <blockquote><p align="left">');
												  l_o('          select table_name <br>');                                     
												  l_o('           , to_char(surrogate_id) surrogate_id<br>'); 
												  l_o('           , true_key<br>'); 
												  l_o('           , exception_text<br>'); 
												  l_o('            from hr_stu_exceptions;<br>'); 
												  l_o('          </blockquote><br>');
												  l_o('     </TD>');
												  l_o('   </TR>');
												  l_o(' <TR>');
												  l_o(' <TH><B>Table name</B></TD>');
												  l_o(' <TH><B>Surrogate ID</B></TD>');
												  l_o(' <TH><B>True key</B></TD>');
												  l_o(' <TH><B>Exception</B></TD>');
					
												  :n := dbms_utility.get_time;
											  
												  open statutory;
												  loop
														fetch statutory into  v_table_name , v_surrogate_id , v_true_key , v_exception_text;
														EXIT WHEN  statutory%NOTFOUND;
														l_o('<TR><TD>'||v_table_name||'</TD>'||chr(10)||'<TD>'||v_surrogate_id||'</TD>'||chr(10)||'<TD>'||v_true_key||'</TD>'||chr(10)||'<TD>');
														l_o(v_exception_text);
														l_o('</TD></TR>'||chr(10));
												  end loop;
												  close statutory;
												  
												  
												  :n := (dbms_utility.get_time - :n)/100;
												  l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
												  l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
												  l_o(' </TABLE>  ');
												  
												  l_o('<div class="diverr" id="sig3">');
												  l_o('<img class="error_ico"><font color="red">Error:</font> You have statutory exceptions. ');
												  l_o('In order to solve please review:<br>');
												  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=101351.1" target="_blank" >Doc ID 101351.11</a> ');
												  l_o('HRGLOBAL.DRV:DIAGNOSING PROBLEMS WITH LEGISLATIVE UPDATES - HR_LEGISLATION.INSTALL</div>');
												 
						 end if;  
					  l_o('</td></tr>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display baseline patches				
procedure baseline is
 v_status varchar2(5);
  no_rows number;
  v_exists number;
  issue boolean:=FALSE;
  -- Display patch
	procedure display_patch (v_patch varchar2, v_name varchar2) is
	  v_patch_date   ad_bugs.LAST_UPDATE_DATE%type := null;	  
	begin		
					select count(1) into v_exists from ad_bugs where bug_number=v_patch;
						if (v_exists=0) then             
								 issue:=TRUE;
								 l_o('<div class="divwarn">');
								 l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Please plan to install ');
								 l_o('<a href="https://updates.oracle.com/Orion/PatchDetails/process_form?patch_num='||v_patch||'">Patch '||v_patch||'</a> '||v_name||'<br>');	
								 l_o('</div>');
								 :w1:=:w1+1;
						else
							select LAST_UPDATE_DATE  into v_patch_date FROM ad_bugs where bug_number=v_patch and rownum < 2;
							l_o('Patch '||v_patch||' ' || v_name||' applied on '||v_patch_date||'<br>');
							
						end if;
	end; 
				begin
						 if :apps_rel like '11.5%' or :apps_rel like '12.0%' then
							l_o(' <TR><td>Baseline patches</td><td>');
							if :apps_rel like '11.5%' then		  
							  display_patch('5903765','11i.ATG_PF.H.delta.6');
							  select count(1) into no_rows from fnd_product_installations where application_id=203;
							  if no_rows=1 then
									  select status into v_status from fnd_product_installations where application_id=203;
									  if v_status='I' then						
											display_patch('4428060',' - baseline patch for AME');
									  end if;
							  end if;
							  select status into v_status from fnd_product_installations where application_id=453;
							  if v_status='I' then                
									display_patch('4001448',' - baseline patch for HRI');
							  end if; 
							  display_patch('6699770',' - baseline patch for PER, BEN, PSP, IRC, Self Service');          
							  select status into v_status from fnd_product_installations where application_id=810;
							  if v_status='I' then
									display_patch('7446888',' - baseline patch for OTA');				
							  end if; 
							  select count(1) into no_rows from fnd_product_installations where status='I' and application_id in (801, 8301) ;
							  if no_rows>0 then
									display_patch('7666111',' - baseline patch for PAY, GHR');				
							  end if; 
							  select status into v_status from fnd_product_installations where application_id=808;
							  if v_status='I' then
									display_patch('7226660','  - baseline patch for HXT');				
							  end if; 
							  
							  if issue then
								  l_o('<div class="divwarn">');
								  l_o('<img class="warn_ico" id="sig5"><span class="sectionorange">Warning: </span>You have baseline patches missing.</div><br>');
							  else
								  l_o('HCM Product Level Requirements applied.<br>');
							  end if;
								  l_o('<span class="sectionblue1">Advice:</span> Please review ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1199724.1" target="_blank">Doc ID 1199724.1</a> ');
								  l_o('- E-Business Suite 11.5.10 Minimum Patch Level and Extended Support Information Center<br>');
							  
							elsif :apps_rel like '12.0%' then
								  display_patch('7004477','R12.HR_PF.A.delta.6 (Minimum baseline)');
								  display_patch('9301208','R12.HR_PF.A.delta.8 (Minimum baseline for those customers whose legislation tax year end / tax year begin schedule must be applied as a prerequisite before processing the legislative Year End (Doc ID 135266.1))');
								  if issue then
										l_o('<div class="divwarn">');
										l_o('<img class="warn_ico" id="sig5"><span class="sectionorange">Warning: </span>You have baseline patches missing.</div><br>');
								  else
									  l_o('HCM Product Level Requirements applied.<br>');
								  end if;
								  l_o('<span class="sectionblue1">Advice:</span> Please review ');
								  l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1334562.1" target="_blank">Doc ID 1334562.1</a> ');
								  l_o('- Minimum Patch Requirements for Extended Support of Oracle E-Business Suite Human Capital Management (HCM) Release 12.0<br>');
							end if;
							if issue then
								  :issuep:=1;
							end if;
						l_o('</td></tr>');
						end if;    
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display performance patches				
procedure performance is
				begin
						l_o(' <TR><td>Performance</td><td>');
						l_o('<span class="sectionblue1">Advice:</span> For performance patches please periodically review: ');
						l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=244040.1" target="_blank">Doc ID 244040.1</a> - Oracle E-Business Suite Recommended Performance Patches<br>');
						l_o('<DIV align="center"><A class=detail onclick="displayItem(this,''s1sql35'');" href="javascript:;">&#9654; How to check database patches</A></DIV>');
						l_o(' <TABLE align="center" border="1" cellspacing="0" cellpadding="2" id="s1sql35" style="display:none" >');
						l_o('   <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
						l_o(' <blockquote>-	cd RDBMS_ORACLE_HOME<br>-	. ./SID_hostname.env<br>');
						l_o('-	export PATH=$ORACLE_HOME/OPatch:$PATH<br>-	opatch lsinventory<br>-	Compare results with the patches from ');
						l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=244040.1" target="_blank">Doc ID 244040.1</a> - Oracle E-Business Suite Recommended Performance Patches<br>');
						l_o('</blockquote>');
						l_o(' </TD><TR></TABLE>'); 
					   l_o('</td></tr>');
					  l_o(' </TABLE> </div> ');
					  if :issuep=1 then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please review patching section as you have warning(s) reported.<br><br> ');
							l_o('</div><br>');
					  end if;
					  
					  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display Packages versions				
procedure packages_version is
				  v_name dba_source.name%type;
				  v_type varchar2(50);
				  v_file  varchar2(100);
				  v_version varchar2(100);
				  v_status varchar2(50);
				  
				  cursor package_vers_otl is
				  SELECT name,decode(type,'PACKAGE', 'PACKAGE SPEC',type),
				ltrim(rtrim(substr(substr(text, instr(text,'Header: ')),
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 1),
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 2) -
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 1)
               ))) ,
               ltrim(rtrim(substr(substr(text, instr(text,'Header: ')),
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 2),
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 3) -
               instr(substr(text, instr(text,'Header: ')), ' ', 1, 2)
               )))
				 FROM dba_source c
				 WHERE (name like 'HX%' or name in ('PAGTCX',
				'PAROUTINGX',
				'PA_OTC_API',
				'PAY_BATCH_ELEMENT_ENTRY_API' ,
				'PAY_HR_OTC_RETRIEVAL_INTERFACE' ,
				'PAY_HXC_DEPOSIT_INTERFACE' ,
				'PAY_ZA_SOTC_PKG' ,
				'PA_OTC_API' ,
				'PA_PJC_CWK_UTILS' ,
				'PA_TRX_IMPORT',
				'PA_TIME_CLIENT_EXTN' ,
				'PO_HXC_INTERFACE_PVT',
				'RCV_HXT_GRP'))
				AND   type in ('PACKAGE BODY','PACKAGE')
				AND   line = 2
				AND   text like '%$Header%'
				order by name; 
				  begin
							l_o('<DIV class=divItem><a name="packages"></a>');
							l_o('<DIV id="s1sql23b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql23'');" href="javascript:;">&#9654; Packages Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql23" style="display:none" >');
							l_o('   <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
							l_o('     <B>Packages version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql24b" onclick="displayItem2(this,''s1sql24'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql24" style="display:none">');
							l_o('    <TD colspan="4" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select distinct Name as Package, <br> decode(type,''PACKAGE'', ''PACKAGE SPEC'',type) as Type,<br>');
							l_o('          substr(text,instr(text,''$Header: '',1,1)+9 , instr(text,''.p'',1,1) - instr(text,''$Header: '',1,1)-5 ) as FileName ,<br>'); 
							l_o('          substr(text,instr(text,''.p'')+4, instr(text ,'' '' ,instr(text,''.p'')+3, 2)- instr(text,''.p'')-4) as Version<br>');
							l_o('          from dba_source <br> where (name like ''HX%'' or <br> name in (''PAGTCX'', <br> ''PAROUTINGX'',<br>''PA_OTC_API'',<br> ''PAY_BATCH_ELEMENT_ENTRY_API'' ,<br>');
							l_o('                  ''PAY_HR_OTC_RETRIEVAL_INTERFACE'' ,<br> ''PAY_HXC_DEPOSIT_INTERFACE'' ,<br>''PAY_ZA_SOTC_PKG''  ,<br>''PA_OTC_API'' , <br>');
							l_o('                  ''PA_PJC_CWK_UTILS''  ,<br> ''PA_TIME_CLIENT_EXTN'' ,<br> ''PA_TRX_IMPORT'',<br> ''PO_HXC_INTERFACE_PVT'',<br> ''RCV_HXT_GRP''))<br>');    
							l_o('          and instr(text,''$Header'') <>0 and instr(text,''.p'') <>0 and line =2 <br> order by Name;<br>');
							l_o('          </blockquote><br>');
							l_o('     </TD></TR><TR>');
							l_o(' <TH><B>Name</B></TD>');
							l_o(' <TH><B>Type</B></TD>');
							l_o(' <TH><B>File</B></TD>');
							l_o(' <TH><B>Version</B></TD>');

						
							:n := dbms_utility.get_time;
								  open package_vers_otl;
								  loop
										fetch package_vers_otl into v_name,v_type,v_file,v_version;
										EXIT WHEN  package_vers_otl%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>'||v_type||'</TD>'||chr(10)||'<TD>');
										l_o(v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close package_vers_otl;
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql23'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

-- Display java classes version				  
procedure java_version is
				 v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor java_vers is
				  select que.subdir,que.filename, que.version
				  from (
					 select files.filename filename,files.subdir subdir,
					 file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, subdir, file_id
					   from ad_files
					   where app_short_name='HXC' and upper(filename) like upper('%.class')
					   ) files
					 where files.file_id = file_version.file_id
				  ) que
				  where rank1 = 1
				  order by 1,2;
				  begin
							l_o('<DIV class=divItem><a name="java"></a>');
							l_o('<DIV id="s1sql25b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql25'');" href="javascript:;">&#9654; Java Classes Version</A></DIV>');		
		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql25" style="display:none" >');
							l_o('  <TR> <TH COLSPAN=2 bordercolor="#DEE6EF">');
							l_o('     <B>Java version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql26b" onclick="displayItem2(this,''s1sql26'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql26" style="display:none">');
							l_o('    <TD colspan="2" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br> select files.filename filename,files.subdir subdir,<br>');
							l_o('               file_version.version version,<br> rank()over(partition by files.filename<br>');
							l_o('                 order by file_version.version_segment1 desc,<br> file_version.version_segment2 desc,file_version.version_segment3 desc,<br>');
							l_o('                 file_version.version_segment4 desc,file_version.version_segment5 desc,<br> file_version.version_segment6 desc,file_version.version_segment7 desc,<br>');
							l_o('                 file_version.version_segment8 desc,file_version.version_segment9 desc,<br> file_version.version_segment10 desc,<br>');
							l_o('                 file_version.translation_level desc) as rank1<br> from ad_file_versions file_version,<br> (<br>');
							l_o('                 select filename, app_short_name, subdir, file_id<br> from ad_files<br> where app_short_name=''HXC'' and upper(filename) like upper(''%.class'')<br>');  
							l_o('                 ) files<br> where files.file_id = file_version.file_id<br>) que<br> where rank1 = 1<br> order by 1,2;<br>');  
							l_o('          </blockquote><br>');
							l_o('     </TD></TR><TR>');
							l_o(' <TH><B>File directory</B></TD>');
						l_o(' <TH><B>Filename</B></TD>');
						l_o(' <TH><B>Version</B></TD>');
							:n := dbms_utility.get_time;
								  open java_vers;
								  v_dir_old:='';
								  loop
										fetch java_vers into v_dir,v_file,v_version;
										EXIT WHEN  java_vers%NOTFOUND;
										if v_dir_old=v_dir then
											l_o('<TR><TD></TD>'||chr(10)||'<TD>');
										else
											l_o('<TR><TD>'||v_dir||'</TD>'||chr(10)||'<TD>');
										end if;
										v_dir_old:=v_dir;
										l_o(v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close java_vers;
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql25'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;
				  
				  
-- Display forms version				  
procedure forms_version is
				 v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor forms_vers is
				  select que.subdir,que.filename, que.version
				  from (
					 select files.filename filename,files.subdir subdir,
					 file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, subdir, file_id
					   from ad_files
					   where app_short_name in ('HXC','HXT') and upper(filename) like upper('%.fmb') and subdir like 'forms%US'
					   ) files
					 where files.file_id = file_version.file_id
				  ) que
				  where rank1 = 1
				  order by 1,2;
				  begin
							l_o('<DIV class=divItem><a name="forms"></a>');
							l_o('<DIV id="s1sql79b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql79'');" href="javascript:;">&#9654; Forms Version</A></DIV>');
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql79" style="display:none" >');
							l_o('  <TR> <TH COLSPAN=2 bordercolor="#DEE6EF">');
							l_o('     <B>Forms version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql80b" onclick="displayItem2(this,''s1sql80'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql80" style="display:none">');
							l_o('    <TD colspan="2" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br>');
							l_o('               select files.filename filename,files.subdir subdir,<br> file_version.version version,<br> rank()over(partition by files.filename<br>');
							l_o('                 order by file_version.version_segment1 desc,<br> file_version.version_segment2 desc,file_version.version_segment3 desc,<br>');
							l_o('                 file_version.version_segment4 desc,file_version.version_segment5 desc,<br> file_version.version_segment6 desc,file_version.version_segment7 desc,<br>');
							l_o('                 file_version.version_segment8 desc,file_version.version_segment9 desc,<br> file_version.version_segment10 desc,<br>');
							l_o('                 file_version.translation_level desc) as rank1<br> from ad_file_versions file_version,<br>');
							l_o('                 (<br> select filename, app_short_name, subdir, file_id<br> from ad_files<br>');
							l_o('                 where app_short_name in (''HXC'',''HXT'') and upper(filename) like upper(''%.fmb'') and subdir like ''forms%US''<br>');  
							l_o('                 ) files<br> where files.file_id = file_version.file_id<br> ) que<br> where rank1 = 1<br> order by 1,2;<br>');  
							l_o('          </blockquote><br>');
							l_o('     </TD></TR><TR>');
							l_o(' <TH><B>File directory</B></TD>');
						l_o(' <TH><B>Filename</B></TD>');
						l_o(' <TH><B>Version</B></TD>');
							:n := dbms_utility.get_time;
								  open forms_vers;
								  v_dir_old:='';
								  loop
										fetch forms_vers into v_dir,v_file,v_version;
										EXIT WHEN  forms_vers%NOTFOUND;
										if v_dir_old=v_dir then
											l_o('<TR><TD></TD>'||chr(10)||'<TD>');
										else
											l_o('<TR><TD>'||v_dir||'</TD>'||chr(10)||'<TD>');
										end if;
										v_dir_old:=v_dir;
										l_o(v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close forms_vers;
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql79'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

-- Display reports version				  
procedure reports_version is
				  v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor Reports_vers is
				  select que.subdir,que.filename, que.version
				  from (
					 select files.filename filename,files.subdir subdir,
					 file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, subdir, file_id
					   from ad_files
					   where (app_short_name like 'HXC' or app_short_name like 'HXT') and (upper(filename) like upper('%.rdf') and subdir like 'rep%US') or (lower(filename) in ('authorizeddelegatepersonlistvo.xml','hxcmistc_xml.xml','authorizeddelegatenextpersonvo.xml','exptypeelementlovvo.xml')) 
					   ) files
					 where files.file_id = file_version.file_id
				  ) que
				  where rank1 = 1
				  order by 1,2;
				  begin
							l_o('<DIV class=divItem><a name="reports"></a>');
							l_o('<DIV id="s1sql37b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql37'');" href="javascript:;">&#9654; Reports and XML Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql37" style="display:none" >');
							l_o('   <TR><TH COLSPAN=3 bordercolor="#DEE6EF">');
							l_o('     <B>Reports and XML version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql38b"  onclick="displayItem2(this,''s1sql38'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql38" style="display:none">');
							l_o('    <TD colspan="2" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br> select files.filename filename,files.subdir subdir,<br>');
							l_o('               file_version.version version,<br> rank()over(partition by files.filename<br> order by file_version.version_segment1 desc,<br>');
							l_o('                 file_version.version_segment2 desc,file_version.version_segment3 desc,<br> file_version.version_segment4 desc,file_version.version_segment5 desc,<br>');
							l_o('                 file_version.version_segment6 desc,file_version.version_segment7 desc,<br> file_version.version_segment8 desc,file_version.version_segment9 desc,<br>');
							l_o('                 file_version.version_segment10 desc,<br> file_version.translation_level desc) as rank1<br>');
							l_o('               from ad_file_versions file_version,<br> (<br> select filename, app_short_name, subdir, file_id<br> from ad_files<br>');
							l_o('                 where (app_short_name like ''HXC'' or app_short_name like ''HXT'') and upper(filename) like upper(''%.rdf'') and subdir like ''rep%US''<br>');  
							l_o('                 ) files<br> where files.file_id = file_version.file_id<br> ) que<br> where rank1 = 1<br> order by 1,2;<br>');  
							l_o('          </blockquote><br>');
							l_o('     </TD></TR><TR>');
							l_o(' <TH><B>File directory</B></TD>');
							l_o(' <TH><B>Name</B></TD>');
							l_o(' <TH><B>Filename</B></TD>');
							l_o(' <TH><B>Version</B></TD>');
						
							:n := dbms_utility.get_time;
																 
								  open Reports_vers;
								  v_dir_old:='';
								  loop
										fetch Reports_vers into v_dir,v_file,v_version;
										EXIT WHEN  Reports_vers%NOTFOUND;
										if v_dir_old=v_dir then
											l_o('<TR><TD></TD>'||chr(10)||'<TD>');
										else
											l_o('<TR><TD>'||v_dir||'</TD>'||chr(10)||'<TD>');
										end if;
										v_dir_old:=v_dir;
										
										if v_file like 'HXCMISTC%' then
											l_o('Missing Timecard Report');
										elsif v_file like 'HXCRTERR%' then
											l_o('Retrieval Error Handling Report');
										else
											l_o('-');
										end if;
										l_o('</TD>'||chr(10)||'<TD>'||v_file||'</TD>'||chr(10));
										
										l_o('<TD>'||v_version);
										l_o('</TD></TR>'||chr(10));
									end loop;
								  close Reports_vers;			 
					  
							:n := (dbms_utility.get_time - :n)/100;
							l_o(' <TR><TH COLSPAN=3 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

				  
-- Display ldt version				  
procedure ldt_version is
				 v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor ldt_vers is
				  select que.subdir,que.filename, que.version
				  from (
					 select files.filename filename,files.subdir subdir,
					 file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, subdir, file_id
					   from ad_files
					   where app_short_name in ('HXC','HXT') and upper(filename) like upper('%.ldt') and subdir like '%US'
					   ) files
					 where files.file_id = file_version.file_id and file_version.version like substr(:apps_rel,1,2)||'%'
				  ) que
				  where rank1 = 1
				  order by 1,2;
				  begin
							l_o('<DIV class=divItem><a name="ldt"></a>');
							l_o('<DIV id="s1sql77b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql77'');" href="javascript:;">&#9654; Ldt Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql77" style="display:none" >');
							l_o('  <TR> <TH COLSPAN=2 bordercolor="#DEE6EF">');
							l_o('     <B>Ldt version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql78b" onclick="displayItem2(this,''s1sql78'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql78" style="display:none"><TD colspan="2" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br> select files.filename filename,files.subdir subdir,<br>');
							l_o('               file_version.version version,<br> rank()over(partition by files.filename<br>');
							l_o('                 order by file_version.version_segment1 desc,<br> file_version.version_segment2 desc,file_version.version_segment3 desc,<br>');
							l_o('                 file_version.version_segment4 desc,file_version.version_segment5 desc,<br> file_version.version_segment6 desc,file_version.version_segment7 desc,<br>');
							l_o('                 file_version.version_segment8 desc,file_version.version_segment9 desc,<br> file_version.version_segment10 desc,<br>');
							l_o('                 file_version.translation_level desc) as rank1<br> from ad_file_versions file_version,<br>(<br>');
							l_o('                 select filename, app_short_name, subdir, file_id<br>from ad_files<br>');
						l_o('                 where app_short_name in (''HXC'',''HXT'') and upper(filename) like upper(''%.ldt'') and subdir like ''%US''<br>');  
							l_o('                 ) files<br> where files.file_id = file_version.file_id and file_version.version like substr('''||:apps_rel||''',1,2)||''%''<br>');
							l_o('            ) que<br> where rank1 = 1<br> order by 1,2;<br>');  
							l_o('          </blockquote><br>');
							l_o('     </TD>');
							l_o('   </TR>');
							l_o(' <TR>');
							l_o(' <TH><B>File directory</B></TD>');
						l_o(' <TH><B>Filename</B></TD>');
						l_o(' <TH><B>Version</B></TD>');

						
							:n := dbms_utility.get_time;
						
					   
										 
								  open ldt_vers;
								  v_dir_old:='';
								  loop
										fetch ldt_vers into v_dir,v_file,v_version;
										EXIT WHEN  ldt_vers%NOTFOUND;
										if v_dir_old=v_dir then
											l_o('<TR><TD></TD>'||chr(10)||'<TD>');
										else
											l_o('<TR><TD>'||v_dir||'</TD>'||chr(10)||'<TD>');
										end if;
										v_dir_old:=v_dir;
										l_o(v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close ldt_vers;		 
					  
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql77'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF"><i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;


-- Display odf version				  
procedure odf_version is
				 v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor odf_vers is
				  select que.filename, que.version
				  from (
					 select files.filename filename, file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, file_id
					   from ad_files
					   where app_short_name in ('HXC','HXT') and upper(filename) like upper('%.odf') 
					   ) files
					 where files.file_id = file_version.file_id and file_version.version like substr(:apps_rel,1,2)||'%'
				  ) que
				  where rank1 = 1
				  order by 1;
				  begin
							l_o('<DIV class=divItem><a name="odf"></a>');
							l_o('<DIV id="s1sql86b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql86'');" href="javascript:;">&#9654; Odf Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="1" id="s1sql86" style="display:none" >');
							l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('     <B>Odf version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql87b" onclick="displayItem2(this,''s1sql87'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql87" style="display:none"><TD colspan="1" height="60"><blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br> select files.filename filename,file_version.version version,<br>');
							l_o('               rank()over(partition by files.filename<br> order by file_version.version_segment1 desc,<br> file_version.version_segment2 desc,file_version.version_segment3 desc,<br>');
							l_o('                 file_version.version_segment4 desc,file_version.version_segment5 desc,<br> file_version.version_segment6 desc,file_version.version_segment7 desc,<br>');
							l_o('                 file_version.version_segment8 desc,file_version.version_segment9 desc,<br> file_version.version_segment10 desc,<br>');
							l_o('                 file_version.translation_level desc) as rank1<br> from ad_file_versions file_version,<br>(<br>select filename, app_short_name, file_id<br> from ad_files<br>');
							l_o('                 where app_short_name in (''HXC'',''HXT'') and upper(filename) like upper(''%.odf'')<br>) files<br>');
							l_o('               where files.file_id = file_version.file_id and file_version.version like substr('''||:apps_rel||''',1,2)||''%''<br>) que<br> where rank1 = 1<br> order by 1;<br>');  
							l_o('          </blockquote><br></TD></TR><TR>');							
							l_o(' <TH><B>Filename</B></TD>');
							l_o(' <TH><B>Version</B></TD>');					
							:n := dbms_utility.get_time;					   
								  open odf_vers;								  
								  loop
										fetch odf_vers into v_file,v_version;
										EXIT WHEN  odf_vers%NOTFOUND;										
										l_o('<TR><TD>'||v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close odf_vers;				  
						
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql86'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF"><i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR></TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

-- Display sql version				  
procedure sql_version is
				 v_dir ad_files.subdir%type;
				  v_dir_old ad_files.subdir%type;
				  v_file ad_files.filename%type;
				  v_version ad_file_versions.version%type;
				   
				  cursor sql_vers is
				  select que.filename, que.version
				  from (
					 select files.filename filename, file_version.version version,
					 rank()over(partition by files.filename
					   order by file_version.version_segment1 desc,
					   file_version.version_segment2 desc,file_version.version_segment3 desc,
					   file_version.version_segment4 desc,file_version.version_segment5 desc,
					   file_version.version_segment6 desc,file_version.version_segment7 desc,
					   file_version.version_segment8 desc,file_version.version_segment9 desc,
					   file_version.version_segment10 desc,
					   file_version.translation_level desc) as rank1
					 from ad_file_versions file_version,
					   (
					   select filename, app_short_name, file_id
					   from ad_files
					   where app_short_name in ('HXC','HXT') and upper(filename) like upper('%.sql') 
					   ) files
					 where files.file_id = file_version.file_id and file_version.version like substr(:apps_rel,1,2)||'%'
				  ) que
				  where rank1 = 1
				  order by 1;
				  begin
							l_o('<DIV class=divItem><a name="sql"></a>');
							l_o('<DIV id="s1sql88b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql88'');" href="javascript:;">&#9654; Sql Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="1" id="s1sql88" style="display:none" >');
							l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('     <B>Sql version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql89b" onclick="displayItem2(this,''s1sql89'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql89" style="display:none"><TD colspan="1" height="60"><blockquote><p align="left">');
							l_o('          select que.subdir,que.filename, que.version <br> from (<br> select files.filename filename,file_version.version version,<br>');
							l_o('               rank()over(partition by files.filename<br> order by file_version.version_segment1 desc,<br> file_version.version_segment2 desc,file_version.version_segment3 desc,<br>');
							l_o('                 file_version.version_segment4 desc,file_version.version_segment5 desc,<br> file_version.version_segment6 desc,file_version.version_segment7 desc,<br>');
							l_o('                 file_version.version_segment8 desc,file_version.version_segment9 desc,<br> file_version.version_segment10 desc,<br>');
							l_o('                 file_version.translation_level desc) as rank1<br> from ad_file_versions file_version,<br>(<br>select filename, app_short_name, file_id<br> from ad_files<br>');
							l_o('                 where app_short_name in (''HXC'',''HXT'') and upper(filename) like upper(''%.sql'')<br>) files<br>');
							l_o('               where files.file_id = file_version.file_id and file_version.version like substr('''||:apps_rel||''',1,2)||''%''<br>) que<br> where rank1 = 1<br> order by 1;<br>');  
							l_o('          </blockquote><br></TD></TR><TR>');							
							l_o(' <TH><B>Filename</B></TD>');
							l_o(' <TH><B>Version</B></TD>');						
							:n := dbms_utility.get_time;					   
								  open sql_vers;								  
								  loop
										fetch sql_vers into v_file,v_version;
										EXIT WHEN  sql_vers%NOTFOUND;										
										l_o('<TR><TD>'||v_file||'</TD>'||chr(10)||'<TD>'||v_version);
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close sql_vers;	
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql88'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF"><i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> </TABLE></div> ');
						

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;
				  
-- Display workflow version				  
procedure workflow_version is
				wtf_version ad_file_versions.version%type;
				begin
							l_o('<DIV class=divItem><a name="workflow"></a>');
							l_o('<DIV id="s1sql39b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql39'');" href="javascript:;">&#9654; Workflow Version</A></DIV>');		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql39" style="display:none" >');
							l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('     <B>Workflow version:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql40b" onclick="displayItem2(this,''s1sql40'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD></TR><TR id="s1sql40" style="display:none"><TD colspan="1" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('          select que.filename, que.version <br> from (<br> select files.filename filename,files.subdir subdir,<br>');
							l_o('               file_version.version version,<br> rank()over(partition by files.filename<br> order by file_version.version_segment1 desc,<br>');
							l_o('                 file_version.version_segment2 desc,file_version.version_segment3 desc,<br> file_version.version_segment4 desc,file_version.version_segment5 desc,<br>');
							l_o('                 file_version.version_segment6 desc,file_version.version_segment7 desc,<br> file_version.version_segment8 desc,file_version.version_segment9 desc,<br>');
							l_o('                 file_version.version_segment10 desc,<br> file_version.translation_level desc) as rank1<br>');
							l_o('               from ad_file_versions file_version,<br> (<br> select filename, app_short_name, subdir, file_id<br>');
							l_o('                 from ad_files<br> where upper(filename) like upper(''hxcempwf.wft'') and subdir like ''%US%''<br> ) files<br>');
							l_o('               where files.file_id = file_version.file_id<br>) que<br>');
							l_o('            where rank1 = 1 and rownum < 2<br> order by 1,2;<br>');
							l_o('          </blockquote><br>');
							l_o('     </TD></TR><TR>');
							l_o(' <TH><B>Filename</B></TD>');
							l_o(' <TH><B>Version</B></TD>');
					
							:n := dbms_utility.get_time;					   
										
									select sub.version into wtf_version
									from (
									   select files.filename filename,
									   file_version.version version,
									   rank()over(partition by files.filename
										 order by file_version.version_segment1 desc,
										 file_version.version_segment2 desc,file_version.version_segment3 desc,
										 file_version.version_segment4 desc,file_version.version_segment5 desc,
										 file_version.version_segment6 desc,file_version.version_segment7 desc,
										 file_version.version_segment8 desc,file_version.version_segment9 desc,
										 file_version.version_segment10 desc,
										 file_version.translation_level desc) as rank1
									   from ad_file_versions file_version,
										 (
										 select filename, app_short_name, subdir, file_id
										 from ad_files
										 where upper(filename) like upper('hxcempwf.wft') and subdir like '%US%'
										 ) files
									   where files.file_id = file_version.file_id
									) sub
									where rank1 = 1 and rownum < 2;
								   l_o('<TR><TD>hxcempwf.wft</TD>'||chr(10)||'<TD>'||wtf_version);
											l_o('</TD></TR>'||chr(10));
								  
								
						
							:n := (dbms_utility.get_time - :n)/100;
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF"><i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR></TABLE></div> ');					

						  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display purging issues				
procedure purging is
				  status varchar2(160);
				  last_date date;
				  need_run boolean:=FALSE;
				  days number;
				  no_rows number;

				  no_rows_wf number;

				  issue boolean:=FALSE;
				  v_table_name dba_tables.table_name%type;
				  v_no_rows number;
				  begin
								:n := dbms_utility.get_time;
								select wf_purge.getpurgeablecount('HXCEMP') into no_rows_wf from dual;
								if no_rows_wf>1000 then
									issue:=TRUE;
								end if;     

								:n := (dbms_utility.get_time - :n)/100;
					
								l_o('<DIV class=divItem><a name="purge"></a>');
								l_o('<DIV id="s1sql15b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql15'');" href="javascript:;">&#9654; Purgeable Obsolete Workflow</A></DIV>');		
								
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql15" style="display:none" >');
								l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Purging:</B></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql16b" onclick="displayItem2(this,''s1sql16'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql16" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('          select wf_purge.getpurgeablecount(''HXCEMP'') from dual; <br>');            
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Purgeable Obsolete Workflow</B></TD>');
								l_o(' <TH><B>Purgeable Workflow Count</B></TD>');
											

								if issue then
										l_o('<TR><TD>'||'<font color="red">wf_purge.getpurgeablecount(''HXCEMP'') </font>'||'</TD>'||chr(10)||'<TD><font color="red">'||no_rows_wf||'</font></TD></TR>'||chr(10));
								else
										l_o('<TR><TD>'||'wf_purge.getpurgeablecount(''HXCEMP'') '||'</TD>'||chr(10)||'<TD>'||no_rows_wf||'</TD></TR>'||chr(10));
								end if;   

											  
								
							   
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE> </div> ');
									   
								if issue then
										l_o('<div class="divwarn" id="sigp4">');
										l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your Purgeable Workflow count is more than 1000. ');
										l_o('Please run ''Purge Obsolete Workflow Runtime Data'' with (Item Type = OTL Workflows for Employees) from System Administrator responsibility.<br> ');
										l_o('</div>');
										:w1:=:w1+1;
								else
										l_o('<div class="divok1">');
										l_o('<img class="check_ico">OK! Your Purgeable Workflow count is less than 1000. You don''t need to purge your obsolete workflows.');
										l_o('</div>');
								end if; 
								

								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;


-- Display Workflow Errors issues
procedure workflow is
	  v_it_old wf_process_activities.PROCESS_ITEM_TYPE%type; 
	  v_activity_old wf_process_activities.ACTIVITY_NAME%type;
	  v_err_name_old varchar2(400);
	  v_big_no number :=1;
	  v_big_no2 number :=1;
	  v_rows number;
	  v_count number;
	  cursor otl_workflow  is
		select p.process_item_type v_it, p.activity_name v_activity, wi.item_key v_ik, substr(s.error_message,1,150) v_err_name, wi.begin_date v_date, activity_result_code v_code, s.process_activity v_process_activity
			FROM wf_item_activity_statuses s,wf_process_activities p, wf_items wi
			WHERE p.instance_id = s.process_activity
			and wi.item_type = s.item_type
			and wi.item_key = s.item_key
			and activity_status = 'ERROR'			
			AND p.PROCESS_ITEM_TYPE in  ('HXCEMP', 'HXCSAW')
			and ROWNUM<300
			order by 1,2,4,5;
begin
		select count(1)	into v_rows FROM wf_item_activity_statuses s,wf_process_activities p
					WHERE p.instance_id = s.process_activity
					AND activity_status = 'ERROR'
					AND p.PROCESS_ITEM_TYPE in  ('HXCEMP', 'HXCSAW');	
		
			
		l_o('<a name="stuck"></a><DIV class=divItem>');
		l_o('<DIV id="s1sql84b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql84'');" href="javascript:;">&#9654; Workflows with Errors</A></DIV>');
			
		l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql84" style="display:none" >');
		l_o(' <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF">');
		l_o('   <TH COLSPAN=4 bordercolor="#DEE6EF">');
		l_o('     <B>Workflows with Errors</B></font></TD>');
		l_o('     <TD bordercolor="#DEE6EF">');
		l_o('<A class=detail  id="s1sql85b"  onclick="displayItem2(this,''s1sql85'');" href="javascript:;">&#9654; Show SQL Script</A>');
		l_o('   </TD>');
		l_o(' </TR>');
		l_o(' <TR id="s1sql85" style="display:none">');
		l_o('    <TD colspan="4" height="60">');
		l_o('       <blockquote><p align="left">');
    
		l_o('         select p.process_item_type, p.activity_name, activity_result_code, wi.item_key, substr(s.error_message,1,150), wi.begin_date<br>');
		l_o('         	FROM wf_item_activity_statuses s,wf_process_activities p, wf_items wi<br>');
		l_o('         	WHERE p.instance_id = s.process_activity<br>');
		l_o('         	and wi.item_type = s.item_type<br>');
		l_o('         	and wi.item_key = s.item_key<br>');
		l_o('         	AND activity_status = ''ERROR''<br>');			
		l_o('         	AND p.PROCESS_ITEM_TYPE in <br>');		
		l_o('    (''HXCEMP'', ''HXCSAW'')<br>');
		l_o('    and ROWNUM<1000<br>');
		l_o('         	order by 1,2,4,5;<br>');    
		l_o('          </blockquote><br>');
		l_o('     </TD>');
		l_o('   </TR>');
		l_o(' <TR>');
		l_o(' <TH width="15%"><B>Item Type</B></TD>');
		l_o(' <TH width="15%"><B>Activity</B></TD>');
		l_o(' <TH width="50%"><B>Error Message (first 200 characters)</B></TD>');
		l_o(' <TH width="10%"><B>Count of errors</B></TD>');
		l_o(' <TH width="10%"><B>Show Details</B></TD>');
    
    
	:n := dbms_utility.get_time;
	
	
	if v_rows>0 then
		if v_rows>300 then
			l_o('<TR><TD COLSPAN=5>You have more than 300 workflows with errors. Erros list truncated.</TD><TR>');
		end if;
				v_it_old:='x';
				v_activity_old:='x';
				v_err_name_old:='x';
				

				for wrec in otl_workflow loop							
					if wrec.v_it<>v_it_old or wrec.v_activity<>v_activity_old or wrec.v_err_name<>v_err_name_old then
										  if v_big_no>1 then
												v_big_no2 :=v_big_no-1;
												l_o('</TABLE></td></TR>');
										  end if;
										  l_o('<TR><TD>'||wrec.v_it||'</TD>'||chr(10)||'<TD>'||wrec.v_activity ||'</TD>'||chr(10)||'<TD>');
										  if wrec.v_err_name is null then
											l_o('-</TD>'||chr(10));
										  else
											l_o(replace(wrec.v_err_name,chr(10),'<br>') ||'</TD>'||chr(10));
										  end if;
										  SELECT count(s.ITEM_KEY) into v_count
												FROM wf_item_activity_statuses s,wf_process_activities p
												WHERE p.instance_id = s.process_activity
												AND activity_status = 'ERROR'												
												AND p.PROCESS_ITEM_TYPE = wrec.v_it and p.ACTIVITY_NAME=wrec.v_activity and substr(nvl(s.error_message,'null'),1,150)=nvl(wrec.v_err_name,'null');
										  l_o('<TD>'||v_count ||'</TD>'||chr(10));
										  l_o('<TD><A style="white-space:nowrap" class=detail id="s1sql200'||v_big_no||'b" onclick="displayItem2(this,''s1sql200'||v_big_no||''');" href="javascript:;">&#9654; Show Details</A>');
										  l_o('   </TD>');
										  l_o(' </TR>');
										  l_o(' <TR><TD COLSPAN=5><TABLE width="100%" border="1" cellspacing="0" cellpadding="2"  id="s1sql200'||v_big_no||'" style="display:none">');
										  l_o(' <TR><TD width="10%"></TD><TD><B>Result</B></TD>');
										  l_o(' <TD><B>Item Key</B></TD>');
										  l_o(' <TD><B>Begin Date</B></TD>');										  
										  l_o(' <TD><B>Command to get error stack</B></TD>');
										  l_o(' <TD><B>Command to run wfstat</B></TD></TR>');										  
										  v_big_no:=v_big_no+1;
										  
								end if;
								
								v_it_old:=wrec.v_it;
								v_activity_old:=wrec.v_activity;
								v_err_name_old:=wrec.v_err_name;

								l_o('<TD></TD>');
								l_o('<TD>'||wrec.v_code||'</TD>'||chr(10));
								l_o('<TD>'||wrec.v_ik||'</TD>'||chr(10));
								l_o('<TD>'||wrec.v_date||'</TD>'||chr(10));
								
								l_o('<TD>select Error_Message, Error_Stack from wf_item_activity_statuses <br>where item_type='''||wrec.v_it||'''');
								l_o(' and item_key='''||wrec.v_ik||''' and process_activity='||wrec.v_process_activity||';</TD>'||chr(10));
								l_o('<TD>@wfstat.sql '||wrec.v_it||' '||wrec.v_ik||'</TD>'||chr(10));
											   
								l_o('</TR>'||chr(10));              
					  end loop;						
					  
					  v_big_no2 :=v_big_no-1;					  							
					  l_o(' </TABLE>');
		
	end if;
	:n := (dbms_utility.get_time - :n)/100;
	l_o('<tr><td><A class=detail onclick="hideRow(''s1sql84'');" href="javascript:;">Collapse section</a></td></tr>');
    l_o(' <TR bgcolor="#DEE6EF" bordercolor="#DEE6EF">');
    l_o(' <TH COLSPAN=4 bordercolor="#DEE6EF">');
    l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
    l_o(' </TABLE> </div> ');
	
	if v_rows=0 then
		l_o('<div class="divok1">');    
		l_o('<img class="check_ico">OK! No workflow in error.');
        l_o('</div>');
	else
		l_o('<div class="divwarn">');
		l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>You have '||v_rows||' workflows with errors! Please review the table and run the wfstat.sql command to take details.<br>');
		l_o('<blockquote>');
		if :apps_rel like '11.%' then
			l_o('1. Go to script directory: $FND_TOP/admin/sql<br>');
		else
			l_o('1. Go to script directory: $FND_TOP/sql<br>');
		end if;
		l_o('2. Connect to sqlplus: sqlplus apps/apps_password<br>');
		l_o('3. Spool the upcoming output to your $HOME directory: SQL> spool $HOME/wf_oracle_stat.txt<br>');
		l_o('4. Execute wfstat.sql as adviced in the table: SQL> @wfstat.sql ITEM_TYPE ITEM_KEY<br>');
		l_o('5. Turn spool off: SQL> spool off </blockquote>');
		l_o('</div>');
		:w1:=:w1+1;
	end if;
	
	l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');


EXCEPTION
					when others then
					  l_o('<br>'||sqlerrm ||' occurred in test');
					  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');	
end;


				  
-- Display database initialization parameters issues				  
procedure database is
				v_db_parameter v$parameter.name%type; 
				v_db_value v$parameter.value%type;
				database_version	varchar2(100);
				apps_version	varchar2(10);
				issue1 varchar2(100) := '';
				issue2 boolean := FALSE;
				issue3 boolean := FALSE;
				issue4 boolean := FALSE;
				cursor db_init is
				select name, nvl(value,'null') from v$parameter 
				  where name in ('max_dump_file_size','timed_statistics'
				  ,'user_dump_dest','compatible'
				  ,'sql_trace'
				  ,'utl_file_dir','_optimizer_autostats_job')
				  order by name;
				cursor db_init2 is
				select name, nvl(value,'null') from v$parameter order by name;
				begin
						l_o(' <a name="db_init_ora"></a>');
						select banner into database_version from V$VERSION WHERE ROWNUM = 1;
						
						apps_version:=:APPS_REL;
							open db_init;
						loop
							  fetch db_init into v_db_parameter,v_db_value;
							  EXIT WHEN  db_init%NOTFOUND;
							  CASE v_db_parameter
									when 'compatible' then 
										CASE
											when database_version like '%8.1%' then
												if v_db_value<>'8.1.7' then
													issue1:='Please set Compatible parameter to 8.1.7';
												end if;
											when database_version like '%9.2%' then
												if v_db_value<>'9.2.0' then
													issue1:='Please set Compatible parameter to 9.2.0';
												end if;
											when database_version like '%10.1%' then
												if v_db_value<>'10.1.0' then
													issue1:='Please set Compatible parameter to 10.1.0';
												end if;
											when database_version like '%10.2%' then
												if v_db_value<>'10.2.0' then
													issue1:='Please set Compatible parameter to 10.2.0';
												end if;
											when database_version like '%11.1%' then
												if v_db_value<>'11.1.0' then
													issue1:='Please set Compatible parameter to 11.1.0';
												end if;
											when database_version like '%11.2%' then
												if v_db_value<>'11.2.0' then
													issue1:='Please set Compatible parameter to 11.2.0';
												end if;
											when database_version like '%12.1%' then
												if v_db_value<>'12.1.0' then
													issue1:='Please set Compatible parameter to 12.1.0';
												end if;
											else
												null;
										end case;
									when 'max_dump_file_size' then
										if v_db_value <>'UNLIMITED' then
											issue2:=TRUE;
										end if;
									when '_optimizer_autostats_job' then
										begin
											if database_version like '%11.1%' or database_version like '%11.2%' then
												if v_db_value <>'FALSE' then
													issue3:=TRUE;
												end if;	
											end if;
										end;
									when 'timed_statistics' then
										begin
											if database_version like '%8.1%' or database_version like '%9.2%' or database_version like '%10.1%' or database_version like '%10.2%' then
												if v_db_value <> 'TRUE' then
													issue4:=TRUE;
												end if;	
											end if;
										end;			
									else
										null;
								END CASE;
								
							  
						end loop;
						close db_init;
							l_o('<DIV class=divItem>');
							l_o('<DIV id="s1sql11b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql11'');" href="javascript:;">&#9654; Database Initialization Parameters</A></DIV>');		
		
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql11" style="display:none" >'); 
							l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('     <B>Database parameters</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql12b" onclick="displayItem2(this,''s1sql12'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD>');
							l_o(' </TR>');
							l_o(' <TR id="s1sql12" style="display:none">');
							l_o('    <TD colspan="1" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('         select name, value from v$parameter <br>');							
							l_o('         order by name;<br>');
						    l_o('          </blockquote><br>');
							l_o('     </TD>');
							l_o('   </TR>');
							l_o(' <TR>');
							l_o(' <TH><B>Parameter</B></TD>');
							l_o(' <TH><B>Value</B></TD>');
						
							:n := dbms_utility.get_time;
							open db_init2;
							loop
								fetch db_init2 into v_db_parameter,v_db_value;
								EXIT WHEN  db_init2%NOTFOUND;
								l_o('<TR><TD>'||v_db_parameter||'</TD>'||chr(10)||'<TD>');
								l_o(v_db_value);
								l_o('</TD></TR>'||chr(10));
							  
							end loop;
							close db_init2;

							
							:n := (dbms_utility.get_time - :n)/100;
							l_o('<tr><td><A class=detail onclick="hideRow(''s1sql11'');" href="javascript:;">Collapse section</a></td></tr>');
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE> </div> ');
							
							if issue1<>'' or issue3 or issue4 then
								l_o('<div class="divwarn">');		
								if issue1<>'' then
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>'||issue1||'<br>');
									:w1:=:w1+1;
								end if;
												
								if issue3 then
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please set _optimizer_autostats_job to FALSE<br>');
									:w1:=:w1+1;
								end if;
								
								if issue4 then
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Please set timed_statistics to TRUE<br>');
									:w1:=:w1+1;
								end if;		
								l_o('</div>');
							end if;
							
							l_o('<div class="divok">');
							if issue2 then			
								l_o('<span class="sectionblue1">Advice:</span> If you need to run a trace please set Max_dump_file_size = UNLIMITED<br>');
							end if;
							l_o('<span class="sectionblue1">Advice:</span> If you have performance issue please ensure you have correct database initialization parameters as per ');
							if apps_version like '12.%' then
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=396009.1" target="_blank">Doc ID 396009.1</a> Database Initialization Parameters for Oracle E-Business Suite Release 12<br>');
							else 
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=216205.1" target="_blank">Doc ID 216205.1</a> Database Initialization Parameters for Oracle Applications Release 11i<br>');
							end if;
							l_o('Use <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=174605.1" target="_blank">Doc ID 174605.1</a> bde_chk_cbo.sql - EBS initialization parameters - Healthcheck<br>');
							l_o('This will help you to identify the difference between actual values and required values. Verify that all Mandatory Parameters - MP are set correctly<br><br>');
							l_o('Review also <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=419075.1" target="_blank">Doc ID 419075.1</a> Payroll Performance Checklist<br>');
							
							if issue1='' and (not issue2) and (not issue3) and (not issue4) then
									l_o('Verified parameters are correctly set');
							end if;	
							l_o('</div>');
							
							l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

-- Display last run of gather schema statistics				  
procedure gather is
				  status_all varchar2(100);
				  status_hr varchar2(100);
				  status_hxc varchar2(100);
				  status_hxt varchar2(100);
				  status_pa varchar2(100);
				  last_date_all date;
				  last_date_hr date;
				  last_date_hxc date;
				  last_date_hxt date;
				  last_date_pa date;
				  last_date_normal date;
				  status2 varchar2(100);
				  last_date2 date;
				  need_run boolean:=FALSE;
				  days number;
				  no_rows number;
				  issue1 boolean:=FALSE;
				  issue2 boolean:=FALSE;
				  issue3 boolean:=FALSE;
				  issue4 boolean:=FALSE;
				  issue5 boolean:=FALSE;
				  issue6 boolean:=FALSE;
				  issue7 boolean:=FALSE;
				  issue8 boolean:=FALSE;
				  issue9 boolean:=FALSE;
				  issue10 boolean:=FALSE;
				  issue11 boolean:=FALSE;
				  issue12 boolean:=FALSE;
				  issue13 boolean:=FALSE;
				  issue14 boolean:=FALSE;
				  issue15 boolean:=FALSE;
				  v_PROG_SCHEDULE_TYPE varchar2(100);
				  v_PROG_SCHEDULE varchar2(400);
				  v_USER_NAME fnd_user.user_name%type;
				  v_START_DATE fnd_concurrent_requests.requested_start_date%type;
				  v_ARGUMENT_TEXT FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  v_ARGUMENT_TEXT_all FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  v_ARGUMENT_TEXT_hr FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  v_ARGUMENT_TEXT_hxc FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  v_ARGUMENT_TEXT_hxt FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  v_ARGUMENT_TEXT_pa FND_CONC_REQ_SUMMARY_V.ARGUMENT_TEXT%type;
				  
				  begin
							 select count(1) into no_rows
							  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
								AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL');
								
							  if no_rows=0 then
								  issue1:=TRUE;
							  else
								  SELECT * 
								  into status_all,last_date_all,v_ARGUMENT_TEXT_all
								  FROM (
								  SELECT PHAS.MEANING || ' ' || STAT.MEANING pStatus       
								   ,ACTUAL_COMPLETION_DATE pEndDate,ARGUMENT_TEXT        
								  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL')
								  ORDER BY 2 desc)
								  where rownum < 2;
							  
								  if instr(upper(status_all),upper('Completed Normal'))=0 then 
									  issue2:=TRUE;
								  else
									  select  sysdate-last_date_all into days from dual;
									  if days>7 then
											issue3:=TRUE;
									  end if;
								  end if;
								end if;
								
								
							  select count(1) into no_rows
							  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
								AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,');
								
							  if no_rows=0 then
								  issue4:=TRUE;
							  else
								   SELECT * 
								  into status_hr,last_date_hr,v_ARGUMENT_TEXT_hr
								  FROM (
								  SELECT PHAS.MEANING || ' ' || STAT.MEANING pStatus       
								   ,ACTUAL_COMPLETION_DATE pEndDate ,ARGUMENT_TEXT       
								  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,')
								  ORDER BY 2 desc)
								  where rownum < 2;
							  
								  if instr(upper(status_hr),upper('Completed Normal'))=0 then 
									  issue5:=TRUE;
								  else
									  select  sysdate-last_date_hr into days from dual;
									  if days>7 then
											issue6:=TRUE;
									  end if;
								  end if;
								end if;
												

					-- HXC gather schema statistics
					select count(1) into no_rows
									  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
										AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC');
										
					if no_rows=0 then
										  issue7:=TRUE;
					else
										  SELECT * 
										  into status_hxc,last_date_hxc,v_ARGUMENT_TEXT_hxc
										  FROM (
										  SELECT PHAS.MEANING || ' ' || STAT.MEANING pStatus       
										   ,ACTUAL_COMPLETION_DATE pEndDate,ARGUMENT_TEXT        
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC')
										  ORDER BY 2 desc)
										  where rownum < 2;
										  
										  if instr(upper(status_hxc),upper('Completed Normal'))=0 then 
											  issue8:=TRUE;
										  else
											  select  sysdate-last_date_hxc into days from dual;
											  if days>7 then
													issue9:=TRUE;
											  end if;
										  end if;
					end if;
									  
					-- HXT gather schema statistics
					select count(1) into no_rows
									  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
										AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT');
										
					if no_rows=0 then
										  issue10:=TRUE;
									  else
										  SELECT * 
										  into status_hxt,last_date_hxt,v_ARGUMENT_TEXT_hxt
										  FROM (
										  SELECT PHAS.MEANING || ' ' || STAT.MEANING pStatus       
										   ,ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT')
										  ORDER BY 2 desc)
										  where rownum < 2;
									  
										  if instr(upper(status_hxt),upper('Completed Normal'))=0 then 
											  issue11:=TRUE;
										  else
											  select  sysdate-last_date_hxt into days from dual;
											  if days>7 then
													issue12:=TRUE;
											  end if;
										  end if;
										  
					end if;
									  
					-- PA gather schema statistics  
					select count(1) into no_rows
									  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
										AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,');
										
					if no_rows=0 then
										  issue13:=TRUE;
					else
										 SELECT * 
										  into status_pa,last_date_pa,v_ARGUMENT_TEXT_pa
										  FROM (
										  SELECT PHAS.MEANING || ' ' || STAT.MEANING pStatus       
										   ,ACTUAL_COMPLETION_DATE pEndDate ,ARGUMENT_TEXT       
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,')
										  ORDER BY 2 desc)
										  where rownum < 2;
									  
										  if instr(upper(status_pa),upper('Completed Normal'))=0 then 
											  issue14:=TRUE;
										  else
											  select  sysdate-last_date_pa into days from dual;
											  if days>7 then
													issue15:=TRUE;
											  end if;
										  end if;
										  
					end if;

								
											
					l_o(' <a name="gather"></a>');											
					 l_o('<DIV class=divItem>');
					l_o('<DIV id="s1sql13b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql13'');" href="javascript:;">&#9654; Gather Statistics</A></DIV>');                    
                    
					l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="4" id="s1sql13" style="display:none" >');
					l_o(' <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
					l_o('     <B>Statistics</B></TD>');
					l_o('     <TH bordercolor="#DEE6EF">');
					l_o('<A class=detail id="s1sql14b" onclick="displayItem2(this,''s1sql14'');" href="javascript:;">&#9654; Show SQL Script</A>');
					l_o('   </TD>');
					l_o(' </TR>');
					l_o(' <TR id="s1sql14" style="display:none">');
					l_o('    <TD colspan="4" height="60">');
					l_o('       <blockquote><p align="left">');
					l_o('          SELECT PHAS.MEANING || '' '' || STAT.MEANING pStatus <br>');                
					l_o('                     ,ACTUAL_COMPLETION_DATE pEndDate      <br>');  
					l_o('                      FROM FND_CONC_REQ_SUMMARY_V fcrs<br>');
					l_o('                     , FND_LOOKUPS STAT<br>');
					l_o('                     , FND_LOOKUPS PHAS<br>');
					l_o('                      WHERE STAT.LOOKUP_CODE = FCRS.STATUS_CODE<br>');
					l_o('                     AND STAT.LOOKUP_TYPE = ''CP_STATUS_CODE''<br>');
					l_o('                     AND PHAS.LOOKUP_CODE = FCRS.PHASE_CODE<br>');
					l_o('                      AND PHAS.LOOKUP_TYPE = ''CP_PHASE_CODE''<br>');
					l_o('                      AND (UPPER(program) LIKE ''%GATHER SCHEMA%''<br>');
					l_o('                      AND substr(UPPER(ARGUMENT_TEXT),1,3) in (''HR,'',''ALL''<br>');
					l_o('                      ,''HXC'',''HXT'',''PA,''');    
					l_o('                      ))<br>');
					l_o('                      ORDER BY 2 desc<br>');
					l_o('          </blockquote><br>');
					l_o('     </TD>');
					l_o('   </TR>');
					l_o(' <TR>');
                    l_o(' <TD><B>Request</B></TD>');
                    l_o(' <TD><B>Status</B></TD>');
                    l_o(' <TD><B>Last run</B></TD>');
					l_o(' <TD><B>Last Time Completed Normal</B></TD>');
					l_o(' <TD><B>Scheduling</B></TD>');
                  
                    :n := dbms_utility.get_time;
                    begin
                    l_o('<TR><TD>'||'Gather Schema Statistics for ALL'||'</TD>'||chr(10));
                    if issue1 then
                          l_o('<TD>'||'no run'||'</TD>'||chr(10)||'<TD>'||'no run'||'</TD><TD>no run</TD>'||chr(10));
                    elsif issue2 then
							if instr(upper(status_all),'ERROR')=0 then 
                                      issue2:=FALSE;
							end if;		  
							select count(1) into no_rows FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL')
									and PHAS.MEANING='Completed' and STAT.MEANING='Normal';
							if no_rows>0 then
								SELECT * 
								  into last_date_normal,v_ARGUMENT_TEXT
								  FROM (
								  SELECT ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
								  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL')
									and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
								  ORDER BY 1 desc)
								  where rownum < 2;
								  l_o('<TD>'||status_all||'</TD>'||chr(10)||'<TD>'||last_date_all||'</TD>'||chr(10));
								  l_o('<TD>'||last_date_normal||' with parameters:');
								  l_o(v_ARGUMENT_TEXT);
								  l_o('</TD>'||chr(10));
								  select  sysdate-last_date_normal into days from dual;
								  if days>7 then
										issue3:=TRUE;
										last_date_all:=last_date_normal;
								  else
										issue3:=FALSE;
								  end if;
							else
								l_o('<TD>'||status_all||'</TD>'||chr(10)||'<TD>'||last_date_all||'</TD>'||chr(10));
								l_o('<TD>never</TD>'||chr(10));
								issue2:=TRUE;
							end if;
					else
                          l_o('<TD>'||status_all||'</TD>'||chr(10)||'<TD>'||last_date_all||'</TD>'||chr(10));
						  l_o('<TD>'||last_date_all||' with parameters:');
						  l_o(v_ARGUMENT_TEXT_all);
						  l_o('</TD>'||chr(10));
                    end if;
					select count(1) into no_rows from fnd_concurrent_programs_tl fcpt,
									 fnd_concurrent_requests fcr,
									 fnd_user fu,
									 fnd_conc_release_classes fcrc
									 WHERE fcpt.application_id = fcr.program_application_id
									 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
									 AND fcr.requested_by = fu.user_id
									 AND fcr.phase_code = 'P'
									 AND fcr.requested_start_date > SYSDATE
									 AND fcpt.LANGUAGE = 'US'
									 AND fcrc.release_class_id(+) = fcr.release_class_id
									 AND fcrc.application_id(+) = fcr.release_class_app_id
									 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL');
					if no_rows=0 then
								l_o('<TD>no scheduling</TD></TR>'||chr(10));
					else						  
								select * into v_PROG_SCHEDULE_TYPE, v_PROG_SCHEDULE,v_user_name,v_START_DATE from (
								SELECT 
									 NVL2(fcr.resubmit_interval,
									 'PERIODICALLY',
									 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')) PROG_SCHEDULE_TYPE,
									 DECODE(NVL2(fcr.resubmit_interval,
									 'PERIODICALLY',
									 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
									 'PERIODICALLY',
									 'EVERY ' || fcr.resubmit_interval || ' ' ||
									 fcr.resubmit_interval_unit_code || ' FROM ' ||
									 fcr.resubmit_interval_type_code || ' OF PREV RUN',
									 'ONCE',
									 'AT :' ||
									 TO_CHAR(fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
									 'EVERY: ' || fcrc.class_info) PROG_SCHEDULE,
									 fu.user_name USER_NAME,
									 requested_start_date START_DATE									
									 FROM fnd_concurrent_programs_tl fcpt,
									 fnd_concurrent_requests fcr,
									 fnd_user fu,
									 fnd_conc_release_classes fcrc
									 WHERE fcpt.application_id = fcr.program_application_id
									 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
									 AND fcr.requested_by = fu.user_id
									 AND fcr.phase_code = 'P'
									 AND fcr.requested_start_date > SYSDATE
									 AND fcpt.LANGUAGE = 'US'
									 AND fcrc.release_class_id(+) = fcr.release_class_id
									 AND fcrc.application_id(+) = fcr.release_class_app_id
									 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('ALL')
									ORDER BY 2 desc)
									where rownum < 2;
								  
								  l_o('<TD>Schedule type: '||v_PROG_SCHEDULE_TYPE||' '||v_PROG_SCHEDULE);
								  l_o(' by user '||v_user_name||' starting date '||v_START_DATE||'</TD></TR>'||chr(10));
					end if;
                    
                    l_o('<TR><TD>'||'Gather Schema Statistics for HR'||'</TD>'||chr(10));
                    if issue4 then
                          l_o('<TD>'||'no run'||'</TD>'||chr(10)||'<TD>'||'no run'||'</TD><TD>no run</TD>'||chr(10));
                    elsif issue5 then
							if instr(upper(status_hr),'ERROR')=0 then 
                                      issue5:=FALSE;
							end if;
							select count(1) into no_rows FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,')
									and PHAS.MEANING='Completed' and STAT.MEANING='Normal';
							if no_rows>0 then
								SELECT * 
								  into last_date_normal,v_ARGUMENT_TEXT
								  FROM (
								  SELECT ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
								  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,')
									and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
								  ORDER BY 1 desc)
								  where rownum < 2;
								  l_o('<TD>'||status_hr||'</TD>'||chr(10)||'<TD>'||last_date_hr||'</TD>'||chr(10));
								  l_o('<TD>'||last_date_normal||' with parameters:');
								  l_o(v_ARGUMENT_TEXT);
								  l_o('</TD>'||chr(10));
								  select  sysdate-last_date_normal into days from dual;
								  if days>7 then
										issue6:=TRUE;
										last_date_hr:=last_date_normal;
								  else
										issue6:=FALSE;
								  end if;
							else
								l_o('<TD>'||status_hr||'</TD>'||chr(10)||'<TD>'||last_date_hr||'</TD>'||chr(10));
								l_o('<TD>never</TD>'||chr(10));
								issue5:=TRUE;
							end if;
					else
                          l_o('<TD>'||status_hr||'</TD>'||chr(10)||'<TD>'||last_date_hr||'</TD>'||chr(10));
						  l_o('<TD>'||last_date_hr||' with parameters:');
						  l_o(v_ARGUMENT_TEXT_hr);
						  l_o('</TD>'||chr(10));
                    end if;
					select count(1) into no_rows from fnd_concurrent_programs_tl fcpt,
									 fnd_concurrent_requests fcr,
									 fnd_user fu,
									 fnd_conc_release_classes fcrc
									 WHERE fcpt.application_id = fcr.program_application_id
									 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
									 AND fcr.requested_by = fu.user_id
									 AND fcr.phase_code = 'P'
									 AND fcr.requested_start_date > SYSDATE
									 AND fcpt.LANGUAGE = 'US'
									 AND fcrc.release_class_id(+) = fcr.release_class_id
									 AND fcrc.application_id(+) = fcr.release_class_app_id
									 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,');
					
					if no_rows=0 then
								l_o('<TD>no scheduling</TD></TR>'||chr(10));
					else						  
								select * into v_PROG_SCHEDULE_TYPE, v_PROG_SCHEDULE,v_user_name,v_START_DATE from (
								SELECT 
									 NVL2(fcr.resubmit_interval,
									 'PERIODICALLY',
									 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')) PROG_SCHEDULE_TYPE,
									 DECODE(NVL2(fcr.resubmit_interval,
									 'PERIODICALLY',
									 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
									 'PERIODICALLY',
									 'EVERY ' || fcr.resubmit_interval || ' ' ||
									 fcr.resubmit_interval_unit_code || ' FROM ' ||
									 fcr.resubmit_interval_type_code || ' OF PREV RUN',
									 'ONCE',
									 'AT :' ||
									 TO_CHAR(fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
									 'EVERY: ' || fcrc.class_info) PROG_SCHEDULE,
									 fu.user_name USER_NAME,
									 requested_start_date START_DATE
									 FROM fnd_concurrent_programs_tl fcpt,
									 fnd_concurrent_requests fcr,
									 fnd_user fu,
									 fnd_conc_release_classes fcrc
									 WHERE fcpt.application_id = fcr.program_application_id
									 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
									 AND fcr.requested_by = fu.user_id
									 AND fcr.phase_code = 'P'
									 AND fcr.requested_start_date > SYSDATE
									 AND fcpt.LANGUAGE = 'US'
									 AND fcrc.release_class_id(+) = fcr.release_class_id
									 AND fcrc.application_id(+) = fcr.release_class_app_id
									 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
									AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HR,')
									ORDER BY 2 desc)
									where rownum < 2;
								  
								  l_o('<TD>Schedule type: '||v_PROG_SCHEDULE_TYPE||' '||v_PROG_SCHEDULE);
								  l_o(' by user '||v_user_name||' starting date '||v_START_DATE||'</TD></TR>'||chr(10));
					end if;
                    
					
                  
                          l_o('<TR><TD>'||'Gather Schema Statistics for HXC'||'</TD>'||chr(10));
                          if issue7 then
								  l_o('<TD>'||'no run'||'</TD>'||chr(10)||'<TD>'||'no run'||'</TD><TD>no run</TD>'||chr(10));
							elsif issue8 then
									if instr(upper(status_hxc),'ERROR')=0 then 
                                      issue8:=FALSE;
									end if;
									select count(1) into no_rows FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal';
									if no_rows>0 then
										SELECT * 
										  into last_date_normal,v_ARGUMENT_TEXT
										  FROM (
										  SELECT ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
										  ORDER BY 1 desc)
										  where rownum < 2;
										  l_o('<TD>'||status_hxc||'</TD>'||chr(10)||'<TD>'||last_date_hxc||'</TD>'||chr(10));
										  l_o('<TD>'||last_date_normal||' with parameters:');
										  l_o(v_ARGUMENT_TEXT);
										  l_o('</TD>'||chr(10));
										  select  sysdate-last_date_normal into days from dual;
										  if days>7 then
												issue9:=TRUE;
												last_date_hxc:=last_date_normal;
										  else
												issue9:=FALSE;
										  end if;
									else
										l_o('<TD>'||status_hxc||'</TD>'||chr(10)||'<TD>'||last_date_hxc||'</TD>'||chr(10));
										l_o('<TD>never</TD>'||chr(10));
										issue8:=TRUE;
									end if;
							else
								  l_o('<TD>'||status_hxc||'</TD>'||chr(10)||'<TD>'||last_date_hxc||'</TD>'||chr(10));
								  l_o('<TD>'||last_date_hxc||' with parameters:');
								  l_o(v_ARGUMENT_TEXT_hxc);
								  l_o('</TD>'||chr(10));
							end if;
							select count(1) into no_rows from fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC');
							
							if no_rows=0 then
										l_o('<TD>no scheduling</TD></TR>'||chr(10));
							else						  
										select * into v_PROG_SCHEDULE_TYPE, v_PROG_SCHEDULE,v_user_name,v_START_DATE from (
										SELECT 
											 NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')) PROG_SCHEDULE_TYPE,
											 DECODE(NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
											 'PERIODICALLY',
											 'EVERY ' || fcr.resubmit_interval || ' ' ||
											 fcr.resubmit_interval_unit_code || ' FROM ' ||
											 fcr.resubmit_interval_type_code || ' OF PREV RUN',
											 'ONCE',
											 'AT :' ||
											 TO_CHAR(fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
											 'EVERY: ' || fcrc.class_info) PROG_SCHEDULE,
											 fu.user_name USER_NAME,
											 requested_start_date START_DATE											 
											 FROM fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXC')
											ORDER BY 2 desc)
											where rownum < 2;
										  
										  l_o('<TD>Schedule type: '||v_PROG_SCHEDULE_TYPE||' '||v_PROG_SCHEDULE);
										  l_o(' by user '||v_user_name||' starting date '||v_START_DATE||'</TD></TR>'||chr(10));
							end if;
                          
                          l_o('<TR><TD>'||'Gather Schema Statistics for HXT'||'</TD>'||chr(10));
                          if issue10 then
								  l_o('<TD>'||'no run'||'</TD>'||chr(10)||'<TD>'||'no run'||'</TD><TD>no run</TD>'||chr(10));
							elsif issue11 then
									if instr(upper(status_hxt),'ERROR')=0 then 
                                      issue11:=FALSE;
									end if;
									select count(1) into no_rows FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal';
									if no_rows>0 then
										SELECT * 
										  into last_date_normal,v_ARGUMENT_TEXT
										  FROM (
										  SELECT ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
										  ORDER BY 1 desc)
										  where rownum < 2;
										  l_o('<TD>'||status_hxt||'</TD>'||chr(10)||'<TD>'||last_date_hxt||'</TD>'||chr(10));
										  l_o('<TD>'||last_date_normal||' with parameters:');
										  l_o(v_ARGUMENT_TEXT);
										  l_o('</TD>'||chr(10));
										  select  sysdate-last_date_normal into days from dual;
										  if days>7 then
												issue12:=TRUE;
												last_date_hxt:=last_date_normal;
										  else
												issue12:=FALSE;
										  end if;
									else
										l_o('<TD>'||status_hxt||'</TD>'||chr(10)||'<TD>'||last_date_hxt||'</TD>'||chr(10));
										l_o('<TD>never</TD>'||chr(10));
										issue11:=TRUE;
									end if;
							else
								  l_o('<TD>'||status_hxt||'</TD>'||chr(10)||'<TD>'||last_date_hxt||'</TD>'||chr(10));
								  l_o('<TD>'||last_date_hxt||' with parameters:');
								  l_o(v_ARGUMENT_TEXT_hxt);
								  l_o('</TD>'||chr(10));
							end if;
							select count(1) into no_rows from fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT');
							
							if no_rows=0 then
										l_o('<TD>no scheduling</TD></TR>'||chr(10));
							else						  
										select * into v_PROG_SCHEDULE_TYPE, v_PROG_SCHEDULE,v_user_name,v_START_DATE from (
										SELECT 
											 NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')) PROG_SCHEDULE_TYPE,
											 DECODE(NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
											 'PERIODICALLY',
											 'EVERY ' || fcr.resubmit_interval || ' ' ||
											 fcr.resubmit_interval_unit_code || ' FROM ' ||
											 fcr.resubmit_interval_type_code || ' OF PREV RUN',
											 'ONCE',
											 'AT :' ||
											 TO_CHAR(fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
											 'EVERY: ' || fcrc.class_info) PROG_SCHEDULE,
											 fu.user_name USER_NAME,
											 requested_start_date START_DATE											 
											 FROM fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('HXT')
											ORDER BY 2 desc)
											where rownum < 2;
										  
										  l_o('<TD>Schedule type: '||v_PROG_SCHEDULE_TYPE||' '||v_PROG_SCHEDULE);
										  l_o(' by user '||v_user_name||' starting date '||v_START_DATE||'</TD></TR>'||chr(10));
							end if;
                          
                          l_o('<TR><TD>'||'Gather Schema Statistics for PA'||'</TD>'||chr(10));
                          		if issue13 then
								  l_o('<TD>'||'no run'||'</TD>'||chr(10)||'<TD>'||'no run'||'</TD><TD>no run</TD>'||chr(10));
							elsif issue14 then
									if instr(upper(status_pa),'ERROR')=0 then 
                                      issue14:=FALSE;
									end if;
									select count(1) into no_rows FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal';
									if no_rows>0 then
										SELECT * 
										  into last_date_normal,v_ARGUMENT_TEXT
										  FROM (
										  SELECT ACTUAL_COMPLETION_DATE pEndDate, ARGUMENT_TEXT        
										  FROM FND_CONCURRENT_PROGRAMS_TL PT, FND_CONCURRENT_PROGRAMS PB, FND_CONCURRENT_REQUESTS R
										, FND_LOOKUP_VALUES STAT
										, FND_LOOKUP_VALUES PHAS 
										WHERE PB.APPLICATION_ID = R.PROGRAM_APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID 
										AND PB.APPLICATION_ID = PT.APPLICATION_ID AND PB.CONCURRENT_PROGRAM_ID = PT.CONCURRENT_PROGRAM_ID 
										AND PT.LANGUAGE = 'US' and
										STAT.LOOKUP_CODE = R.STATUS_CODE
													AND STAT.LOOKUP_TYPE = 'CP_STATUS_CODE'
													AND PHAS.LOOKUP_CODE = R.PHASE_CODE
													AND PHAS.LOOKUP_TYPE = 'CP_PHASE_CODE' and PHAS.language='US' and STAT.language='US' and PHAS.VIEW_APPLICATION_ID = 0 and STAT.VIEW_APPLICATION_ID = 0
													AND UPPER(USER_CONCURRENT_PROGRAM_NAME) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,')
											and PHAS.MEANING='Completed' and STAT.MEANING='Normal'
										  ORDER BY 1 desc)
										  where rownum < 2;
										  l_o('<TD>'||status_pa||'</TD>'||chr(10)||'<TD>'||last_date_pa||'</TD>'||chr(10));
										  l_o('<TD>'||last_date_normal||' with parameters:');
										  l_o(v_ARGUMENT_TEXT);
										  l_o('</TD>'||chr(10));
										  select  sysdate-last_date_normal into days from dual;
										  if days>7 then
												issue15:=TRUE;
												last_date_pa:=last_date_normal;
										  else
												issue15:=FALSE;
										  end if;
									else
										l_o('<TD>'||status_pa||'</TD>'||chr(10)||'<TD>'||last_date_pa||'</TD>'||chr(10));
										l_o('<TD>never</TD>'||chr(10));
										issue14:=TRUE;
									end if;
							else
								  l_o('<TD>'||status_pa||'</TD>'||chr(10)||'<TD>'||last_date_pa||'</TD>'||chr(10));
								  l_o('<TD>'||last_date_pa||' with parameters:');
								  l_o(v_ARGUMENT_TEXT_pa);
								  l_o('</TD>'||chr(10));
							end if;
							select count(1) into no_rows from fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,');
							
							if no_rows=0 then
										l_o('<TD>no scheduling</TD></TR>'||chr(10));
							else						  
										select * into v_PROG_SCHEDULE_TYPE, v_PROG_SCHEDULE,v_user_name,v_START_DATE from (
										SELECT 
											 NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')) PROG_SCHEDULE_TYPE,
											 DECODE(NVL2(fcr.resubmit_interval,
											 'PERIODICALLY',
											 NVL2(fcr.release_class_id, 'ON SPECIFIC DAYS', 'ONCE')),
											 'PERIODICALLY',
											 'EVERY ' || fcr.resubmit_interval || ' ' ||
											 fcr.resubmit_interval_unit_code || ' FROM ' ||
											 fcr.resubmit_interval_type_code || ' OF PREV RUN',
											 'ONCE',
											 'AT :' ||
											 TO_CHAR(fcr.requested_start_date, 'DD-MON-RR HH24:MI'),
											 'EVERY: ' || fcrc.class_info) PROG_SCHEDULE,
											 fu.user_name USER_NAME,
											 requested_start_date START_DATE
											 FROM fnd_concurrent_programs_tl fcpt,
											 fnd_concurrent_requests fcr,
											 fnd_user fu,
											 fnd_conc_release_classes fcrc
											 WHERE fcpt.application_id = fcr.program_application_id
											 AND fcpt.concurrent_program_id = fcr.concurrent_program_id
											 AND fcr.requested_by = fu.user_id
											 AND fcr.phase_code = 'P'
											 AND fcr.requested_start_date > SYSDATE
											 AND fcpt.LANGUAGE = 'US'
											 AND fcrc.release_class_id(+) = fcr.release_class_id
											 AND fcrc.application_id(+) = fcr.release_class_app_id
											 and upper(fcpt.user_concurrent_program_name) LIKE '%GATHER SCHEMA%'
											AND substr(UPPER(ARGUMENT_TEXT),1,3) in ('PA,')
											ORDER BY 2 desc)
											where rownum < 2;
										  
										  l_o('<TD>Schedule type: '||v_PROG_SCHEDULE_TYPE||' '||v_PROG_SCHEDULE);
										  l_o(' by user '||v_user_name||' starting date '||v_START_DATE||'</TD></TR>'||chr(10));
							end if;
              
					EXCEPTION
						when others then			  
						  l_o('<br>'||sqlerrm ||' occurred in test');
						  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
					end;
			
					:n := (dbms_utility.get_time - :n)/100;
					l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
					l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
					l_o(' </TABLE> </div> ');


					l_o('<div class="divwarn">');
					if issue1 and issue4 then
							l_o('<img class="warn_ico" id="sigp3"><span class="sectionorange">Warning: </span>You never performed Gather Schema Statistics for HR!<br> ');
							:w1:=:w1+1;
					end if;
									  
					if issue2 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for ALL is not Completed Normal. <br> ');
							:w1:=:w1+1;
					end if;
									  
					if issue5 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for HR is not Completed Normal. <br> ');
							:w1:=:w1+1;
					end if;
									  
					if issue1 and issue6 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your never performed gather schema statistics for ALL, and for HR was on '||last_date_hr||'.');
							l_o('Frequency of this concurrent request depends on payroll cycle, i.e.  If payroll is run weekly, these tables should be gathered weekly, if bi-weekly Payroll, then stats within last 15 days, etc.<br>');                  
							:w1:=:w1+1;
					end if;
									  
					if issue3 and (issue6 or issue5 or issue4) then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Your last run of gather schema statistics for ALL was on ' || last_date_all);
							l_o('Frequency of this concurrent request depends on payroll cycle, i.e.  If payroll is run weekly, these tables should be gathered weekly, if bi-weekly Payroll, then stats within last 15 days, etc.<br>');                  
							:w1:=:w1+1;                         
					  elsif issue3 and issue6 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for ALL was on ' || last_date_all||' and, for HR was on '||last_date_hr||'.');
							l_o('Frequency of this concurrent request depends on payroll cycle, i.e.  If payroll is run weekly, these tables should be gathered weekly, if bi-weekly Payroll, then stats within last 15 days, etc.<br>'); 
							:w1:=:w1+1;
					end if;
									  
					if issue1 and issue7 then
							l_o('<img class="warn_ico" id="sigp2"><span class="sectionorange">Warning: </span>You never performed Gather Schema Statistics for HXC!<br> ');
							:w1:=:w1+1;
					end if;
					
					if issue8 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for HXC is not Completed Normal. Verify the log and schedule it as per ');
							:w1:=:w1+1;
					end if;
											
					if issue1 and issue9 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your never performed gather schema statistics for ALL and for HXC was on '||last_date_hxc||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');  
							:w1:=:w1+1;
					end if;
											
					if issue3 and issue9 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for ALL was on ' || last_date_all||' and for HXC was on '||last_date_hxc||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');
							:w1:=:w1+1;							
					end if;
											
					if issue1 and issue10 then
							l_o('<img class="warn_ico" id="sigp1"><span class="sectionorange">Warning: </span>You never performed Gather Schema Statistics for HXT!<br> ');
							:w1:=:w1+1;
					end if;
					if issue11 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for HXT is not Completed Normal. Verify the log and schedule it as per ');
							:w1:=:w1+1;
					end if;
											
					if issue1 and issue12 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your never performed gather schema statistics for ALL, and for HXT was on '||last_date_hxt||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');  
							:w1:=:w1+1;
					end if;
											  
					if issue3 and issue12 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for ALL was on ' || last_date_all||', and for HXT was on '||last_date_hxt||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');
							:w1:=:w1+1;							
					end if;
											
					if issue1 and issue13 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>You never performed Gather Schema Statistics for PA!<br> ');
							:w1:=:w1+1;
					end if;
					if issue14 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for PA is not Completed Normal. Verify the log and schedule it as per ');
							:w1:=:w1+1;
					end if;
					if issue1 and issue15 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your never performed gather schema statistics for ALL, and for PA was on '||last_date_pa||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');  
							:w1:=:w1+1;
					end if;
					if issue3 and issue15 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Your last run of gather schema statistics for ALL was on ' || last_date_all||', and for PA was on '||last_date_pa||'.');
							l_o('Frequency of this concurrent request should be weekly.<br>');  
							:w1:=:w1+1;
					end if;
															 
					if (issue1 and issue4) or issue2 or issue5 or (issue1 and issue6) or (issue3 and (issue6 or issue5 or issue4)) or (issue1 and issue7) or issue8 or (issue1 and issue9) or (issue3 and issue9) 
									or (issue1 and issue10) or issue11 or  (issue1 and issue12) or(issue3 and issue12) or (issue1 and issue13) or issue14 or (issue1 and issue15) or (issue3 and issue15) then
							l_o('In order to schedule use <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=419728.1" target="_blank" >Doc ID 419728.1</a> ');
							l_o('Concurrent Processing - How To Gather Statistics On Oracle Applications Release 11i and/or Release 12 - Concurrent Process,Temp Tables, Manually <br>');
					end if;
					l_o('</div>'); 
					
					if not issue1 and not issue2 and not issue3 then
							l_o('<div class="divok1">');
							l_o('<img class="check_ico">OK! Gather Scema statistics was performed in last week without errors.<br><br>');
							l_o('</div>');
					else
							if issue2 or issue3 or issue4 or issue5 or issue6 or issue7 or issue8 or issue9 or issue10 or issue11 or issue12 or issue13 or issue14 or issue15 then
									l_o('<div class="divwarn">');
									 l_o('Please review also <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=226987.1" target="_blank" >Doc ID 226987.1</a> ');
									 l_o('Oracle 11i and R12 Human Resources (HRMS) and Benefits (BEN) Tuning and System Health Checks <br>');                         
									 l_o('</div>');
								 else
										l_o('<div class="divok1">');
										l_o('<img class="check_ico">OK! Gather Scema statistics was performed in last week without errors.<br><br>');
										l_o('</div>');
							end if;
					end if;
					 
					l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				  EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				  end;

-- Display timestamp desyncronization issues				  
procedure timestampd is
				issue boolean := FALSE;
				v_problems number:=0;
				begin
					select count(1) into v_problems
							 from sys.obj$ do, sys.dependency$ d, sys.obj$ po
							 where p_obj#=po.obj#(+)
							 and d_obj#=do.obj#
							 and do.status=1 
							 and po.status=1 
							 and po.stime!=p_timestamp 
							 and do.type# not in (28,29,30) 
							 and po.type# not in (28,29,30) ;
			 
					if v_problems>0 then

						  l_o(' <a name="timestamp"></a>');
						  l_o('<DIV class=divItem>');
						  l_o('<DIV id="s1sql21b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql21'');" href="javascript:;">&#9654; Dependency timestamp discrepancies</A></DIV>');
		
						  l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql21" style="display:none" >');
						  l_o('   <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
						  l_o('     <B>Dependency timestamp discrepancies between the database objects:</B></font></TD>');
						  l_o('     <TH bordercolor="#DEE6EF">');
						  l_o('<A class=detail id="s1sql22b" onclick="displayItem2(this,''s1sql22'');" href="javascript:;">&#9654; Show SQL Script</A>');
						  l_o('   </TD>');
						  l_o(' </TR>');
						  l_o(' <TR id="s1sql22" style="display:none">');
						  l_o('    <TD colspan="2" height="60">');
						  l_o('       <blockquote><p align="left">');
						  l_o('          select count(1)  <br>');
						  l_o('                from sys.obj$ do, sys.dependency$ d, sys.obj$ po <br>');
						  l_o('                     where p_obj#=po.obj#(+)<br>');
						  l_o('                     and d_obj#=do.obj#<br>');
						  l_o('                     and do.status=1 <br>');
						  l_o('                     and po.status=1 <br>');
						  l_o('                     and po.stime!=p_timestamp <br>');
						  l_o('                     and do.type# not in (28,29,30)<br>');
						  l_o('                     and po.type# not in (28,29,30) ;<br>');
						  l_o('          </blockquote><br>');
						  l_o('     </TD>');
						  l_o('   </TR>');
						  l_o(' <TR>');
						  l_o(' <TH><B>Number</B></TD>');
						
						  :n := dbms_utility.get_time;
						  
						  l_o('<TR><TD>'||v_problems||'</TD></TR>'||chr(10));
						   
						
						  
						  :n := (dbms_utility.get_time - :n)/100;
						  l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
						  l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						  l_o(' </TABLE> </div> ');
						  if v_problems>0 then
								l_o('<div class="diverr" id="sig4">');
								l_o('<img class="error_ico"><font color="red">Error:</font> You have dependency timestamp discrepancies between the database objects.<br>');
								l_o('Please follow <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=370137.1" target="_blank">Doc ID 370137.1</a>' );
								l_o('After Upgrade, Some Packages Intermittently Fail with ORA-04065');                     
								l_o('</div>');
								:e1:=:e1+1;
						  else 
								l_o('<div class="divok1">');
								l_o('<img class="check_ico">OK! No dependency timestamp discrepancies between the database objects found.');
								l_o('</div>');
						  end if;
						  l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
					end if;
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display invalid objects				
procedure invalids is
				v_name dba_objects.object_name%type; 
				v_type dba_objects.object_type%type;
				v_owner dba_objects.owner%type;
				no_invalids number;
				no_errors number;
				inv_error varchar2(250);
				issue boolean := FALSE;

				cursor invalids_otl is
					select owner,object_name,object_type
				  from dba_objects
				  where status != 'VALID' and object_type != 'UNDEFINED' and
				  (object_name like 'PAY%' or object_name like 'HX%' or object_name like 'WF%');
				
				cursor invalid_errors (object varchar2, object_type varchar2, object_owner varchar2) is
				  select nvl(substr(text,1,240) ,'null')
				  from   all_errors
					where  name = object
					and    type = object_type
					and    owner = object_owner;
				begin
										l_o(' <a name="invalids"></a>');

								  select count(1) into no_invalids from dba_objects   where status != 'VALID' and object_type != 'UNDEFINED' 
								  and (object_name like 'HX%' or object_name like 'PAY%' or object_name like 'WF%');
								  if no_invalids>0 then
										issue:=TRUE;
								  end if;

						l_o(' <a name="invalids"></a>');
							l_o('<DIV class=divItem>');
							l_o('<DIV id="s1sql17b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql17'');" href="javascript:;">&#9654; Invalid Objects</A></DIV>');
									
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="3" id="s1sql17" style="display:none" >');
							l_o('  <TR><TH COLSPAN=3 bordercolor="#DEE6EF">');
							l_o('     <B>Fix next invalid objects:</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql18b" onclick="displayItem2(this,''s1sql18'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD>');
							l_o(' </TR>');
							l_o(' <TR id="s1sql18" style="display:none">');
							l_o('    <TD colspan="3" height="60">');
							l_o('       <blockquote><p align="left">');
							l_o('         select owner, object_name, object_type <br>');
							l_o('               from dba_objects<br>');
							l_o('               where status != ''VALID'' and object_type != ''UNDEFINED'' <br>');
							l_o('                and (object_name like ''HX%'' or object_name like ''PAY%'' or object_name like ''WF%'') <br>'); 
							l_o('          </blockquote><br>');
							l_o('     </TD>');
							l_o('   </TR>');
							l_o(' <TR>');
							l_o(' <TH><B>Owner</B></TD>');
							l_o(' <TH><B>Object</B></TD>');
							l_o(' <TH><B>Type</B></TD>');
							l_o(' <TH><B>Error</B></TD>');
						
							:n := dbms_utility.get_time;
						
						

								  open invalids_otl;
								  loop
										fetch invalids_otl into v_owner,v_name,v_type;
										EXIT WHEN  invalids_otl%NOTFOUND;
										l_o('<TR><TD>'||v_owner||'</TD>'||chr(10)||'<TD>'|| v_name||'</TD>'||chr(10)||'<TD>'||v_type||'</TD>'||chr(10)||'<TD>');
										select count(1) into no_errors from all_errors where name = v_name and type=v_type and owner=v_owner;
										if no_errors>0 then
											  open invalid_errors(v_name, v_type, v_owner);
												loop
													fetch invalid_errors into inv_error;
													EXIT WHEN  invalid_errors%NOTFOUND;
													l_o(substr(inv_error,1,240)||'<br>');							  
												end loop;
												close invalid_errors;                          
										end if;
											l_o('</TD></TR>'||chr(10));
									end loop;
								  close invalids_otl;
							
						
							
							:n := (dbms_utility.get_time - :n)/100;
							if no_invalids>100 then
								l_o('<tr><td><A class=detail onclick="hideRow(''s1sql17'');" href="javascript:;">Collapse section</a></td></tr>');
							end if;
							l_o(' <TR><TH COLSPAN=3 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE> </div> ');
							
							
							if issue then
									l_o('<div class="divwarn">');
									l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>You have '||no_invalids||' invalid objects.</span><br>');
									l_o('<span class="sectionblue1">Advice:</span>Please run adadmin - Compile apps schema.<br>');
									l_o('If you still have invalids review steps from: <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1325394.1" target="_blank">Doc ID 1325394.1</a>');
									l_o(' Troubleshooting Guide - invalid objects in the E-Business Suite Environment 11i and 12');	
									l_o('</div><br>');
									:w1:=:w1+1;
							else
								  l_o('<div class="divok1">');
								  l_o('<img class="check_ico">OK! No invalid object found.');
								  l_o('</div><br>');								  
							end if;
							
							l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display disabled triggers				
procedure triggers is
				v_owner dba_triggers.owner%type; 
				v_table dba_triggers.table_name%type;
				v_trigger dba_triggers.trigger_name%type;
				no_triggers number;
				no_triggers2 number;
				issue boolean := FALSE;
				issue_alr boolean := FALSE;
				issue_only_alr boolean := FALSE;
				cursor disabled_triggers_otl is
					select owner, table_name, trigger_name 
				  from dba_triggers
				  where status = 'DISABLED'
				  and table_owner in ('HR','HXT','HXC')
				  and (table_name like 'PAY%' or table_name like 'HX%')
				  order by 1, 2, 3; 
				begin
						l_o(' <a name="triggers"></a>');
						
						select count(1) into no_triggers from dba_triggers   where status = 'DISABLED'
						  and table_owner in ('HR','HXT','HXC')
						  and (table_name like 'HX%' or table_name like 'PAY%');
						  if no_triggers>0 then
								issue:=TRUE;
						  end if;
						  select count(1) into no_triggers2 from dba_triggers   where status = 'DISABLED'
						  and table_owner in ('HR','HXT','HXC')
						  and (table_name like 'HX%' or table_name like 'PAY%')
						  and trigger_name like 'ALR%';
						if no_triggers2>0 then
								issue_alr:=TRUE;
								if no_triggers2=no_triggers then
									issue_only_alr:=TRUE;
								end if;
						end if;
				  
						l_o('<DIV class=divItem>');
						l_o('<DIV id="s1sql19b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql19'');" href="javascript:;">&#9654; Disabled Triggers</A></DIV>');
		
						l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql19" style="display:none" >');
						l_o('   <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
						l_o('     <B>Disabled triggers:</B></font></TD>');
						l_o('     <TH bordercolor="#DEE6EF">');
						l_o('<A class=detail id="s1sql20b" onclick="displayItem2(this,''s1sql20'');" href="javascript:;">&#9654; Show SQL Script</A>');
						l_o('   </TD>');
						l_o(' </TR>');
						l_o(' <TR id="s1sql20" style="display:none">');
						l_o('    <TD colspan="2" height="60">');
						l_o('       <blockquote><p align="left">');
						l_o('          select owner, table_name, trigger_name <br>');
						l_o('                from dba_triggers <br>');
						l_o('                where status = ''DISABLED'' <br>');
						l_o('                and table_owner in (''HR'',''HXT'',''HXC'',''HRI'',''BEN'') <br>');
						l_o('                and (table_name like ''HX%'' or table_name like ''PAY%'') <br>'); 
						l_o('                order by 1, 2, 3; <br>');
						l_o('          </blockquote><br>');
						l_o('     </TD>');
						l_o('   </TR>');
						l_o(' <TR>');
						l_o(' <TH><B>Owner</B></TD>');
						l_o(' <TH><B>Table name</B></TD>');
						l_o(' <TH><B>Trigger Name</B></TD>');
					
						:n := dbms_utility.get_time;
					
						open disabled_triggers_otl;
						loop
						   fetch disabled_triggers_otl into v_owner,v_table,v_trigger;
						   EXIT WHEN  disabled_triggers_otl%NOTFOUND;
						   if v_trigger like 'ALR%' then
								l_o('<TR><TD>'||v_owner||'</TD>'||chr(10)||'<TD>'||v_table||'</TD>'||chr(10)||'<TD>'||v_trigger||'</TD></TR>'||chr(10));
							 else
								l_o('<TR><TD>'||v_owner||'</TD>'||chr(10)||'<TD>'||v_table||'</TD>'||chr(10));
								l_o('<TD><font color="#CC3311">'||v_trigger||'</font></TD></TR>'||chr(10));
							 end if;
						end loop;
						close disabled_triggers_otl;
				 
					
						
						:n := (dbms_utility.get_time - :n)/100;
						l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE> </div> ');
						
						if issue and (not issue_alr) then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> You have disabled trigger(s).<br>');
							l_o('In order to re-enable use command: alter trigger trigger_name enable ><br>');
							l_o('</div>');
							:w1:=:w1+1;
						elsif issue_only_alr then
							l_o('<div class="divok">');
							l_o(' You have disabled trigger(s) only related to alert. These are event triggers created inside Oracle Alert, so you can ignore them if not using Oracle Alert.<br>');
							l_o('</div>');
						elsif issue_alr and (not issue_only_alr) then
							l_o('<div class="divwarn">');
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> You have disabled trigger(s).<br>');
							l_o('In order to re-enable use command: alter trigger trigger_name enable<br>');
							l_o('You have disabled trigger(s) related to alert (ALR_). These are event triggers created inside Oracle Alert, so you can ignore them if not using Oracle Alert.<br>');
							l_o('Please focus on not ALR_ disabled triggers.<br>');
							l_o('</div>');
							:w1:=:w1+1;
						elsif  (not issue) then             
							l_o('<div class="divok1">');
							l_o('<img class="check_ico">OK! No disabled trigger.<br>');
							l_o('</div>');
						end if;
						l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');		
				end;

-- Main program			
begin
declare

  
begin  
  :g_curr_loc:=1;
  Show_Header('9999999.999', '&v_scriptlongname', '&v_headerinfo', '&v_queries_ver');
  
  :e1:=0;
  :e2:=0;
  :e3:=0;
  :e4:=0;
  :e5:=0;
  :e6:=0;
  :w1:=0;
  :w2:=0;
  :w3:=0;
  :w4:=0;
  :w5:=0;
  :w6:=0;



  l_o('<div id="tabCtrl">');
  l_o('<div id="page1" style="display: block;">');
if upper('&&1') = 'N' then
   l_o('Choose the relevant information you want to see from the above menu');
end if;

-- Display OTL Technical Information
if upper('&&1') = 'N' then
overview();
else
-- ************************
-- *** OTL Technical Information 
-- ************************
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">');
	l_o('<div class="left"  id="technical" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">Technical Information: '); 
	l_o('</div><div class="right" font style="font-weight: normal; font-size: small;" align="right" color="#FFFFFF">'); 
    l_o('<a class="detail" onclick="openall();" href="javascript:;">');
    l_o('<font color="#FFFFFF">&#9654; Expand All Checks</font></a>'); 
    l_o('<font color="#FFFFFF">&nbsp;/ &nbsp; </font><a class="detail" onclick="closeall();" href="javascript:;">');
    l_o('<font color="#FFFFFF">&#9660; Collapse All Checks</font></a> ');
    l_o('</div><div class="clear"></div></div><br>');
	
	l_o('<div class="divItem" >');
	l_o('<div class="divItemTitle">In This Section</div>');
				table_contents();
	l_o('</div><br/>');
	l_o('</div><br><br>');
	
	
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">Instance Overview</div><br>');
				overview();
				languages();
				patching();
				projects_paching();
				atg_patching();
				hrglobal();
				datainstalled();
				statutory();
				baseline();
				performance();
	l_o('</div><br><br>');
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">Versions</div><br>');
				packages_version();
				java_version();
				forms_version();
				reports_version();
				ldt_version();
				odf_version();
				sql_version();
				workflow_version();
	l_o('</div><br><br>');	
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">Performance</div><br>');
				database();
				gather() ;
	l_o('</div><br>');
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">Workflow</div><br>');		 
				purging();
				workflow();
	l_o('</div><br>');
	l_o('<div class="divSection">');
	l_o('<div class="divSectionTitle">Database Issues</div><br>');
				timestampd();
				invalids();
				triggers();
	l_o('</div><br><br>');
				
				
end if;
l_o('</div>');


	l_o('<!-');

EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
	
end;	
end;
/

-- Print CLOB
print :g_hold_output


-- Second main (split due to "program too long" error)

variable g_hold_output2 clob;
variable g_curr_loc2 number;

declare
-- Display lines in HTML format
procedure l_o (text varchar2) is
   l_ptext      varchar2(32767);
   l_hold_num   number;
   l_ptext2      varchar2(32767);
   l_hold_num2   number;
begin
   l_hold_num := mod(:g_curr_loc2, 32767);
   
   l_hold_num2 := mod(:g_curr_loc2, 14336);
   if l_hold_num2 + length(text) > 14000 then
      l_ptext2 := '                                                                                                                                                                                              ';
      dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
   end if;
   
   l_hold_num2 := mod(:g_curr_loc2, 18204);
   if l_hold_num2 + length(text) > 17900 then
      l_ptext2 := '                                                                                                                                                                                              ';
      dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);	 
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);
	  dbms_lob.write(:g_hold_output2, length(l_ptext2), :g_curr_loc2, l_ptext2);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext2);	
   end if;
   
   if l_hold_num + length(text) > 32759 then
      l_ptext := '<!--' || rpad('*', 32761-l_hold_num,'*') || '-->';
      dbms_lob.write(:g_hold_output2, length(l_ptext), :g_curr_loc2, l_ptext);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext);
	  dbms_lob.write(:g_hold_output2, length(l_ptext), :g_curr_loc2, l_ptext);
      :g_curr_loc2 := :g_curr_loc2 + length(l_ptext);
   end if;
   dbms_lob.write(:g_hold_output2, length(text)+1, :g_curr_loc2, text || chr(10));
   :g_curr_loc2 := :g_curr_loc2 + length(text)+1;
   
   --dbms_lob.write(:g_hold_output2, length(text), :g_curr_loc2, text );
   --:g_curr_loc2 := :g_curr_loc2 + length(text);
   
end l_o;

-- Display HR profiles				
procedure hr_profiles is
			v_name fnd_profile_options_tl.user_profile_option_name%type; 
			v_short_name fnd_profile_options.profile_option_name%type;
			v_short_name_old fnd_profile_options.profile_option_name%type;
			v_level varchar2(50);
			v_level_old varchar2(50);
			v_context varchar2(1000);
			v_value fnd_profile_option_values.profile_option_value%type;
			v_id fnd_profile_options.PROFILE_OPTION_ID%type;
			v_big_no_old number;
			v_big_no number;    
			cursor hr_profiles is
			select n.user_profile_option_name,
			  po.profile_option_name ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', 'Application',
					  '10003', 'Responsibility',
					  '10005', 'Server',
					  '10006', 'Org',
					  '10007', 'Servresp',
					  '10004', 'User', '???') ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', nvl(app.application_short_name,to_char(pov.level_value)),
					  '10003', nvl(rsp.responsibility_name,to_char(pov.level_value)),
					  '10005', svr.node_name,
					  '10006', org.name,
					  '10007', pov.level_value ||', '|| pov.level_value_application_id ||', '|| pov.level_value2,
					  '10004', nvl(usr.user_name,to_char(pov.level_value)),
					  '???') ,
			   pov.profile_option_value 
				from   fnd_profile_options po,
					   fnd_profile_option_values pov,
					   fnd_profile_options_tl n,
					   fnd_user usr,
					   fnd_application app,
					   fnd_responsibility_vl rsp,
					   fnd_nodes svr,
					   hr_operating_units org
				where  po.profile_option_name in
					('FND_PPR_DISABLED',
					'FND_DISABLE_OA_CUSTOMIZATIONS',
					'FND_PPR_DISABLED',
					'HR_SCH_BASED_ABS_CALC',					
					'ORG_ID',
					'PER_SECURITY_PROFILE_ID',
					'PER_BUSINESS_GROUP_ID'	,
					'DATETRACK:ENABLED'	,
					'HR_USER_TYPE',
					'HR_ABS_OTL_INTEGRATION',
					'PER_ACCRUAL_PLAN_ELEMENT_SET',
					'PER_ABSENCE_DURATION_AUTO_OVERWRITE',
					'XLA_MO_SECURITY_PROFILE_LEVEL'
					)
				and    pov.application_id = po.application_id
				and    po.profile_option_name = n.profile_option_name
				and    pov.profile_option_id = po.profile_option_id
				and    usr.user_id (+) = pov.level_value
				and    rsp.application_id (+) = pov.level_value_application_id
				and    rsp.responsibility_id (+) = pov.level_value
				and    app.application_id (+) = pov.level_value
				and    svr.node_id (+) = pov.level_value
				and    svr.node_id (+) = pov.level_value2
				and    org.organization_id (+) = pov.level_value
				and    n.language='US'
				order by n.user_profile_option_name,pov.level_id;
				v_security	varchar2(42);
				v_rows number;
				v_org_name HR_ALL_ORGANIZATION_UNITS.NAME%type;
				begin
							
							l_o('<DIV class=divItem><a name="profiles">');
							l_o('<DIV id="s1sql7b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql7'');" href="javascript:;">&#9654; Profile Settings</A></DIV>');
							
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql7" style="display:none" >');
							l_o('   <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
							l_o('     <B>Profile Settings</B></font></TD>');
							l_o('     <TH bordercolor="#DEE6EF">');
							l_o('<A class=detail id="s1sql8b" onclick="displayItem2(this,''s1sql8'');" href="javascript:;">&#9654; Show SQL Script</A>');
							l_o('   </TD>');
							l_o(' </TR>');
							l_o(' <TR id="s1sql8" style="display:none">');
							l_o('    <TD colspan="4" height="60">');
							l_o('       <blockquote><p align="left">');
						
							l_o('         select n.user_profile_option_name, <br>');    	
							l_o('               po.profile_option_name ,<br>');
							l_o('         decode(to_char(pov.level_id),<br>');
							l_o('         ''10001'', ''Site'',<br>');
							l_o('         ''10002'', ''Application'',<br>');
							l_o('         ''10003'', ''Responsibility'',<br>');
							l_o('         ''10005'', ''Server'',<br>');
							l_o('         ''10006'', ''Org'',<br>');
							l_o('         ''10007'', ''Servresp'',<br>');
							l_o('          ''10004'', ''User'', ''???'') ,<br>');
							l_o('         decode(to_char(pov.level_id),<br>');
							l_o('          ''10001'', ''Site'',<br>');
							l_o('         ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),<br>');
							l_o('         ''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),<br>');
							l_o('          ''10005'', svr.node_name,<br>');
							l_o('         ''10006'', org.name,<br>');
							l_o('         ''10007'', pov.level_value ||'', ''|| pov.level_value_application_id ||'', ''|| pov.level_value2,<br>');
							l_o('          ''10004'', nvl(usr.user_name,to_char(pov.level_value)),<br>');
							l_o('          ''???'') ,<br>');
							l_o('          pov.profile_option_value<br>');
							l_o('         from   fnd_profile_options po,<br>');
							l_o('         fnd_profile_option_values pov,<br>');
							l_o('         fnd_profile_options_tl n,<br>');
							l_o('         fnd_user usr,<br>');
							l_o('         fnd_application app,<br>');
							l_o('         fnd_responsibility_vl rsp,<br>');
							l_o('         fnd_nodes svr,<br>');
							l_o('         hr_operating_units org<br>');
							  l_o('         where  (po.profile_option_name like ''HXT%''<br>');
							  l_o('         or po.profile_option_name like ''HXC%''<br>');
							  l_o('         or po.profile_option_name in (''PA_PTE_AUTOAPPROVE_TS'',''PO_SERVICES_ENABLED''<br>');  
							  l_o('         ''PER_BUSINESS_GROUP_ID'',''PER_SECURITY_PROFILE_ID'',''ORG_ID'',''DATETRACK:ENABLED''	,<br>');
							l_o('         ''HR_USER_TYPE'',''HR_ABS_OTL_INTEGRATION'',''HR_SCH_BASED_ABS_CALC'',''PER_ACCRUAL_PLAN_ELEMENT_SET'',<br>');
							l_o('         ''PER_ABSENCE_DURATION_AUTO_OVERWRITE'',''FND_DISABLE_OA_CUSTOMIZATIONS'',''FND_PPR_DISABLED'',''XLA_MO_SECURITY_PROFILE_LEVEL'')<br>');
							l_o('         ) and    pov.application_id = po.application_id<br>');
							l_o('          and    po.profile_option_name = n.profile_option_name<br>');
							l_o('          and    pov.profile_option_id = po.profile_option_id<br>');
							l_o('          and    usr.user_id (+) = pov.level_value<br>');
							l_o('          and    rsp.application_id (+) = pov.level_value_application_id<br>');
							l_o('          and    rsp.responsibility_id (+) = pov.level_value<br>');
							l_o('          and    app.application_id (+) = pov.level_value<br>');
							l_o('          and    svr.node_id (+) = pov.level_value<br>');
							l_o('          and    svr.node_id (+) = pov.level_value2<br>');
							l_o('         and    org.organization_id (+) = pov.level_value<br>');
							l_o('         and    n.language=''US''<br>');
							l_o('         order by 2,3;<br>');
						
							l_o('          </blockquote><br>');
							l_o('     </TD>');
							l_o('   </TR>');
							l_o(' <TR>');
							l_o(' <TH width="25%"><B>Long Name</B></TD>');
							l_o(' <TH width="15%"><B>Short Name</B></TD>');
							l_o(' <TH width="10%"><B>Level</B></TD>');
							l_o(' <TH width="35%"><B>Context</B></TD>');
							l_o(' <TH width="15%"><B>Profile Value</B></TD>');
						
						
							:n := dbms_utility.get_time;
							v_short_name_old:='x';
							v_level_old:='x';
							v_big_no:=1;

							open hr_profiles;
							  loop
								fetch hr_profiles into v_name,v_short_name,v_level,v_context,v_value;
								EXIT WHEN  hr_profiles%NOTFOUND;
										if v_short_name<>v_short_name_old then
												  if v_big_no>1 then  
														l_o('</TABLE></td></TR>');
												  end if;
												  l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>'||v_short_name ||'</TD>'||chr(10));
												 
												  l_o('<TD><A class=detail id="s1sql100'||v_big_no||'b" onclick="displayItem2(this,''s1sql100'||v_big_no||''');" href="javascript:;">&#9654; Show Records</A>');
												  l_o('   </TD>');
												  l_o(' </TR>');
												  l_o(' <TR><TD COLSPAN=5><TABLE width="100%" border="1" cellspacing="0" cellpadding="2"  id="s1sql100'||v_big_no||'" style="display:none">');
												  l_o(' <TR><TD width="25%"><B>Long Name</B></TD>');
												  l_o(' <TD width="15%"><B>Short Name</B></TD>');
												  l_o(' <TD width="10%"><B>Level</B></TD>');
												  l_o(' <TD width="35%"><B>Context</B></TD>');
												  l_o(' <TD width="15%"><B>Profile Value</B></TD></TR>');
												  v_big_no:=v_big_no+1;
												  
										end if;
										if v_short_name=v_short_name_old and v_level=v_level_old then
											l_o('<TR><TD></TD>'||chr(10)||'<TD>');
											l_o('</TD>'||chr(10)||'<TD>' );
											l_o('</TD>'||chr(10)||'<TD>');
										else
											l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>');
											l_o(v_short_name ||'</TD>'||chr(10)||'<TD>' );
											l_o(v_level ||'</TD>'||chr(10)||'<TD>');
										end if;
										v_short_name_old:=v_short_name;
										v_level_old:=v_level;
							  
										if v_context is null then
											l_o('-');
										else
											l_o(v_context );
										end if;
										begin
										case v_short_name
										when 'PER_SECURITY_PROFILE_ID' then
											if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
												select count(1) into v_rows from PER_SECURITY_PROFILES 
													where SECURITY_PROFILE_ID = v_value;
												if v_rows=1 then
														select substr(SECURITY_PROFILE_NAME,1,40) into v_security from PER_SECURITY_PROFILES 
															where SECURITY_PROFILE_ID = v_value;							
														l_o('</TD>'||chr(10)||'<TD>'||v_value||' - '|| v_security);
												else
														l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
												end if;
											else
												l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
											end if;
										when 'ORG_ID' then
												if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
													select count(1) into v_rows from HR_ALL_ORGANIZATION_UNITS
																where ORGANIZATION_ID=v_value;
													if v_rows=1 then									
															select NAME into v_org_name from HR_ALL_ORGANIZATION_UNITS
																where ORGANIZATION_ID=v_value;										
															l_o('</TD>'||chr(10)||'<TD>'||v_value||' - '|| v_org_name);									
													else
															l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
													end if;
												else
													l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
												end if;
										when 'HR_USER_TYPE' then
												case v_value
												when 'INT' then
													l_o('</TD>'||chr(10)||'<TD>INT - HR with Payroll User' );
												when 'PAY' then
													l_o('</TD>'||chr(10)||'<TD>PAY - Payroll User' );
												when 'PER' then
													l_o('</TD>'||chr(10)||'<TD>PER - HR User' );
												else
													l_o('</TD>'||chr(10)||'<TD>'     ||v_value );
												end case;
										when 'PER_BUSINESS_GROUP_ID' then
												if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
													select count(1) into v_rows from HR_ALL_ORGANIZATION_UNITS
																where ORGANIZATION_ID=v_value;
													if v_rows=1 then									
															select NAME into v_org_name from HR_ALL_ORGANIZATION_UNITS
																where ORGANIZATION_ID=v_value;										
															l_o('</TD>'||chr(10)||'<TD>'||v_value||' - '|| v_org_name);									
													else
															l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
													end if;
												else
													l_o('</TD>'||chr(10)||'<TD>'||v_value||' - null');
												end if;
										else
												l_o('</TD>'||chr(10)||'<TD>'     ||v_value );
										end case;
										EXCEPTION
											when others then			  
											  l_o('<br>'||sqlerrm ||' occurred in test');
											  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
										end;
										l_o('</TD></TR>'||chr(10));              
							  end loop;
							  close hr_profiles;
							  l_o(' </TABLE>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display OTL profiles				
procedure otl_profiles is
			v_name fnd_profile_options_tl.user_profile_option_name%type; 
			v_short_name fnd_profile_options.profile_option_name%type;
			v_short_name_old fnd_profile_options.profile_option_name%type;
			v_level varchar2(50);
			v_level_old varchar2(50);
			v_context varchar2(1000);
			v_value fnd_profile_option_values.profile_option_value%type;
			v_id fnd_profile_options.PROFILE_OPTION_ID%type;
			v_big_no number;			
			v_rows number;
			issue0 boolean := FALSE;
			issue1 boolean := FALSE;
			  issue2 boolean := FALSE;
			  issue3 boolean := FALSE;
			  issue4 boolean := FALSE;
			  issue5 boolean := FALSE;
			  issue6 boolean := FALSE;
			  issue7 boolean := FALSE;
			  issue8 boolean := FALSE;
			  issue9 boolean := FALSE;
			  issue10 boolean := FALSE;
			  issue11 boolean := FALSE;
			  issue12 boolean := FALSE;
			  issue13 boolean := FALSE;
			  issue131 boolean := FALSE;
			  issue14 boolean := FALSE;
			  issue142 boolean := FALSE;
			  issue15 boolean := FALSE;
			  issue16 boolean := FALSE;
			  issue17 boolean := FALSE;
			  issue1n boolean := FALSE;
			  issue10n boolean := FALSE;
			  issue12n boolean := FALSE;
			  issue14n boolean := FALSE;
			  issue18 boolean := FALSE;
			  issue19 boolean := FALSE;
			v_sql varchar2(100);			  
			cursor otl_profiles is
			select n.user_profile_option_name,
			  po.profile_option_name ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', 'Application',
					  '10003', 'Responsibility',
					  '10005', 'Server',
					  '10006', 'Org',
					  '10007', 'Servresp',
					  '10004', 'User', '???') ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', nvl(app.application_short_name,to_char(pov.level_value)),
					  '10003', nvl(rsp.responsibility_name,to_char(pov.level_value)),
					  '10005', svr.node_name,
					  '10006', org.name,
					  '10007', pov.level_value ||', '|| pov.level_value_application_id ||', '|| pov.level_value2,
					  '10004', nvl(usr.user_name,to_char(pov.level_value)),
					  '???') ,
			   pov.profile_option_value 
				from   fnd_profile_options po,
					   fnd_profile_option_values pov,
					   fnd_profile_options_tl n,
					   fnd_user usr,
					   fnd_application app,
					   fnd_responsibility_vl rsp,
					   fnd_nodes svr,
					   hr_operating_units org
				where  (po.profile_option_name like 'HXT%' 
						or po.profile_option_name like 'HXC%' 
						or po.profile_option_name in
						('PA_PTE_AUTOAPPROVE_TS', 'PO_SERVICES_ENABLED')
					  ) 
				and    pov.application_id = po.application_id
				and    po.profile_option_name = n.profile_option_name
				and    pov.profile_option_id = po.profile_option_id
				and    usr.user_id (+) = pov.level_value
				and    rsp.application_id (+) = pov.level_value_application_id
				and    rsp.responsibility_id (+) = pov.level_value
				and    app.application_id (+) = pov.level_value
				and    svr.node_id (+) = pov.level_value
				and    svr.node_id (+) = pov.level_value2
				and    org.organization_id (+) = pov.level_value
				and    n.language='US'
				order by n.user_profile_option_name,pov.level_id;
				begin
						v_short_name_old:='x';
						v_level_old:='x';
						v_big_no:=13;

						  open otl_profiles;
						  loop
							fetch otl_profiles into v_name,v_short_name,v_level,v_context,v_value;
							EXIT WHEN  otl_profiles%NOTFOUND;
								   if v_short_name<>v_short_name_old then
											  if v_big_no>13 then  
													l_o('</TABLE></td></TR>');
											  end if;
											  l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>'||v_short_name ||'</TD>'||chr(10));
											  l_o('<TD><A class=detail id="s1sql100'||v_big_no||'b" onclick="displayItem2(this,''s1sql100'||v_big_no||''');" href="javascript:;">&#9654; Show Records</A>');
											  l_o('   </TD>');
											  l_o(' </TR>');
											  l_o(' <TR><TD COLSPAN=5><TABLE width="100%" border="1" cellspacing="0" cellpadding="2"  id="s1sql100'||v_big_no||'" style="display:none">');
											  l_o(' <TR><TD width="25%"><B>Long Name</B></TD>');
											  l_o(' <TD width="15%"><B>Short Name</B></TD>');
											  l_o(' <TD width="10%"><B>Level</B></TD>');
											  l_o(' <TD width="35%"><B>Context</B></TD>');
											  l_o(' <TD width="15%"><B>Profile Value</B></TD></TR>');
											  v_big_no:=v_big_no+1;
											  
									end if;
								   if v_short_name=v_short_name_old and v_level=v_level_old then
										l_o('<TR><TD></TD>'||chr(10)||'<TD>');
										l_o('</TD>'||chr(10)||'<TD>' );
										l_o('</TD>'||chr(10)||'<TD>');
									else
										l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>');
										l_o(v_short_name ||'</TD>'||chr(10)||'<TD>' );
										l_o(v_level ||'</TD>'||chr(10)||'<TD>');
									end if;
									v_short_name_old:=v_short_name;
									v_level_old:=v_level;
						  
									if v_context is null then
										l_o('-');
									else
										l_o(v_context );
									end if;
									l_o('</TD>'||chr(10)||'<TD>'     ||v_value );
									l_o('</TD></TR>'||chr(10));              
						  end loop;
						  close otl_profiles;
						  l_o(' </TABLE>');
						  
					select   count(1)  into v_rows from   fnd_profile_options po,  fnd_profile_option_values pov         
						where  po.profile_option_name ='FND_DISABLE_OA_CUSTOMIZATIONS'   and pov.profile_option_value='N'
						and    pov.application_id = po.application_id  and pov.profile_option_id = po.profile_option_id;
					if v_rows > 0 then
							issue0:=TRUE;
					end if;
					select   count(1)  into v_rows from   fnd_profile_options po,  fnd_profile_option_values pov         
						where  po.profile_option_name ='FND_PPR_DISABLED'   and pov.profile_option_value='Y'
						and    pov.application_id = po.application_id  and pov.profile_option_id = po.profile_option_id;
					if v_rows > 0 then
							issue19:=TRUE;
					end if;
					select   count(1)  into v_rows from   fnd_profile_options po,  fnd_profile_option_values pov         
						where  po.profile_option_name ='HR_ABS_OTL_INTEGRATION'   and pov.profile_option_value='Y'
						and    pov.application_id = po.application_id  and pov.profile_option_id = po.profile_option_id;					
					if v_rows > 0 then									
						select count(1) into v_rows from dba_tables where table_name='HXC_ABSENCE_TYPE_ELEMENTS';							
						if v_rows>0 then
							v_sql:='select count(1) from HXC_ABSENCE_TYPE_ELEMENTS';
							execute immediate v_sql into v_rows;							
							if v_rows=0 then
								issue18:=TRUE;
							end if;
						end if;				
					end if;							
								
					begin	
					open otl_profiles;
					loop
							fetch otl_profiles into v_name,v_short_name,v_level,v_context,v_value;
							EXIT WHEN  otl_profiles%NOTFOUND;
							CASE v_short_name
							  when 'HXT_BATCH_SIZE' then 
								if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
									if v_value<25 then
										issue1:=TRUE;
									end if;
								else
									issue1n:=TRUE;
								end if;
							  when 'HXT_HOL_HOURS_FROM_HOL_CAL' then
								if v_value ='Y' then                
								  issue2:=TRUE;
								elsif v_value='N' then
									issue3:=TRUE;
								end if;  
							  when 'HXT_ROLLUP_BATCH_HOURS' then
								if v_value ='Y' then                
								  issue4:=TRUE;								
								end if; 
							  when 'HXC_TIMEKEEPER_OVERRIDE' then 
								if v_value='N' then
									issue6:=TRUE;
								end if;     
							  when 'HXC_ALLOW_TERM_SS_TIMECARD' then 
								if v_value='N' then
									issue7:=TRUE;
								end if;    
							  when 'HXC_DEFER_WORKFLOW' then
								if v_value ='Y' then                
								  issue8:=TRUE;
								elsif v_value='N' then
									issue9:=TRUE;
								end if; 
							  when 'HXC_RETRIEVAL_MAX_ERRORS' then
								if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
									if v_value<500 then                
									  issue10:=TRUE;
									elsif v_value<1000 then
										issue11:=TRUE;
									end if; 
								else
									issue10n:=TRUE;
								end if;
							  when 'HXC_RETRIEVAL_CHANGES_DATE' then
								if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
									if v_value >100 then                
									  issue12:=TRUE;
									elsif v_value < 15 then                
									  issue13:=TRUE;
									end if; 
								else
									issue12n:=TRUE;
								end if;
							  when 'HXC_RETRIEVAL_BATCH_SIZE' then 
								if LENGTH(TRIM(TRANSLATE(v_value, ' +-.0123456789', ' '))) is null then
									if v_value>100 then
										issue14:=TRUE;
									elsif v_value<10 then
										issue142:=TRUE;					
									end if; 
								else
									issue14n:=TRUE;
								end if;
							  when 'HXC_RETRIEVAL_OPTIONS' then
								if v_value='BEE Only' then                
								  issue15:=TRUE;
								elsif v_value='OTLR Only' then
									issue16:=TRUE;
								end if; 
							  when 'PA_PTE_AUTOAPPROVE_TS' then 
								if v_value='Y' then
									issue17:=TRUE;
								end if;							  
							  else
								null;
							END CASE;	
						 
					  end loop;
					  close otl_profiles;
					EXCEPTION
						when others then			  
						  l_o('<br>'||sqlerrm ||' occurred in test');
						  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
					end;	
						:n := (dbms_utility.get_time - :n)/100;
						l_o('<tr><td><A class=detail onclick="hideRow(''s1sql7'');" href="javascript:;">Collapse section</a></td></tr>');
						l_o(' <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE> </div> ');
								
				if issue0 or issue131 or issue15 or issue16 or issue2 or issue3 or issue4 or issue8 or issue9 then
					l_o('<div class="divok">');
					  if issue0 then							
							l_o('<span class="sectionblue1">Advice:</span> Profile "Disable Self-Service Personal" is set to N at one/several levels, ');
							l_o('so personalization/OA page customization is used. This can cause issues in system behavior (caused by custom personalization).<br> ');
							l_o('If you have issues in web pages, before raising an Service Request, please turn this profile to Y (to disable all personalizations) and retest. ');
							l_o('If the issue is not reproducible, then it is caused by customization.<br>');							
					  end if;					 				  
					   if issue15 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "OTL: Transfer to OTLR and / or BEE" is set to "BEE only" at one/several levels, ');
						l_o('so OTLR Timecards will not be transferred.<br>');
					  end if;      
					  if issue16 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "OTL: Transfer to OTLR and / or BEE" is set to "OTLR only" at one/several levels, ');
						l_o('so Non-OTLR Timecards will not be transferred.<br>');
					  end if; 
					  if issue2 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "HXT: Holiday Hours from Holiday Calendar" is set to Y ');
						l_o('at one/several levels, this will auto-generate the holidays from the Holiday Calendar.<br>');
					  end if;      
					  if issue3 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "HXT: Holiday Hours from Holiday Calendar" is set to N ');
						l_o('at one/several levels, this will auto-generate the holidays from the Workplan.<br>');
					  end if;  
					  if issue4 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "HXT: Rollup Batch Hours" is set to Y at one/several levels, ');
						l_o('so Elements will be rolled up when transferring them to BEE.<br>');
					  end if;      
									  
					  if issue8 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "OTL: Defer approval process on timecard submission" is set to Y ');
						l_o('at one/several levels, so Workflow will not be automatically invoked when timecards are submitted.<br>');
					  end if;      
					  if issue9 then
						l_o('<span class="sectionblue1">Reminder:</span> Profile "OTL: Defer approval process on timecard submission" is set to N ');
						l_o('at one/several levels, so Workflow will be invoked automatically for each timecard submitted.<br>');
					  end if;
					  l_o('</div>');
				  end if;
				  		   
				if issue1 or issue6 or issue7 or issue11 or issue12 or issue13 or issue14 or issue142 or issue1n or issue10n or issue12n or issue14n or issue18 or issue19 then
					l_o('<div class="divwarn">');
					  if issue1 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "HXT: Batch Size" is lower than 25 at one/several levels, ');
						l_o('we recommend the value to be 25.<br>');
						:w2:=:w2+1;
					  end if;
					  if issue1n then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "HXT: Batch Size" is not numeric at one/several levels.<br>');
						:w2:=:w2+1;
					  end if;
					   if issue6 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Allow Change Group Timekeeper" is set to N at ');
						l_o('one/several levels, this will stop you from setting up Timekeeper functionality.<br>');
						:w2:=:w2+1;
					  end if;
					  if issue7 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Allow Self Service Time Entry for Terminated Employees" ');
						l_o('is set to N at one/several levels, ');
						l_o('so Terminated (not finally closed) employees will not be able to enter timecards for their previous periods.<br>');
						:w2:=:w2+1;
					  end if;
					  if issue11 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Max Errors" is less than 1000 at one/several levels. ');
						l_o('Please increase it to 1000.<br>');
						:w2:=:w2+1;
					  end if;
					   if issue12 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Number of past days for which retrieval considers changes (days)" is more than 100 at one/several levels. ');
							l_o('Adding too much of data for the retrieval process and might error.');
							l_o('Please refer <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1621675.1" target="_blank">Doc ID 1621675.1</a> ');
							l_o('Transfer Time From OTL To BEE - ORACLE error 20001 in FDPSTP.<br>');
							:w2:=:w2+1;
						  end if;
					  if issue13 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Profile "OTL: Number of past days for which retrieval considers changes (days)" is less than 15 at one/several levels. ');
						l_o('As minimum it should be double the frequency of running it. ');
						l_o('Please refer <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1621675.1" target="_blank">Doc ID 1621675.1</a> ');
						l_o('Transfer Time From OTL To BEE - ORACLE error 20001 in FDPSTP.<br>');
						:w2:=:w2+1;
					  end if;
					   if issue142 then
						l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Transfer Batch Size" is less than 10 at one/several levels.<br>');
						l_o('There will be many chunks in one retrieval process, until all valid timecards have been transferred. ');
						l_o('Please refer <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1621675.1" target="_blank">Doc ID 1621675.1</a> ');
						l_o('Transfer Time From OTL To BEE - ORACLE error 20001 in FDPSTP.<br>');
						:w2:=:w2+1;
					  end if;
					  if issue14 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Transfer Batch Size" is more than 100 at one/several levels. ');
							l_o('Please refer <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1621675.1" target="_blank">Doc ID 1621675.1</a> ');
							l_o('Transfer Time From OTL To BEE - ORACLE error 20001 in FDPSTP.<br>');
							:w2:=:w2+1;
						  end if;
					  if issue10n then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Max Errors" is not numeric at one/several levels.<br>');
							:w2:=:w2+1;
					  end if;
						if issue12n then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Number of past days for which retrieval considers changes (days)" is not numeric.<br>');
							:w2:=:w2+1;
						end if;	
						if issue14n then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "OTL: Transfer Batch Size" is not numeric at one/several levels.<br>');
							:w2:=:w2+1;
						end if;
						if issue18 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "HR: Absences Integration with OTL" is set to Yes to at least at one level while no OTL Absence Types has been setup. ');
							l_o('If you are using Setup Integration with OTL then you need to setup some Absence Types in OTL, otherwise set the profile "HR: Absences Integration with OTL" to No.<br>');
							:w2:=:w2+1;
						end if;
						if issue19 then
							l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span> Profile "FND: Disable Partial Page Rendering" is set to Y at one/several levels, ');
							l_o(' this will disable the realtime LOV validation when tabbing out of the field.<br>');
							:w2:=:w2+1;
						  end if;
					  l_o('</div>');
				  end if;
				  if issue10  or issue17 then
					l_o('<div class="diverr">');
						  if issue10 then
							l_o('<img class="error_ico" id="sigr1"><font color="red">Error:</font> Profile "OTL: Max Errors" is less than 500 at one/several levels. ');
							l_o('Please increase it to 1000.<br>');
							:e2:=:e2+1;
						  end if;				  
						 					 
						  				 
						  if issue17 then
							l_o('<img id="siga1" class="error_ico"><font color="red">Error:</font> Profile "PA: Autoapprove Timesheets" is set to Y at one/several levels. ');
							l_o('Any Projects Timecard will be autoapproved regardless of Approval Style in OTL. This overrides OTL setup.<br>');
							:e2:=:e2+1;
						  end if;       
						l_o('</div>');
				  end if;			 
						
						
						l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;				

-- Display Bad Time Categories				
procedure bad_times is
			v_time_category_name hxc_time_categories.time_category_name%type;
			v_cursorid number;
			v_sql varchar2(2000);
			v_dummy      integer;
			issue boolean := FALSE;
			v_rows number;			
			begin
					l_o(' <a name="nonotlr"></a>');
					
					select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='IS_NULL_MEANING' and TABLE_NAME='HXC_TIME_CATEGORY_COMPS_V';
					if v_rows>0 then
						v_sql:='select count(1) from hxc_time_categories
						 where time_category_id in
							   (select time_category_id
								  from Hxc_Time_Category_Comps_v
								 where is_null_meaning <> ''Wildcard'')
						      and not (upper(time_category_name) like ''%SYSTEM%GENERATED%'' or
								upper(time_category_name) like ''%OTL%DEC%'' or
								upper(time_category_name) like ''%OTL%INC%'')';
						execute immediate v_sql into v_rows;
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql41b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql41'');" href="javascript:;">&#9654; Bad Time Categories</A></DIV>');
		
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql41" style="display:none" >');
								l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Bad Time Categories</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql42b" onclick="displayItem2(this,''s1sql42'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql42" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select distinct time_category_name from hxc_time_categories where time_category_id in <br>');
								l_o('      	(select time_category_id from Hxc_Time_Category_Comps_v<br>');
								l_o('          where is_null_meaning <> ''Wildcard'')<br>');
								l_o('           and not (upper(time_category_name) like ''%SYSTEM%GENERATED%'' or<br>');
								l_o('          upper(time_category_name) like ''%OTL%DEC%'' or<br>');
								l_o('          upper(time_category_name) like ''%OTL%INC%'')<br>');
								l_o('          order by time_category_name;<br>');
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Categories</B></TD>');
									
								:n := dbms_utility.get_time;
								v_cursorid := DBMS_SQL.OPEN_CURSOR;

								v_sql := 'select distinct time_category_name from hxc_time_categories
										 where time_category_id in
											   (select time_category_id
												  from Hxc_Time_Category_Comps_v
												 where is_null_meaning <> ''Wildcard'')
										   and not (upper(time_category_name) like ''%SYSTEM%GENERATED%'' or
												upper(time_category_name) like ''%OTL%DEC%'' or
												upper(time_category_name) like ''%OTL%INC%'')
										 order by time_category_name';


										 --Parse the query.
										 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
										 v_rows:=0;

										 --Define output columns
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_time_category_name, 100);										 

										 --Execute dynamic sql
										 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

										 LOOP
											  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											  END IF;
								
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_time_category_name);
											  l_o('<TR><TD>'||v_time_category_name||'</TD></TR>'||chr(10));
						
										 END LOOP;
										 

										 DBMS_SQL.CLOSE_CURSOR(v_cursorid);
								
								:n := (dbms_utility.get_time - :n)/100;
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div> ');
								
								l_o('<div class="diverr" id="sigs2">');
								l_o('<img class="error_ico"><font color="red">Error:</font> You have some Time Categories that has components with ''Read Empty Values as'' = Null. ');
								l_o('This will cause this component to be inactive. The value has to be ''Wildcard'' instead. Please refer to ');
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=353610.1" target="_blank">Doc ID 353610.1</a> 	for more information</div>');
								:e2:=:e2+1;
											
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
	                end if;							
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Custom Formulas in Time Entry Rules		
procedure custom_formulas is
			v_name hxc_time_entry_rules.name%type;
			v_rows number;
			cursor c_custom_formulas is
			select name
			 from hxc_time_entry_rules
			 where formula_id not in
				   (select formula_id
					  from ff_formulas_f
					 where formula_name in
					   ('HXC_ELP',
						'HXC_FIELD_COMBO_EXCLUSIVE',
						'HXC_FIELD_COMBO_INCLUSIVE',
						'HXC_CLA_LATE_FORMULA',
						'HXC_CLA_CHANGE_FORMULA',
						'HXC_TIME_CATEGORY_COMPARISON',
						'HXC_PTO_ACCRUAL_COMPARISON',
						'HXC_APPROVAL_MAXIMUM',
						'HXC_PERIOD_MAXIMUM',
						'HXC_APPROVAL_ASG_STATUS',
						'HXC_ASG_STD_HRS_COMPARISON'));
			begin
								select count(1) into v_rows from hxc_time_entry_rules
							where formula_id not in
						   (select formula_id
							  from ff_formulas_f
							 where formula_name in
							   ('HXC_ELP',
								'HXC_FIELD_COMBO_EXCLUSIVE',
								'HXC_FIELD_COMBO_INCLUSIVE',
								'HXC_CLA_LATE_FORMULA',
								'HXC_CLA_CHANGE_FORMULA',
								'HXC_TIME_CATEGORY_COMPARISON',
								'HXC_PTO_ACCRUAL_COMPARISON',
								'HXC_APPROVAL_MAXIMUM',
								'HXC_PERIOD_MAXIMUM',
								'HXC_APPROVAL_ASG_STATUS',
								'HXC_ASG_STD_HRS_COMPARISON'));
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql43b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql43'');" href="javascript:;">&#9654; Custom Formulas in Time Entry Rules</A></DIV>');
		
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql43" style="display:none" >');
								l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Custom Formulas in Time Entry Rules</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql44b" onclick="displayItem2(this,''s1sql44'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql44" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select name	 from hxc_time_entry_rules where formula_id not in <br>');
								l_o('         		   (select formula_id  from ff_formulas_f where formula_name in<br>');
								l_o('                        (''HXC_ELP'',<br>');
								l_o('                         ''HXC_FIELD_COMBO_EXCLUSIVE'',<br>');
								l_o('                         ''HXC_FIELD_COMBO_INCLUSIVE'',<br>');
								l_o('                         ''HXC_CLA_LATE_FORMULA'',<br>');
								l_o('                         ''HXC_CLA_CHANGE_FORMULA'',<br>');
								l_o('                         ''HXC_TIME_CATEGORY_COMPARISON'',<br>');
								l_o('                         ''HXC_PTO_ACCRUAL_COMPARISON'',<br>');
								l_o('                         ''HXC_APPROVAL_MAXIMUM'',<br>');
								l_o('                         ''HXC_PERIOD_MAXIMUM'',<br>');
								l_o('                         ''HXC_APPROVAL_ASG_STATUS'',<br>');
								l_o('                         ''HXC_ASG_STD_HRS_COMPARISON''));<br>');
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Name</B></TD>');
									
								:n := dbms_utility.get_time;
								open c_custom_formulas;
								loop
									fetch c_custom_formulas into v_name;
									EXIT WHEN  c_custom_formulas%NOTFOUND;
									l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
								  
								end loop;
								close c_custom_formulas;

								
								:n := (dbms_utility.get_time - :n)/100;
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div> ');
								
								l_o('<div class="divok">Time Entry Rules with Custom Formula found. </div><br>');
												
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Time Entry Rules with Mapping
procedure time_entry is
			v_name hxc_time_entry_rules.name%type;
			v_rows number;
			cursor c_time_mapping is
			select name from hxc_time_entry_rules where mapping_id is not null
			and not (name = 'Overlapping Time Entries' or
				  name = 'Overlapping Time Entries - Save' or
				  name = 'Payroll Data Approval Rule' or
				  name = 'Projects Data Approval Rule');
			begin
									select count(1) into v_rows from hxc_time_entry_rules where mapping_id is not null
									and not (name = 'Overlapping Time Entries' or
									  name = 'Overlapping Time Entries - Save' or
									  name = 'Payroll Data Approval Rule' or
									  name = 'Projects Data Approval Rule');
							if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql45b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql45'');" href="javascript:;">&#9654; Time Entry Rules with Mapping</A></DIV>');
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql45" style="display:none" >');
									l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>Time Entry Rules with Mapping</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql46b" onclick="displayItem2(this,''s1sql46'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql46" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select name from hxc_time_entry_rules where mapping_id is not null <br>');
									l_o('         and not (name = ''Overlapping Time Entries'' or<br>');
									l_o('           name = ''Overlapping Time Entries - Save'' or<br>');
									l_o('           name = ''Payroll Data Approval Rule'' or<br>');
									l_o('           name = ''Projects Data Approval Rule'')<br>');
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Name</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_time_mapping;
									loop
										fetch c_time_mapping into v_name;
										EXIT WHEN  c_time_mapping%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
									  
									end loop;
									close c_time_mapping;

									
									:n := (dbms_utility.get_time - :n)/100;
									l_o('<TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div> ');
									l_o('<div class="divwarn">');								
									l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>You have Time Entry Rules with a mapping selected, which is a group of timecard fields. ');
									l_o('This tells the approval process to include the timecard for approval ONLY if any of these fields have changed.  </div>');
									:w2:=:w2+1;
													
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Approval Styles with PA Extensions enabled			
procedure approval_styles is
			v_name hxc_approval_styles.name%type;
			v_rows number;
			v_cursorid number;
			v_dummy      integer;
			v_sql varchar2(1000);
			begin
					select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='RUN_RECIPIENT_EXTENSIONS' and TABLE_NAME='HXC_APPROVAL_STYLES';
					if v_rows>0 then
						v_sql:='select count(1) from hxc_approval_styles where run_recipient_extensions = ''Y''';
						execute immediate v_sql into v_rows;
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql47b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql47'');" href="javascript:;">&#9654; Approval Styles with PA Extensions enabled</A></DIV>');
										
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql47" style="display:none" >');
								l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Approval Styles with PA Extensions enabled</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql48b" onclick="displayItem2(this,''s1sql48'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql48" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select Name from hxc_approval_styles where run_recipient_extensions = ''Y''; <br>');
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Name</B></TD>');
									
								:n := dbms_utility.get_time;
								v_cursorid := DBMS_SQL.OPEN_CURSOR;

								v_sql := 'select Name from hxc_approval_styles where run_recipient_extensions = ''Y''';


										 --Parse the query.
										 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
										 v_rows:=0;

										 --Define output columns
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_name, 100);										 

										 --Execute dynamic sql
										 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

										 LOOP
											  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											  END IF;
								
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_name);
											  l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
						
										 END LOOP;
										 

										 DBMS_SQL.CLOSE_CURSOR(v_cursorid);
								
								:n := (dbms_utility.get_time - :n)/100;
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div> ');
								l_o('<div class="divwarn" id="siga6">');
								l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>You have Approval Styles with ''Enable Client Extension'' checked. This will bypass the seeded workflow and look for your PA Extensions code. ');
								l_o('If you don''t use PA Extensions code please uncheck this box. Please refer to ');
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=983722.1" target="_blank">Doc ID 983722.1</a> for more information');
								l_o('</div><br>');	
								:w2:=:w2+1;
												
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
	                end if;			
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Approval Styles with Customizations			
procedure approval_styles_custom is
			v_name hxc_approval_styles.name%type;
			v_mechanism varchar2(30);
			v_identifier hxc_approval_comps_v.identifier%type;
			v_rows number;
			cursor c_approval_style_custom is			
			select syl.name,  decode(cmp.approval_mechanism, 'FORMULA_MECHANISM','Custom Formula','WORKFLOW','Custom Workflow'), cmp.identifier
						  from hxc_approval_styles syl, hxc_approval_comps_v cmp
							where syl.approval_style_id = cmp.approval_style_id
							and cmp.approval_mechanism in ('FORMULA_MECHANISM', 'WORKFLOW')
							and syl.name <> 'Projects Override Approver';						   
   
			begin
							select count(1) into v_rows from hxc_approval_styles
							where approval_style_id in
							(select approval_style_id from hxc_approval_comps where approval_mechanism in ('FORMULA_MECHANISM','WORKFLOW'))
							and name <> 'Projects Override Approver';
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql49b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql49'');" href="javascript:;">&#9654; Approval Styles with Customizations</A></DIV>');
		
								l_o(' <TABLE border="2" cellspacing="0" cellpadding="2" id="s1sql49" style="display:none" >'); 
								l_o('  <TR> <TH COLSPAN=2 bordercolor="#DEE6EF">');
								l_o('     <B>Approval Styles with Customizations</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql50b" onclick="displayItem2(this,''s1sql50'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql50" style="display:none">');
								l_o('    <TD colspan="2" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select syl.name,  decode(cmp.approval_mechanism,<br>');	
								l_o('         ''FORMULA_MECHANISM'',''Custom Formula'',''WORKFLOW'',''Custom Workflow''),<br>');	
								l_o('          cmp.identifier <br>');
								l_o('          from hxc_approval_styles syl, hxc_approval_comps_v cmp<br>');	
								l_o('          where syl.approval_style_id = cmp.approval_style_id<br>');	
								l_o('            and cmp.approval_mechanism in (''FORMULA_MECHANISM'', ''WORKFLOW'')<br>');	
								l_o('            and syl.name <> ''Projects Override Approver'';<br>');	
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Name</B></TD>');
								l_o(' <TH><B>Approval Mechanism</B></TD>');
								l_o(' <TH><B>Custom Object</B></TD>');
									
								:n := dbms_utility.get_time;
								open c_approval_style_custom;
								loop
									fetch c_approval_style_custom into v_name,v_mechanism,v_identifier;
									EXIT WHEN  c_approval_style_custom%NOTFOUND;
									l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>');
									l_o(v_mechanism ||'</TD>'||chr(10)||'<TD>'||v_identifier||'</TD></TR>'||chr(10));									
								  
								end loop;
								close c_approval_style_custom;

								
								:n := (dbms_utility.get_time - :n)/100;
								l_o('<TR> <TH COLSPAN=2 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div> ');
								l_o('<div class="divok" id="siga7">');
								l_o('You have Approval Styles that use customizations (Custom Formula/Custom Workflow).');
								l_o('</div><br>');
																				
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Non-Approved Timecards are allowed for Retrieval			
procedure non_approved_timecards is
			v_name hxc_retrieval_rule_groups_v.retrieval_rule_group_name%type;
			v_rows number;
			cursor c_non_approved_retrieval is
			select retrieval_rule_group_name from hxc_retrieval_rule_groups_v
				where retrieval_rule_group_id in
				(select retrieval_rule_group_id from hxc_retrieval_rule_grp_comps_v
				where retrieval_rule_id in
				(
				select retrieval_rule_id from hxc_retrieval_rules
				where retrieval_rule_id in
				(select retrieval_rule_id from hxc_retrieval_rule_comps where status <> 'APPROVED')
				));
			begin
									select count(1) into v_rows from hxc_retrieval_rule_groups_v
								where retrieval_rule_group_id in
								(select retrieval_rule_group_id from hxc_retrieval_rule_grp_comps_v
								where retrieval_rule_id in
								(
								select retrieval_rule_id from hxc_retrieval_rules
								where retrieval_rule_id in
								(select retrieval_rule_id from hxc_retrieval_rule_comps where status <> 'APPROVED')
								));
							if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql51b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql51'');" href="javascript:;">&#9654; Non-Approved Timecards are allowed for Retrieval</A></DIV>');
		
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql51" style="display:none" >');
									l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>Non-Approved Timecards are allowed for Retrieval</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql52b" onclick="displayItem2(this,''s1sql52'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql52" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select retrieval_rule_group_name from hxc_retrieval_rule_groups_v <br>');		
									l_o('         		where retrieval_rule_group_id in <br>');
									l_o('         		(select retrieval_rule_group_id from hxc_retrieval_rule_grp_comps_v <br>');
									l_o('         		where retrieval_rule_id in <br>');
									l_o('         		( <br>');
									l_o('         		select retrieval_rule_id from hxc_retrieval_rules <br>');
									l_o('         		where retrieval_rule_id in <br>');
									l_o('         		(select retrieval_rule_id from hxc_retrieval_rule_comps where status <> ''APPROVED'') <br>');
									l_o('         		));				<br>');
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Retrieval Rule Group Name</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_non_approved_retrieval;
									loop
										fetch c_non_approved_retrieval into v_name;
										EXIT WHEN  c_non_approved_retrieval%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
									  
									end loop;
									close c_non_approved_retrieval;

									
									:n := (dbms_utility.get_time - :n)/100;
									l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="divwarn">');
									l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>The above Retrieval Rule Groups has one or more Retrieval Rules with components of status NOT APPROVED. ');
									l_o('This means that Timecards linked to the above Retrieval Rule Groups can be transferred to some applications without being Approved!');
									l_o('</div><br>');	
									:w2:=:w2+1;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;


-- Display View Only Absences			
procedure view_only_absences is
			v_name pay_element_types_f.element_name%type;
			v_rows number;
			v_cursorid number;
			v_column	VARCHAR2(80);
			v_dummy	INTEGER;
			v_sql varchar2(1000);
			
			begin
					
				select count(1) into v_rows from dba_tables where table_name='HXC_ABSENCE_TYPE_ELEMENTS';
				if v_rows>0 then
						v_sql:='select count(1) from (select (select element_name from pay_element_types_f where element_type_id = ab.element_type_id) 
										from hxc_absence_type_elements ab where ab.edit_flag = ''N'')';
						execute immediate v_sql into v_rows;									
											
						if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql53b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql53'');" href="javascript:;">&#9654; View Only Absences</A></DIV>');
		
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql53" style="display:none" ><TR>');
									l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>View Only Absences</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql54b" onclick="displayItem2(this,''s1sql54'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql54" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select (select element_name from pay_element_types_f where element_type_id = ab.element_type_id) <br>');		
									l_o('         		from hxc_absence_type_elements ab where ab.edit_flag = ''N''; <br>');
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Element Name</B></TD>');
										
									:n := dbms_utility.get_time;
									v_cursorid := DBMS_SQL.OPEN_CURSOR;

									v_sql := 'select (select element_name from pay_element_types_f where element_type_id = ab.element_type_id) 
												from hxc_absence_type_elements ab where ab.edit_flag = ''N''';

									DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
									v_rows:=0;
					
									DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_column, 80);
									v_dummy := DBMS_SQL.EXECUTE(v_cursorid);
									LOOP
											IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											END IF;
											DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_column);
											l_o('<TR><TD>'||v_column||'</TD></TR>'||chr(10));										  
									END LOOP;										 
									DBMS_SQL.CLOSE_CURSOR(v_cursorid);

									
									:n := (dbms_utility.get_time - :n)/100;
									l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="divwarn">');
									l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>The above Absence Elements are configured in OTL as View Only. ');
									l_o('You will not be able to modify them in the Timecard. Please refer to ');
									l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=1541044.1" target="_blank">Doc ID 1541044.1</a> for more information');
									l_o('</div><br>');
									:w2:=:w2+1;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
				end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Link by Responsibility		
procedure link_responsibility is
			v_name hxc_resource_rules_v.name%type;
			v_elig_criteria hxc_resource_rules_v.eligibility_criteria%type;
			v_meaning hxc_resource_rules_v.meaning%type;
			v_rows number;
			cursor c_view_absences is
			select distinct name Rule_name, eligibility_criteria Responsibility, meaning Link_By_Type
				  from hxc_resource_rules_v
				 WHERE (sysdate between start_date and end_date)
					OR (sysdate >= start_date and end_date is null)
				   and upper(meaning) like '%RESP%';
		    begin
							select count(1) into v_rows FROM hxc_resource_rules_person_v
								 WHERE sysdate between start_date and end_date
								   and sysdate between effective_start_date and
									   effective_end_date
								   and upper(meaning) like '%RESP%';
							if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql55b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql55'');" href="javascript:;">&#9654; Link by Responsibility</A></DIV>');
		
									l_o(' <TABLE border="2" cellspacing="0" cellpadding="2" id="s1sql55" style="display:none" >');
									l_o('   <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
									l_o('     <B>Link by Responsibility</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql56b" onclick="displayItem2(this,''s1sql56'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql56" style="display:none">');
									l_o('    <TD colspan="2" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select distinct name Rule_name, eligibility_criteria Responsibility, meaning Link_By_Type<br>');						
									l_o('         		 from hxc_resource_rules_v <br>');
									l_o('         		   WHERE (sysdate between start_date and end_date) <br>');
									l_o('         			OR (sysdate >= start_date and end_date is null) <br>');
									l_o('         		    and upper(meaning) like ''%RESP%''; <br>');
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Rule Name</B></TD>');
									l_o(' <TH><B>Responsibility Name</B></TD>');
									l_o(' <TH><B>Link By Type</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_view_absences;
									loop
										fetch c_view_absences into v_name, v_elig_criteria,v_meaning;
										EXIT WHEN  c_view_absences%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>'||v_elig_criteria||'</TD>'||chr(10));
										l_o('<TD>'||v_meaning||'</TD></TR>'||chr(10));	
									  
									end loop;
									close c_view_absences;

									
									:n := (dbms_utility.get_time - :n)/100;
									l_o(' <TR><TH COLSPAN=2 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="divok">');
									l_o('<span class="sectionblue1"> Advice: </span>Link by Responsibility is being used for some Eligibility Rules, note that this might cause some preferences not to be active ');
									l_o('if you were not logged using the exact responsibility. Please refer to ');
									l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=953192.1" target="_blank">Doc ID 953192.1</a> for more information');
									l_o('</div><br>');
									
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Non Effective Timecard Periods			
procedure non_effective is
			v_name hxc_recurring_periods.name%type;
			v_rows number;
			cursor c_time_periods is
			select name from hxc_recurring_periods where start_date > sysdate;
			begin
									select count(1) into v_rows from hxc_recurring_periods where start_date > sysdate;
							if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql57b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql57'');" href="javascript:;">&#9654; Non Effective Timecard Periods</A></DIV>');
		
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql57" style="display:none" >'); 
									l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>Non Effective Timecard Periods</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql58b" onclick="displayItem2(this,''s1sql58'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql58" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select name from hxc_recurring_periods where start_date > sysdate <br>');						
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Timecard Periods</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_time_periods;
									loop
										fetch c_time_periods into v_name;
										EXIT WHEN  c_time_periods%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
									  
									end loop;
									close c_time_periods;

									
									:n := (dbms_utility.get_time - :n)/100; 
									l_o('<TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="diverr">');
									l_o('<img class="error_ico"><font color="red">Error:</font> You have Timecard Periods starting after current system date and so it is not effective and cannot be used yet.<br>');
									l_o('</div><br>');
									:e2:=:e2+1;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Elements in Alternate Names with no Element Links			
procedure elements_alternative is
			v_name pay_element_types_f.element_name%type;
			v_alias hxc_alias_definitions.alias_definition_name%type;
			v_rows number;
			cursor c_alternate_names is
			select distinct elm.element_name, def.alias_definition_name
				from hxc_alias_values val, hxc_alias_definitions def, pay_element_types_f elm
				where val.alias_definition_id = def.alias_definition_id
				and val.attribute1 = to_char(elm.element_type_id)
				and val.attribute1 not in (select to_char(lnk.element_type_id) from PAY_ELEMENT_LINKS_f lnk);
			begin
									select count(1) into v_rows from (select distinct elm.element_name, def.alias_definition_name
								from hxc_alias_values val, hxc_alias_definitions def, pay_element_types_f elm
								where val.alias_definition_id = def.alias_definition_id
								and val.attribute1 = to_char(elm.element_type_id)
								and val.attribute1 not in (select to_char(lnk.element_type_id) from PAY_ELEMENT_LINKS_f lnk));
							if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql59b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql59'');" href="javascript:;">&#9654; Elements in Alternate Names with no Element Links</A></DIV>');
		
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql59" style="display:none" >'); 
									l_o('  <TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>Elements in Alternate Names with no Element Links</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql60b" onclick="displayItem2(this,''s1sql60'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql60" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select distinct elm.element_name, def.alias_definition_name <br>');	
									l_o('         		from hxc_alias_values val, hxc_alias_definitions def, pay_element_types_f elm <br>');
									l_o('         		where val.alias_definition_id = def.alias_definition_id <br>');
									l_o('         		and val.attribute1 = to_char(elm.element_type_id) <br>');
									l_o('         		and val.attribute1 not in (select to_char(lnk.element_type_id) from PAY_ELEMENT_LINKS_f lnk); <br>');				
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Elements</B></TD>');
									l_o(' <TH><B>Alternate Names</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_alternate_names;
									loop
										fetch c_alternate_names into v_name, v_alias;
										EXIT WHEN  c_alternate_names%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD>'||chr(10)||'<TD>'||v_alias||'</TD></TR>'||chr(10));
									  
									end loop;
									close c_alternate_names;

									
									:n := (dbms_utility.get_time - :n)/100; 
									l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="diverr">');
									l_o('<img class="error_ico"><font color="red">Error:</font> You have Elements used in some Alternate Names but not linked with any Element Link Criteria. ');
									l_o('Please link the Element(s) from Element Links form in an HRMS Manager Responsibility. ');
									l_o('</div><br>');
									:e2:=:e2+1;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display HXT Projects (OTL Projects)			
procedure hxt_projects is
			v_name HXT_TASKS_FMV.name%type;
			v_rows number;
			cursor c_hxt_projects is
			select name from hxt_tasks_fmv;
			begin
								l_o(' <a name="otlr"></a>');
						
						select count(1) into v_rows from hxt_tasks_fmv;
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql61b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql61'');" href="javascript:;">&#9654; HXT Projects (OTL Projects)</A></DIV>');
		
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql61" style="display:none" >'); 
								l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>HXT Projects (OTL Projects)</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql62b" onclick="displayItem2(this,''s1sql62'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql62" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select name from hxt_tasks_fmv; <br>');						
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Name</B></TD>');
									
								:n := dbms_utility.get_time;
								open c_hxt_projects;
								loop
									fetch c_hxt_projects into v_name;
									EXIT WHEN  c_hxt_projects%NOTFOUND;
									l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
								  
								end loop;
								close c_hxt_projects;

								
								:n := (dbms_utility.get_time - :n)/100; 
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div>');
								l_o('<div class="diverr">');
								l_o('<img class="error_ico"><font color="red">Error:</font> Please note that the Projects defined in OTL''s "Project Accounting" form are not used anymore. ');
								l_o('You should define/use projects from PA Projects Module in EBS. ');
								l_o('</div><br>');	
								:e2:=:e2+1;
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Earning Policies with Use Points enabled			
procedure use_points is
			v_name HXT_EARNING_POLICIES.name%type;
			v_rows number;
			cursor c_use_points is
			select name from HXT_EARNING_POLICIES where use_points_assigned = 'Y';
			begin
								select count(1) into v_rows from HXT_EARNING_POLICIES where use_points_assigned = 'Y';
						if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql63b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql63'');" href="javascript:;">&#9654; Earning Policies with Use Points enabled</A></DIV>');
		
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql63" style="display:none" >'); 
								l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Earning Policies with Use Points enabled</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql64b" onclick="displayItem2(this,''s1sql64'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql64" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select name from HXT_EARNING_POLICIES where use_points_assigned = ''Y''; <br>');						
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Name</B></TD>');
									
								:n := dbms_utility.get_time;
								open c_use_points;
								loop
									fetch c_use_points into v_name;
									EXIT WHEN  c_use_points%NOTFOUND;
									l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
								  
								end loop;
								close c_use_points;

								
								:n := (dbms_utility.get_time - :n)/100; 
								l_o('<TR> <TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div>');
								l_o('<div class="divok">');
								l_o('<span class="sectionblue1"> Advice: </span>The above Earning Policies has "Use Points" enabled. This means that you should have ');
								l_o('assigned points to your elements in Element Time Information form, otherwise, please uncheck it. Please review ');
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=749003.1" target="_blank">Doc ID 749003.1</a> for more information');
								l_o('</div><br>');
								
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
						end if;
			EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
			end;

-- Display Earning Policies with Use Points but Compare Special Rules Evaluation = N			
procedure use_points_compare is
			v_name HXT_EARNING_POLICIES.name%type;
			v_rows number;
			v_level varchar2(20);
			v_context VARCHAR2(100);
			
			cursor c_use_points is
				select name from HXT_EARNING_POLICIES where use_points_assigned = 'Y';
			cursor c_profiles is
				select decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', 'Application',
					  '10003', 'Responsibility', '???') ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', nvl(app.application_short_name,to_char(pov.level_value)),
					  '10003', nvl(rsp.responsibility_name,to_char(pov.level_value)),
					  '???')  
				from   fnd_profile_options po,
					   fnd_profile_option_values pov,
					   fnd_profile_options_tl n,               
					   fnd_application app,
					   fnd_responsibility_vl rsp               
				where  po.profile_option_name ='HXT_CA_LABOR_RULE'
				and    pov.application_id = po.application_id
				and    po.profile_option_name = n.profile_option_name
				and    pov.profile_option_id = po.profile_option_id
				and    rsp.application_id (+) = pov.level_value_application_id
				and    rsp.responsibility_id (+) = pov.level_value
				and    app.application_id (+) = pov.level_value
				and    n.language='US'
				and    pov.profile_option_value='N';
				begin
							select count(1) into v_rows from HXT_EARNING_POLICIES where use_points_assigned = 'Y';
							
							if v_rows>0 then
								select count(1) into v_rows
										from   fnd_profile_options po,
											   fnd_profile_option_values pov,
											   fnd_profile_options_vl n         
										where  po.profile_option_name ='HXT_CA_LABOR_RULE'
										and    pov.application_id = po.application_id
										and    po.profile_option_name = n.profile_option_name
										and    pov.profile_option_id = po.profile_option_id
										and    pov.profile_option_value='N';
								if v_rows>0 then
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql65b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql65'');" href="javascript:;">&#9654; Earning Policies with Use Points but Compare Special Rules Evaluation = N</A></DIV>');
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql65" style="display:none" >'); 
									l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('     <B>Earning Policies with Use Points but Compare Special Rules Evaluation = N</B></font></TD>');
									l_o('     <TH bordercolor="#DEE6EF">');
									l_o('<A class=detail id="s1sql66b" onclick="displayItem2(this,''s1sql66'');" href="javascript:;">&#9654; Show SQL Script</A>');
									l_o('   </TD>');
									l_o(' </TR>');
									l_o(' <TR id="s1sql66" style="display:none">');
									l_o('    <TD colspan="1" height="60">');
									l_o('       <blockquote><p align="left">');
									l_o('         select name from HXT_EARNING_POLICIES where use_points_assigned = ''Y''; <br>');		
									l_o('          <br>');
									l_o('         select decode(to_char(pov.level_id),<br>');
									l_o('                       ''10001'', ''Site'',<br>');
									l_o('                       ''10002'', ''Application'',<br>');
									l_o('                       ''10003'', ''Responsibility'', ''???'') ,<br>');
									l_o('                decode(to_char(pov.level_id),<br>');
									l_o('                       ''10001'', ''Site'',<br>');
									l_o('                       ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),<br>');
									l_o('                       ''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),<br>');
									l_o('                       ''???'') ,<br>');
									l_o('                pov.profile_option_value <br>');
									l_o('                 from   fnd_profile_options po,<br>');
									l_o('                        fnd_profile_option_values pov,<br>');
									l_o('                       fnd_profile_options_tl n,   <br>');            
									l_o('                        fnd_application app,<br>');
									l_o('                        fnd_responsibility_vl rsp        <br>');       
									l_o('                 where  po.profile_option_name =''HXT_CA_LABOR_RULE''<br>');
									l_o('                 and    pov.application_id = po.application_id<br>');
									l_o('                 and    po.profile_option_name = n.profile_option_name<br>');
									l_o('                 and    pov.profile_option_id = po.profile_option_id<br>');
									l_o('                 and    rsp.application_id (+) = pov.level_value_application_id<br>');
									l_o('                 and    rsp.responsibility_id (+) = pov.level_value<br>');
									l_o('                 and    app.application_id (+) = pov.level_value<br>');
									l_o('                 and    n.language=''US''<br>');
									l_o('                 and    pov.profile_option_value=''N'';<br>');		
									l_o('          </blockquote><br>');
									l_o('     </TD>');
									l_o('   </TR>');
									l_o(' <TR>');
									l_o(' <TH><B>Earning Policy</B></TD>');
										
									:n := dbms_utility.get_time;
									open c_use_points;
									loop
										fetch c_use_points into v_name;
										EXIT WHEN  c_use_points%NOTFOUND;
										l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
									  
									end loop;
									close c_use_points;
									
									
									l_o(' <TH><B>Profile level with HXT: Compare Special Rules Evaluation = ''N''</B></TD>');
									l_o(' <TH><B>Profile context</B></TD>');
									l_o(' <TH><B>Value</B></TD>');
									open c_profiles;
									loop
										fetch c_profiles into v_level, v_context;
										EXIT WHEN  c_profiles%NOTFOUND;
										l_o('<TR><TD>'||v_level||'</TD>'||chr(10)||'<TD>'||v_context||'</TD>'||chr(10)||'<TD>N</TD></TR>');
									  
									end loop;
									close c_profiles;
									
									
									
									:n := (dbms_utility.get_time - :n)/100; 
									l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									l_o('<div class="divwarn">');
									l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>You have some Earning Policies with "Use Points" enabled while you have ');
									l_o('"HXT: Compare Special Rules Evaluation" profile set to No at one/several responsibilities or site level.  Please refer to ');
									l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=293006.1" target="_blank">Doc ID 293006.1</a> for more information');
									l_o('</div><br>');	
									:w2:=:w2+1;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
								end if;
							end if;
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display Earning Policies of Type "Special" but Compare Special Rules Evaluation = N				
procedure special_compare is
			v_name HXT_EARNING_POLICIES.name%type;
			v_rows number;
			v_level varchar2(20);
			v_context VARCHAR2(100);
			
			cursor c_use_points is
				select name from HXT_EARNING_POLICIES where fcl_earn_type = 'SPECIAL';
			cursor c_profiles is
				select decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', 'Application',
					  '10003', 'Responsibility', '???') ,
			   decode(to_char(pov.level_id),
					  '10001', 'Site',
					  '10002', nvl(app.application_short_name,to_char(pov.level_value)),
					  '10003', nvl(rsp.responsibility_name,to_char(pov.level_value)),
					  '???')  
				from   fnd_profile_options po,
					   fnd_profile_option_values pov,
					   fnd_profile_options_tl n,               
					   fnd_application app,
					   fnd_responsibility_vl rsp               
				where  po.profile_option_name ='HXT_CA_LABOR_RULE'
				and    pov.application_id = po.application_id
				and    po.profile_option_name = n.profile_option_name
				and    pov.profile_option_id = po.profile_option_id
				and    rsp.application_id (+) = pov.level_value_application_id
				and    rsp.responsibility_id (+) = pov.level_value
				and    app.application_id (+) = pov.level_value
				and    n.language='US'
				and    pov.profile_option_value='N';
				
				begin
						select count(1) into v_rows from HXT_EARNING_POLICIES where fcl_earn_type = 'SPECIAL';
						
						if v_rows>0 then
							select count(1) into v_rows
									from   fnd_profile_options po,
										   fnd_profile_option_values pov,
										   fnd_profile_options_vl n         
									where  po.profile_option_name ='HXT_CA_LABOR_RULE'
									and    pov.application_id = po.application_id
									and    po.profile_option_name = n.profile_option_name
									and    pov.profile_option_id = po.profile_option_id
									and    pov.profile_option_value='N';
							if v_rows>0 then
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql67b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql67'');" href="javascript:;">&#9654; Earning Policies of Type "Special" but Compare Special Rules Evaluation = N</A></DIV>');
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql67" style="display:none" >'); 
								l_o('   <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('     <B>Earning Policies of Type "Special" but Compare Special Rules Evaluation = N</B></font></TD>');
								l_o('     <TH bordercolor="#DEE6EF">');
								l_o('<A class=detail id="s1sql68b" onclick="displayItem2(this,''s1sql68'');" href="javascript:;">&#9654; Show SQL Script</A>');
								l_o('   </TD>');
								l_o(' </TR>');
								l_o(' <TR id="s1sql68" style="display:none">');
								l_o('    <TD colspan="1" height="60">');
								l_o('       <blockquote><p align="left">');
								l_o('         select name from HXT_EARNING_POLICIES where fcl_earn_type = ''SPECIAL''; <br>');		
								l_o('          <br>');
								l_o('         select decode(to_char(pov.level_id),<br>');
								l_o('                       ''10001'', ''Site'',<br>');
								l_o('                       ''10002'', ''Application'',<br>');
								l_o('                       ''10003'', ''Responsibility'', ''???'') ,<br>');
								l_o('                decode(to_char(pov.level_id),<br>');
								l_o('                       ''10001'', ''Site'',<br>');
								l_o('                       ''10002'', nvl(app.application_short_name,to_char(pov.level_value)),<br>');
								l_o('                       ''10003'', nvl(rsp.responsibility_name,to_char(pov.level_value)),<br>');
								l_o('                       ''???'') ,<br>');
								l_o('                pov.profile_option_value <br>');
								l_o('                 from   fnd_profile_options po,<br>');
								l_o('                        fnd_profile_option_values pov,<br>');
								l_o('                       fnd_profile_options_tl n,   <br>');            
								l_o('                        fnd_application app,<br>');
								l_o('                        fnd_responsibility_vl rsp        <br>');       
								l_o('                 where  po.profile_option_name =''HXT_CA_LABOR_RULE''<br>');
								l_o('                 and    pov.application_id = po.application_id<br>');
								l_o('                 and    po.profile_option_name = n.profile_option_name<br>');
								l_o('                 and    pov.profile_option_id = po.profile_option_id<br>');
								l_o('                 and    rsp.application_id (+) = pov.level_value_application_id<br>');
								l_o('                 and    rsp.responsibility_id (+) = pov.level_value<br>');
								l_o('                 and    app.application_id (+) = pov.level_value<br>');
								l_o('                 and    n.language=''US''<br>');
								l_o('                 and    pov.profile_option_value=''N'';<br>');		
								l_o('          </blockquote><br>');
								l_o('     </TD>');
								l_o('   </TR>');
								l_o(' <TR>');
								l_o(' <TH><B>Earning Policy</B></TD>');
									
								:n := dbms_utility.get_time;
								open c_use_points;
								loop
									fetch c_use_points into v_name;
									EXIT WHEN  c_use_points%NOTFOUND;
									l_o('<TR><TD>'||v_name||'</TD></TR>'||chr(10));
								  
								end loop;
								close c_use_points;
								
								
								l_o(' <TH><B>Profile level with HXT: Compare Special Rules Evaluation = ''N''</B></TD>');
								l_o(' <TH><B>Profile context</B></TD>');
								l_o(' <TH><B>Value</B></TD>');
								open c_profiles;
								loop
									fetch c_profiles into v_level, v_context;
									EXIT WHEN  c_profiles%NOTFOUND;
									l_o('<TR><TD>'||v_level||'</TD>'||chr(10)||'<TD>'||v_context||'</TD>'||chr(10)||'<TD>N</TD></TR>');
								  
								end loop;
								close c_profiles;
								
								
								
								:n := (dbms_utility.get_time - :n)/100; 
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div>');
								l_o('<div class="divwarn">');
								l_o('<img class="warn_ico"><span class="sectionorange"> Warning: </span>You have some Earning Policies of type "Special Overtime Earning Rule" while you have ');
								l_o('"HXT: Compare Special Rules Evaluation" profile set to No at one/several responsibilities or site level.  Please refer to ');
								l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=293006.1" target="_blank">Doc ID 293006.1</a> for more information');
								l_o('</div><br>');
								:w2:=:w2+1;
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
							end if;
						end if;
				EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
				end;

-- Display Elements in Earning Policy not linked to Employee				
procedure elements_not_linked is
			v_assignment_id HXT_ADD_ASSIGN_INFO_F.assignment_id%type;
			v_person_name per_all_people_f.full_name%type;
			v_earning_policy HXT_ADD_ASSIGN_INFO_F.earning_policy%type;
			v_element_type_id hxt_earning_rules.element_type_id%type;
			v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
			v_element_name pay_element_types_f.element_name%type;
			v_name_policy hxt_earning_policies.name%type;
			v_is_ok boolean:=FALSE;
			issue boolean:=FALSE;
			v_rows number;
			Elig varchar2(3);
			cursor person is
			select distinct ati.assignment_id, full_name
				   from HXT_ADD_ASSIGN_INFO_F ati,
				   per_all_assignments_f asg,
				   per_all_people_f pep
				   where ati.assignment_id = asg.assignment_id
				   and asg.person_id = pep.person_id
				   and sysdate between ati.effective_start_date and ati.effective_end_date
				   and sysdate between asg.effective_start_date and asg.effective_end_date
				   and sysdate between pep.effective_start_date and pep.effective_end_date
				   and asg.primary_flag = 'Y' and assignment_type IN ('E', 'C')
				   order by full_name;

			cursor element (c_earning_policy number) is
			select distinct element_type_id from hxt_earning_rules where egp_id = c_earning_policy;

			cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
			
			begin
							l_o('<DIV class=divItem>');
							l_o('<DIV id="s1sql69b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql69'');" href="javascript:;">&#9654; Elements in Earning Policy not linked to Employee</A></DIV>');
									
							l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql69" style="display:none" >');
							
							l_o(' <TR> <TH><B>Issues</B></TD>');
								
							:n := dbms_utility.get_time;
							issue:=FALSE;
							
							begin
							open person;
							loop
								fetch person into v_assignment_id, v_person_name;
								EXIT WHEN person%NOTFOUND;											
												
								select earning_policy into v_earning_policy 
									from HXT_ADD_ASSIGN_INFO_F where assignment_id = v_assignment_id 
									and sysdate between effective_start_date and effective_end_date and rownum < 2;
								select name into v_name_policy from hxt_earning_policies where id = v_earning_policy and rownum < 2;
								
								open element(v_earning_policy);
								loop
									fetch element into v_element_type_id;
									EXIT WHEN element%NOTFOUND;
									select count(1) into v_rows from pay_element_types_f 
										where element_type_id=v_element_type_id
										and sysdate between effective_start_date and effective_end_date;
								
									if v_rows=0 then
										l_o('<TR><TD>Person "'||v_person_name||'" is using Element ID "'||v_element_type_id);
										l_o('" that is deleted or end dated. </TD></TR>');
									else
											v_is_ok:=FALSE;
											open element_link (v_element_type_id);
											loop
												fetch element_link into v_element_link_id;
												EXIT WHEN element_link%NOTFOUND;
												hr_utility.trace_off();
												Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																							p_element_link_id => v_element_link_id,
																							p_effective_date => sysdate);
												if Elig='Y' then
													v_is_ok:=TRUE;
													EXIT;
												end if;
											end loop;
											close element_link;						
											if not v_is_ok then
												issue:=TRUE;
														
												select distinct element_name into v_element_name 
													from pay_element_types_f where element_type_id = v_element_type_id 
													and sysdate between effective_start_date and effective_end_date and rownum < 2;
											
												l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Element "'||v_element_name||'" and ');
												l_o('so they cannot use the Earning Policy "'||v_name_policy|| '"</TD></TR>');							
											end if;
									end if;
								end loop;
								close element;
							end loop;
							close person;
							EXCEPTION
									when others then			  
									  l_o('<br>'||sqlerrm ||' occurred in test');
									  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');				
							end;
							
							
							:n := (dbms_utility.get_time - :n)/100; 
							l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
							l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
							l_o(' </TABLE></div>');
							
							if issue then
								l_o('<div class="diverr">');
								l_o('<img class="error_ico"><font color="red">Error:</font> You have some Earning Policies linked to people while some Elements in that Policy not linked to those people. ');
								l_o('For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=284588.1" target="_blank">Doc ID 284588.1</a> ');
								l_o('OTL Earning Policy Not In the List of Values on Assignment Time Information.');
								l_o('</div><br>');
								:e2:=:e2+1;
							end if;
							
							l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
			
			end;

-- Display Elements in Holiday Calendar not linked to Employee			
procedure elements_holiday_not_linked is
			v_assignment_id HXT_ADD_ASSIGN_INFO_F.assignment_id%type;
			v_person_name per_all_people_f.full_name%type;
			v_earning_policy HXT_ADD_ASSIGN_INFO_F.earning_policy%type;
			v_element_type_id hxt_earning_rules.element_type_id%type;
			v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
			v_element_name pay_element_types_f.element_name%type;
			v_name_policy hxt_earning_policies.name%type;
			v_hcl_id hxt_earning_policies.hcl_id%type;
			v_holiday_name hxt_holiday_calendars.name%type;
			v_is_ok boolean:=FALSE;
			issue1 boolean:=FALSE;
			issue2 boolean:=FALSE;
			v_rows number;
			Elig varchar2(3);
			cursor person is
			select distinct ati.assignment_id, full_name
				   from HXT_ADD_ASSIGN_INFO_F ati,
				   per_all_assignments_f asg,
				   per_all_people_f pep
				   where ati.assignment_id = asg.assignment_id
				   and asg.person_id = pep.person_id
				   and sysdate between ati.effective_start_date and ati.effective_end_date
				   and sysdate between asg.effective_start_date and asg.effective_end_date
				   and sysdate between pep.effective_start_date and pep.effective_end_date
				   and asg.primary_flag = 'Y' and assignment_type IN ('E', 'C')
				   order by full_name;

			cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
			begin
								l_o('<DIV class=divItem>');
								l_o('<DIV id="s1sql70b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql70'');" href="javascript:;">&#9654; Elements in Holiday Calendar not linked to Employee</A></DIV>');
		
								l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql70" style="display:none" >');
								
								l_o(' <TR> <TH><B>Issues</B></TD>');
									
								:n := dbms_utility.get_time;
								begin				
								open person;
								loop
									fetch person into v_assignment_id, v_person_name;					
									EXIT WHEN person%NOTFOUND;								
												
									select earning_policy into v_earning_policy 
										from HXT_ADD_ASSIGN_INFO_F where assignment_id = v_assignment_id 
										and sysdate between effective_start_date and effective_end_date and rownum < 2;
									select name into v_name_policy from hxt_earning_policies where id = v_earning_policy and rownum < 2;
									
									select distinct pol.hcl_id into v_hcl_id 
										from hxt_earning_policies pol where pol.id = v_earning_policy and rownum < 2; 
														
									select element_type_id,name into v_element_type_id , v_holiday_name
										from hxt_holiday_calendars where id = v_hcl_id and rownum < 2;
														
									select count(1) into v_rows from pay_element_types_f 
									where element_type_id=v_element_type_id
									and sysdate between effective_start_date and effective_end_date;
									
									if v_rows=0 then
										 l_o('<TR><TD>Person: "'||v_person_name||'" is linked to Holiday Calendar "'||v_holiday_name||'" that ');
										 l_o('is using deleted or end dated Element ID "'|| v_element_type_id||'".</TD></TR>');						 
										 issue1:=TRUE;
									else
											v_is_ok:=FALSE;
											open element_link (v_element_type_id);
												loop
													fetch element_link into v_element_link_id;
													EXIT WHEN element_link%NOTFOUND;
													hr_utility.trace_off();
													Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																								p_element_link_id => v_element_link_id,
																								p_effective_date => sysdate);
													if Elig='Y' then
														v_is_ok:=TRUE;
														EXIT;
													end if;
												end loop;
											close element_link;						
											if not v_is_ok then
													issue2:=TRUE;
													select distinct element_name into v_element_name 
														from pay_element_types_f where element_type_id = v_element_type_id 
														and sysdate between effective_start_date and effective_end_date and rownum < 2;
																						
													l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Element "'||v_element_name||'" of ');
													l_o('Holiday Calendar "'||v_holiday_name|| '" and so you cannot link the Earning Policy"');
													l_o(v_name_policy||'" with this person.</TD></TR>');							
											end if;
									end if;					
								end loop;
								close person;
								EXCEPTION
									when others then			  
									  l_o('<br>'||sqlerrm ||' occurred in test');
									  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');				
								end;
								
								:n := (dbms_utility.get_time - :n)/100; 
								l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
								l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
								l_o(' </TABLE></div>');
								
								if issue1 or issue2 then
									l_o('<div class="diverr">');
								end if;
								if issue1 then
									l_o('<img class="error_ico"><font color="red">Error:</font> For Element Ids deleted or end dated you need to change the Element in the Holiday Calendar ');
									l_o('so you can use it in an Earning Policy.<br> ');
									:e2:=:e2+1;
								end if;
								
								if issue2 then
									l_o('<img class="error_ico"><font color="red">Error:</font> Please link the Element(s) from Element Links form in an HRMS Manager Responsibility. ');
									l_o('For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=284588.1" target="_blank">Doc ID 284588.1</a> ');
									l_o('OTL Earning Policy Not In the List of Values on Assignment Time Information.');
									:e2:=:e2+1;
								end if;
								if issue1 or issue2 then
									l_o('</div><br>');
								end if;
								
								l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
			
			end;

-- Display Elements in Earnings Group not linked to Employee			
procedure elements_earnings_not_linked is
			v_assignment_id HXT_ADD_ASSIGN_INFO_F.assignment_id%type;
			v_person_name per_all_people_f.full_name%type;
			v_earning_policy HXT_ADD_ASSIGN_INFO_F.earning_policy%type;
			v_element_type_id hxt_earning_rules.element_type_id%type;
			v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
			v_element_name pay_element_types_f.element_name%type;
			v_name_policy hxt_earning_policies.name%type;
			v_earning_group hxt_earning_policies.egt_id%type;
			v_group_name hxt_earn_group_types.name%type;
			v_is_ok boolean:=FALSE;
			issue boolean:=FALSE;
			v_rows number;
			Elig varchar2(3);
			cursor person is
			select distinct ati.assignment_id, full_name
				   from HXT_ADD_ASSIGN_INFO_F ati,
				   per_all_assignments_f asg,
				   per_all_people_f pep
				   where ati.assignment_id = asg.assignment_id
				   and asg.person_id = pep.person_id
				   and sysdate between ati.effective_start_date and ati.effective_end_date
				   and sysdate between asg.effective_start_date and asg.effective_end_date
				   and sysdate between pep.effective_start_date and pep.effective_end_date
				   and asg.primary_flag = 'Y' and assignment_type IN ('E', 'C')
				   order by full_name;

			cursor element (c_earning_group number) is
			select distinct element_type_id from HXT_EARN_GROUPS where egt_id = c_earning_group;

			cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
			begin
										l_o('<DIV class=divItem>');
										l_o('<DIV id="s1sql71b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql71'');" href="javascript:;">&#9654; Elements in Earnings Group not linked to Employee</A></DIV>');
		
										l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql71" style="display:none" >');
										
										l_o(' <TR> <TH><B>Issues</B></TD>');
											
										:n := dbms_utility.get_time;
										issue:=FALSE;
										
										begin
										open person;
										loop
											fetch person into v_assignment_id, v_person_name;
											EXIT WHEN person%NOTFOUND;						
															
											select earning_policy into v_earning_policy 
												from HXT_ADD_ASSIGN_INFO_F where assignment_id = v_assignment_id 
												and sysdate between effective_start_date and effective_end_date and rownum < 2;
											select name into v_name_policy from hxt_earning_policies where id = v_earning_policy and rownum < 2;
																
											select distinct egt_id into v_earning_group from hxt_earning_policies where id = v_earning_policy and rownum < 2;
											
											select distinct name into v_group_name from hxt_earn_group_types where id = v_earning_group and rownum < 2;
											
											open element(v_earning_group);
											loop
												fetch element into v_element_type_id;
												EXIT WHEN element%NOTFOUND;
												select count(1) into v_rows from pay_element_types_f 
													where element_type_id=v_element_type_id
													and sysdate between effective_start_date and effective_end_date;
											
												if v_rows=0 then
													l_o('<TR><TD>Person "'||v_person_name||'" is using Element ID "'||v_element_type_id);
													l_o('" that is deleted or end dated. </TD></TR>');
												else
														v_is_ok:=FALSE;
														open element_link (v_element_type_id);
														loop
															fetch element_link into v_element_link_id;
															EXIT WHEN element_link%NOTFOUND;
															hr_utility.trace_off();
															Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																										p_element_link_id => v_element_link_id,
																										p_effective_date => sysdate);
															if Elig='Y' then
																v_is_ok:=TRUE;
																EXIT;
															end if;
														end loop;
														close element_link;						
														if not v_is_ok then
															issue:=TRUE;
																	
															select distinct element_name into v_element_name 
																from pay_element_types_f where element_type_id = v_element_type_id 
																and sysdate between effective_start_date and effective_end_date and rownum < 2;
														
															l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Element "'||v_element_name||'" of ');
															l_o('Earnings Group "'||v_group_name|| '", and so you cannot use the Earning Policy "'||v_name_policy||'" to them.</TD></TR>');							
														end if;
												end if;
											end loop;
											close element;
										end loop;
										close person;
										EXCEPTION
											when others then			  
											  l_o('<br>'||sqlerrm ||' occurred in test');
											  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');				
										end;			
										
										:n := (dbms_utility.get_time - :n)/100; 
										l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
										l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
										l_o(' </TABLE></div>');
										
										if issue then
											l_o('<div class="diverr">');
											l_o('<img class="error_ico"><font color="red">Error:</font> You have some Earning Groups in Earning Policies linked to people while some Elements in that Group not linked to those people. ');
											l_o('For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=284588.1" target="_blank">Doc ID 284588.1</a> ');
											l_o('OTL Earning Policy Not In the List of Values on Assignment Time Information.');
											l_o('</div><br>');
											:e2:=:e2+1;
										end if;
										
										l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
			
			end;

-- Display Elements in Premium Eligibility Policy Base Hours not linked to Employee			
procedure elements_premium_non_linked is
			v_assignment_id HXT_ADD_ASSIGN_INFO_F.assignment_id%type;
			v_person_name per_all_people_f.full_name%type;
			v_earning_policy HXT_ADD_ASSIGN_INFO_F.earning_policy%type;
			v_element_type_id hxt_earning_rules.element_type_id%type;
			v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
			v_element_name pay_element_types_f.element_name%type;
			v_name_policy hxt_earning_policies.name%type;
			v_earning_group hxt_earning_policies.egt_id%type;
			v_premium_id hxt_earning_policies.pep_id%type;
			v_premium_name hxt_prem_eligblty_policies.name%type;
			v_is_ok boolean:=FALSE;
			issue boolean:=FALSE;
			v_rows number;
			Elig varchar2(3);
			cursor person is
			select distinct ati.assignment_id, full_name
				   from HXT_ADD_ASSIGN_INFO_F ati,
				   per_all_assignments_f asg,
				   per_all_people_f pep
				   where ati.assignment_id = asg.assignment_id
				   and asg.person_id = pep.person_id
				   and sysdate between ati.effective_start_date and ati.effective_end_date
				   and sysdate between asg.effective_start_date and asg.effective_end_date
				   and sysdate between pep.effective_start_date and pep.effective_end_date
				   and asg.primary_flag = 'Y' and assignment_type IN ('E', 'C')
				   order by full_name;

			cursor element (c_premium_id number) is
			select distinct elt_base_id from HXT_PREM_ELIGBLTY_POL_RULES where pep_id = c_premium_id;

			cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
			
			begin
									l_o('<DIV class=divItem>');
									l_o('<DIV id="s1sql72b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql72'');" href="javascript:;">&#9654; Elements in Premium Eligibility Policy Base Hours not linked to Employee</A></DIV>');
		
									l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql72" style="display:none" >');
									
									l_o(' <TR> <TH><B>Issues</B></TD>');
										
									:n := dbms_utility.get_time;
									issue:=FALSE;
									
									begin
									open person;
									loop
										fetch person into v_assignment_id,v_person_name;					
										EXIT WHEN person%NOTFOUND;													
														
										select earning_policy into v_earning_policy 
											from HXT_ADD_ASSIGN_INFO_F where assignment_id = v_assignment_id 
											and sysdate between effective_start_date and effective_end_date and rownum < 2;
										select name into v_name_policy from hxt_earning_policies where id = v_earning_policy and rownum < 2;						
										
										select count(pol.pep_id) into v_rows 
											from hxt_earning_policies pol 
											where pol.id = v_earning_policy
											and pol.pep_id is not null;
										if v_rows>0 then
													select distinct pol.pep_id into v_premium_id from hxt_earning_policies pol where pol.id = v_earning_policy and rownum < 2;								
													select distinct name into v_premium_name from hxt_prem_eligblty_policies where id = v_premium_id and rownum < 2;								
																		
													open element(v_premium_id);
													loop
														fetch element into v_element_type_id;
														EXIT WHEN element%NOTFOUND;
														select count(1) into v_rows from pay_element_types_f 
															where element_type_id=v_element_type_id
															and sysdate between effective_start_date and effective_end_date;
													
														if v_rows=0 then
															l_o('<TR><TD>Person "'||v_person_name||'" is using Element ID "'||v_element_type_id);
															l_o('" that is deleted or end dated. </TD></TR>');
														else
																v_is_ok:=FALSE;
																open element_link (v_element_type_id);
																loop
																	fetch element_link into v_element_link_id;
																	EXIT WHEN element_link%NOTFOUND;
																	hr_utility.trace_off();
																	Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																												p_element_link_id => v_element_link_id,
																												p_effective_date => sysdate);
																	if Elig='Y' then
																		v_is_ok:=TRUE;
																		EXIT;
																	end if;
																end loop;
																close element_link;						
																if not v_is_ok then
																	issue:=TRUE;
																			
																	select distinct element_name into v_element_name 
																		from pay_element_types_f where element_type_id = v_element_type_id 
																		and sysdate between effective_start_date and effective_end_date and rownum < 2;
																
																	l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Base Hours Element "'||v_element_name||'" of ');
																	l_o('Premium Eligibility Policy "'||v_premium_name||'" and ');
																	l_o('so you cannot link the Earning Policy "'||v_name_policy||'" to them.</TD></TR>');							
																end if;
														end if;
													end loop;
													close element;
										end if;
									end loop;
									close person;
									EXCEPTION
									when others then			  
									  l_o('<br>'||sqlerrm ||' occurred in test');
									  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');				
									end;

									
									:n := (dbms_utility.get_time - :n)/100; 
									l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
									l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
									l_o(' </TABLE></div>');
									
									if issue then
										l_o('<div class="diverr">');
										l_o('<img class="error_ico"><font color="red">Error:</font> You have some Premium Eligibility Policies in Earning Policies linked to people while ');
										l_o('some Base Hours Elements in that Policy not linked to those people. For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=284588.1" target="_blank">Doc ID 284588.1</a> ');
										l_o('OTL Earning Policy Not In the List of Values on Assignment Time Information.');
										l_o('</div><br>');
										:e2:=:e2+1;
									end if;
									l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
			
			end;

-- Display Elements in Premium Eligibility Policy Premium Hours not linked to Employee			
procedure elements_premium_premium is
			v_assignment_id HXT_ADD_ASSIGN_INFO_F.assignment_id%type;
			v_person_name per_all_people_f.full_name%type;
			v_earning_policy HXT_ADD_ASSIGN_INFO_F.earning_policy%type;
			v_element_type_id hxt_earning_rules.element_type_id%type;
			v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
			v_element_name pay_element_types_f.element_name%type;
			v_name_policy hxt_earning_policies.name%type;
			v_earning_group hxt_earning_policies.egt_id%type;
			v_premium_id hxt_earning_policies.pep_id%type;
			v_premium_name hxt_prem_eligblty_policies.name%type;
			v_is_ok boolean:=FALSE;
			issue boolean:=FALSE;
			v_rows number;
			Elig varchar2(3);
			cursor person is
			select distinct ati.assignment_id, full_name
				   from HXT_ADD_ASSIGN_INFO_F ati,
				   per_all_assignments_f asg,
				   per_all_people_f pep
				   where ati.assignment_id = asg.assignment_id
				   and asg.person_id = pep.person_id
				   and sysdate between ati.effective_start_date and ati.effective_end_date
				   and sysdate between asg.effective_start_date and asg.effective_end_date
				   and sysdate between pep.effective_start_date and pep.effective_end_date
				   and asg.primary_flag = 'Y' and assignment_type IN ('E', 'C')
				   order by full_name;		  	
								
			cursor element (c_premium_id number) is
			select distinct elt_premium_id from HXT_PREM_ELIGBLTY_RULES where pep_id = c_premium_id;	
			
			cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
			
			begin
						l_o('<DIV class=divItem>');
						l_o('<DIV id="s1sql73b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql73'');" href="javascript:;">&#9654; Elements in Premium Eligibility Policy Premium Hours not linked to Employee</A></DIV>');
		
						l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql73" style="display:none" >');
						
						l_o(' <TR> <TH><B>Issues</B></TD>');
							
						:n := dbms_utility.get_time;
						issue:=FALSE;				
						
						begin						
						open person;
						loop
							fetch person into v_assignment_id, v_person_name;					
							EXIT WHEN person%NOTFOUND;							
											
							select earning_policy into v_earning_policy 
								from HXT_ADD_ASSIGN_INFO_F where assignment_id = v_assignment_id 
								and sysdate between effective_start_date and effective_end_date and rownum < 2;
							select name into v_name_policy from hxt_earning_policies where id = v_earning_policy and rownum < 2;						
							
							select count(pol.pep_id) into v_rows 
								from hxt_earning_policies pol 
								where pol.id = v_earning_policy
								and pol.pep_id is not null;
							if v_rows>0 then
										select distinct pol.pep_id into v_premium_id from hxt_earning_policies pol where pol.id = v_earning_policy and rownum < 2;								
										select distinct name into v_premium_name from hxt_prem_eligblty_policies where id = v_premium_id and rownum < 2;								
															
										open element(v_premium_id);
										loop
											fetch element into v_element_type_id;
											EXIT WHEN element%NOTFOUND;
											select count(1) into v_rows from pay_element_types_f 
												where element_type_id=v_element_type_id
												and sysdate between effective_start_date and effective_end_date;
										
											if v_rows=0 then
												l_o('<TR><TD>Person "'||v_person_name||'" is using Element ID "'||v_element_type_id);
												l_o('" that is deleted or end dated. </TD></TR>');
											else
													v_is_ok:=FALSE;
													open element_link (v_element_type_id);
													loop
														fetch element_link into v_element_link_id;
														EXIT WHEN element_link%NOTFOUND;												
														hr_utility.trace_off();
														Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																									p_element_link_id => v_element_link_id,
																									p_effective_date => sysdate);
																								
														if Elig='Y' then
															v_is_ok:=TRUE;
															EXIT;
														end if;
													end loop;
													close element_link;						
													if not v_is_ok then
														issue:=TRUE;
																
														select distinct element_name into v_element_name 
															from pay_element_types_f where element_type_id = v_element_type_id 
															and sysdate between effective_start_date and effective_end_date and rownum < 2;
													
														l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Premium Element "'||v_element_name||'" of ');
														l_o('Premium Eligibility Policy "'||v_premium_name||'" and ');
														l_o('so you cannot link the Earning Policy "'||v_name_policy||'" to them.</TD></TR>');							
													end if;
											end if;
										end loop;
										close element;
							end if;
						end loop;
						close person;
						EXCEPTION
									when others then			  
									  l_o('<br>'||sqlerrm ||' occurred in test');
									  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');				
						end;
						
						:n := (dbms_utility.get_time - :n)/100; 
						l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
						l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
						l_o(' </TABLE></div>');
						
						if issue then
							l_o('<div class="diverr">');
							l_o('<img class="error_ico"><font color="red">Error:</font> You have some Premium Eligibility Policies in Earning Policies linked to people while some Premium Elements in ');
							l_o('that Policy not linked to those people. For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=284588.1" target="_blank">Doc ID 284588.1</a> ');
							l_o('OTL Earning Policy Not In the List of Values on Assignment Time Information.');
							l_o('</div><br>');
							:e2:=:e2+1;
						end if;

						l_o(' <br><A href="#top"><font size="-1">Back to Top</font></A><BR> <br>');
					
			end;
begin
-- Display OTL setup analyzer
:g_curr_loc2:=1;
DBMS_LOB.CREATETEMPORARY(:g_hold_output2,TRUE,DBMS_LOB.SESSION);
l_o('<BR>');
if upper('&&2') = 'Y' then
			l_o('<div id="page2" style="display: none;">');
			l_o('<a name="scan"></a>');
			l_o('<div class="divSection">');			
			l_o('<div class="divSectionTitle">');
			l_o('<div class="left"  id="setup" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">OTL Setup Analyzer: '); 
			l_o('</font></div><div class="right" font style="font-weight: normal; font-size: small;" align="right" color="#FFFFFF">'); 
			l_o('<a class="detail" onclick="openall();" href="javascript:;">');
			l_o('<font color="#FFFFFF">&#9654; Expand All Checks</font></a>'); 
			l_o('<font color="#FFFFFF">&nbsp;/ &nbsp; </font><a class="detail" onclick="closeall();" href="javascript:;">');
			l_o('<font color="#FFFFFF">&#9660; Collapse All Checks</font></a> ');
			l_o('</div><div class="clear"></div></div><br>');
			 l_o('<div class="divItem"><div class="divItemTitle">In This Section</div>');
			  l_o('<table border="0" width="90%" align="center" cellspacing="0" cellpadding="0"><tr><td class="toctable">');
			  l_o('<a href="#prof">Profiles settings</a> <br>');	  
			  l_o('<a href="#nonotlrscan">OTL (Non-OTLR) Setup Scan</a> <br>');
			  l_o('<a href="#otlrscan">OTLR(HXT) Setup Scan</a> <br>');	
			  l_o('</td></tr></table>');
			l_o('</div></div><br>');
	
			l_o('<br><div class="divSection">');
			l_o('<a name="prof"></a><div class="divSectionTitle">Profiles settings</div><br>');
			hr_profiles();
			otl_profiles();
			l_o('</div><br/>');
			
			l_o('<br><div class="divSection">');
			l_o('<a name="nonotlrscan"></a><div class="divSectionTitle">OTL (Non-OTLR) Setup Scan</div><br>');
			bad_times();
			custom_formulas();
			time_entry();
			approval_styles();
			approval_styles_custom();
			non_approved_timecards();
			view_only_absences();
			link_responsibility();
			non_effective();
			elements_alternative() ;
			l_o('</div><br/>');
			
			l_o('<br><div class="divSection">');
			l_o('<a name="otlrscan"></a><div class="divSectionTitle">OTLR(HXT) Setup Scan</div><br>');
			hxt_projects();
			use_points();
			use_points_compare();
			special_compare() ;
			elements_not_linked();
			elements_holiday_not_linked();
			elements_earnings_not_linked();
			elements_premium_non_linked();
			elements_premium_premium();
			l_o('</div><br/>');
			
			
			l_o('</div>');
end if;

	l_o('<!-');

EXCEPTION
			when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
	
end;
/			

-- Print CLOB
print :g_hold_output2

-- Third section due to program too long error

variable g_hold_output3 clob;

declare
   counter      number       := 0;
   failures     number       := 0;


/* Global defaults for SQL output formatting */
   g_sql_date_format   varchar2(100) := 'DD-MON-YYYY HH24:MI';

/* Global variables set by Set_Client which can be used throughout a script */
   g_user_id      number;
   g_resp_id      number;
   g_appl_id      number;
   g_org_id       number;

/* Global variable set by Set_Client or Get_DB_Apps_Version which can
   be referenced in scripts which branch based on applications release */

   g_appl_version varchar2(10);

   type V2T is table of varchar2(32767);

-- Display line in HTML format
procedure l_o (text varchar2) is
   l_ptext      varchar2(32767);
   l_hold_num   number;
   l_ptext2      varchar2(32767);
   l_hold_num2   number;
begin
   l_hold_num := mod(:g_curr_loc, 32767);
   
   l_hold_num2 := mod(:g_curr_loc, 14336);
   if l_hold_num2 + length(text) > 14000 then
      l_ptext2 := '                                                                                                                                                                                      ';
      dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
   end if;
   
   l_hold_num2 := mod(:g_curr_loc, 18204);
   if l_hold_num2 + length(text) > 17900 then
      l_ptext2 := '                                                                                                                                                                                              ';
      dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);	 
	  dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);
	  dbms_lob.write(:g_hold_output3, length(l_ptext2), :g_curr_loc, l_ptext2);
      :g_curr_loc := :g_curr_loc + length(l_ptext2);	
   end if;
   
   if l_hold_num + length(text) > 32759 then
      l_ptext := '<!--' || rpad('*', 32761-l_hold_num,'*') || '-->';
      dbms_lob.write(:g_hold_output3, length(l_ptext), :g_curr_loc, l_ptext);
      :g_curr_loc := :g_curr_loc + length(l_ptext);
   end if;
   dbms_lob.write(:g_hold_output3, length(text)+1, :g_curr_loc, text || chr(10));
   :g_curr_loc := :g_curr_loc + length(text)+1;
   
   --dbms_lob.write(:g_hold_output3, length(text), :g_curr_loc, text );
   --:g_curr_loc := :g_curr_loc + length(text);
   
end l_o;


-- Procedure Name: ActionErrorPrint
-- Displays the text string with the word ACTION - prior to the string

procedure ActionErrorPrint(p_text varchar2) is
begin
   l_o('<span class="errorbold">ACTION - </span><span class="error">'  || p_text || '</span><br>');
end ActionErrorPrint;


-- Procedure Name: ErrorPrint
--      Displays the text string
procedure ErrorPrint(p_text varchar2) is
begin
   l_o('<span class="errorbold">ERROR - </span><span class="error">'  || p_text || '</span><br>');
end ErrorPrint;

-- Procedure Name: NoticePrint
-- Displays the text string in italics preceded by the word 'ATTENTION - '
procedure NoticePrint (p_text varchar2) is
begin
   l_o('<span class="noticebold">ATTENTION - </span>'||
     '<span class="notice">'||p_text||'</span><br>');
end NoticePrint;

-- Procedure Name: SectionPrint
-- Displays the text string in bold print
procedure SectionPrint (p_text varchar2) is
begin
   l_o('<br><span class="sectionbold">' || p_text || '</span><br>');
end SectionPrint;

-- Procedure Name: Tab0Print
-- Displays the text string with no indentation
procedure Tab0Print (p_text varchar2) is
begin
   l_o('<div class="tab0">' || p_text || '</div>');
end Tab0Print;


-- Procedure Name: BRPrint
-- Displays a blank Line
procedure BRPrint is
begin
   l_o('<br>');
end BRPrint;




-- Function Name: Column_Exists
-- Returns: 'Y' if the column exists in the table, 'N' if not.
function Column_Exists(p_tab in varchar, p_col in varchar) return varchar2 is
l_counter integer:=0;
begin
  select count(*) into l_counter
  from   all_tab_columns
  where  table_name = upper(p_tab)
  and    column_name = upper(p_col);
  if l_counter > 0 then
    return('Y');
  else
    return('N');
  end if;
exception when others then
  ErrorPrint(sqlerrm||' occured in Column_Exists');
  ActionErrorPrint('Report this information to your support analyst');
  raise;
end Column_Exists;

-- Procedure Name: Begin_Pre
-- Allows the following output to be preformatted
procedure Begin_Pre is
begin
   l_o('<pre>');
end Begin_Pre;

-- Procedure Name: End_Pre
-- Closes the Begin_Pre procedure
procedure End_Pre is
begin
   l_o('</pre>');
end End_Pre;


procedure Show_Table(p_type varchar2, p_values V2T, p_caption varchar2 default null, p_options V2T default null,
p_valuesN V2T default null/*jsh added*/, p_null varchar2 default 'Y'/*jsh added*/,p_spaces varchar2 default 'Y'/*jsh added*/ ) is
l_hold_option   varchar2(500);
l_continue  varchar2(1) := 'N';
v_describe varchar2(1);

begin
   if upper(p_type) in ('START','TABLE') then
      if p_caption is null then
         l_o('<table cellspacing=0>');
      else
         l_o('<br><table cellspacing=0 summary="' || p_caption || '">');
      end if;
   end if;
   if upper(p_type) in ('TABLE','ROW', 'HEADER') then
      l_o('<tr>');
      for i in 1..p_values.COUNT loop

 ----> jsh added for null columns
      if p_valuesN is not null then
        if p_valuesN(i) is not null then
      	l_continue := 'Y';
      	end if;
      end if;
 ----> jsh added for null columns



if (l_continue = 'Y' and p_values(i) is not null) or p_null = 'Y' or p_valuesN is null then  ----> jsh added for null columns and show spaces

--if p_values(i) is not null or (p_values(i) is null and p_null = 'Y') then  ----> jsh added for null columns and show spaces


      if p_options is not null then
            l_hold_option := ' ' || p_options(i);
         end if;
         if p_values(i) = '&nbsp;'
         or p_values(i) is null then
            if upper(p_type) = 'HEADER' then
               l_o('<th id=' || i || '>&nbsp;</th>');
            else
               l_o('<td headers=' || i || '>&nbsp;</td>');
            end if;
         else
            if upper(p_type) = 'HEADER' then
               l_o('<th' || l_hold_option || ' id=' || i || '>' || p_values(i) || '</th>');
            else
          		if p_spaces = 'Y' then

          			begin

          			if p_values(i) - p_values(i) = 0 then

				v_describe := 'Y';

				end if;

				exception when others then

				v_describe := 'N';

          			end;

          			if v_describe = 'Y' then

          			l_o('<td' || l_hold_option || ' headers=' || i || '>' || p_values(i) || '</td>');

          			else

          			l_o('<td' || l_hold_option || ' headers=' || i || '>' || p_values(i) || '</td>');

          			end if;

          		else

          		l_o('<td' || l_hold_option || ' headers=' || i || '>' || p_values(i) || '</td>');

          		end if;
            end if;
         end if;

end if;  ----->jsh added for null columns and show spaces

	l_continue := 'N';

      end loop;
      l_o('</tr>');
   end if;
   if upper(p_type) in ('TABLE','END') then
      l_o('</TABLE>');
   end if;
end Show_Table;


procedure Show_Table(p_values V2T) is
begin
   Show_Table('TABLE',p_values);
end Show_Table;

procedure Show_Table(p_type varchar2) is
begin
   Show_Table(p_type,null);
end Show_Table;

procedure Show_Table_Row(p_values V2T, p_options V2T default null,
p_valuesN V2T default null/*jsh added*/, p_null varchar2 default 'Y'/*jsh added*/, p_spaces varchar2 default 'N'/*jsh added*/) is
begin
   Show_Table('ROW', p_values, null, p_options, p_valuesN/*jsh added*/, p_null/*jsh added*/, p_spaces/*jsh added*/);
end Show_Table_Row;

procedure Show_Table_Header(p_values V2T, p_options V2T default null,
p_valuesN V2T default null/*jsh added*/, p_null varchar2 default 'Y'/*jsh added*/, p_spaces varchar2 default 'N'/*jsh added*/) is
begin
   Show_Table('HEADER', p_values, null, p_options, p_valuesN/*jsh added*/, p_null/*jsh added*/, p_spaces);
end Show_Table_Header;

procedure Start_Table (p_caption varchar2 default null) is
begin
   Show_Table('START',null, p_caption);
end Start_Table;

procedure End_Table is
begin
   Show_Table('END',null);
end End_Table;

-- Function Name: Display_SQL
--
-- Usage:
--     a_number := Display_SQL('SQL statement','Name for Header','Long Flag',
--                 'Feedback','Max Rows','Indent Level', 'Show sql' );
--
-- Parameters:
--     SQL Statement - Any valid SQL Select Statement
--     Name for Header - Text String to for heading the output
--     Long Flag - Y or N  - If set to N then this will not output
--                 any LONG columns (default = Y)
--     Feedback - Y or N indicates whether to indicate the number of rows
--                selected automatically in the output (default = Y)
--     Max Rows - Limits the number of rows output to this number. NULL or
--                ZERO value indicates unlimited. (Default = NULL)
--     Indent Level - Indicates if the table should be indented and if so
--                    how far: 0 = no indent, 1=.25in, 2=.5in, 3 = .75in
--                    (Default = 0)
--     Show Sql - creates a link called See sql which shows the SQL-statement
--               (Default = N)
--
-- Returns:
--      The function returns the # of rows selected.
--      If there is an error then the function returns -1.
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      declare
--         num_rows number;
--      begin
--         num_rows := Display_SQL('select * from ar_system_parameters_all',
--                                 'AR Parameters', 'Y', 'N',null);
--         num_rows := Display_SQL('select * from pa_implementations_all',
--                                 'PA Implementation Options');
--      end;
--

function Display_SQL (p_sql_statement  varchar2
                    , p_table_alias    varchar2
                    , display_longs    varchar2 default 'Y'
                    , p_feedback       varchar2 default 'Y'
                    , p_max_rows       number   default null
                    , p_ind_level      number   default 0
                    , p_show_sql       varchar2 default 'N'
                    , p_current_exec   number   default 0
                    , p_null          varchar2 default 'Y'                      --jsh added
                    , p_spaces         varchar2 default 'Y') return number is    --jsh added

  c                 number;
  l_error_pos       number;
  l_error_len       number;
  l_row_count       number;
  l_exclude_cols    boolean;
  l_header_val      varchar2(1000);

  l_col_val         varchar2(32767);
  l_col_val_clob    clob;
  l_col_val_blob    blob;

  l_col_opts        varchar2(32767)  default null;
  l_col_max_len     integer;
  l_col_num         binary_integer  default 1;

  l_num_cols        binary_integer  default 1;
  l_dummy           integer;
  l_old_date_format varchar2(40);
  l_max_rows        integer;
  l_feedback_txt    varchar2(200);
  l_format          varchar2(1);
  l_hold_long      long;

  l_values     V2T;
  l_options    V2T;
  l_sql_descr   dbms_sql.desc_tab;

  T_VARCHAR2   constant integer := 1;
  T_NUMBER     constant integer := 2;
  T_LONG       constant integer := 8;
  T_ROWID      constant integer := 11;
  T_DATE       constant integer := 12;
  T_CHAR       constant integer := 96;
  T_CLOB       constant integer := 112;
  T_BLOB       constant integer := 113;

  v_valuesN    V2T := V2T('');
  v_valuesN2   V2T := V2T('');
  row_counter2 number;
  v_dummy      integer;

begin
     if nvl(p_max_rows,0) = 0 then
          l_max_rows := null;
     else
          l_max_rows := p_max_rows;
     end if;

     select value
     into l_old_date_format
     from nls_session_parameters
     where parameter = 'NLS_DATE_FORMAT';
     execute immediate 'alter session set nls_date_format = ''' || g_sql_date_format || '''';

     c := dbms_sql.open_cursor;
     dbms_sql.parse(c, p_sql_statement, dbms_sql.native);
     dbms_sql.describe_columns(c, l_num_cols, l_sql_descr);

     for l_col_num in 1..l_num_cols loop
          l_col_max_len := to_number(l_sql_descr(l_col_num).col_max_len);

          if l_sql_descr(l_col_num).col_type in (T_DATE, T_VARCHAR2, T_NUMBER, T_CHAR, T_ROWID) then
               dbms_sql.define_column(c, l_col_num,l_col_val,greatest(l_col_max_len,30));
          elsif l_sql_descr(l_col_num).col_type = T_LONG then
               dbms_sql.define_column(c, l_col_num,l_col_val,32767);
          elsif l_sql_descr(l_col_num).col_type = T_CLOB then
               dbms_sql.define_column(c, l_col_num,l_col_val_clob);
          elsif l_sql_descr(l_col_num).col_type = T_BLOB then
               dbms_sql.define_column(c, l_col_num,l_col_val_blob);
          else
               dbms_sql.define_column(c, l_col_num,l_col_val,32767);
          end if;

          l_header_val := initcap(l_sql_descr(l_col_num).col_name);
		  
		  ------------------
-- IFREEBER
-- make column_name show on one line
------------------
--		if length(l_header_val) > 10 then
--			l_header_val := replace(l_header_val,'_','_|');
--		end if;
------------------
-- set column_name format to initcap
                l_header_val := initcap(l_header_val);
------------------

          if l_col_num = 1 then
               l_values := V2T(replace(l_header_val,'|','<br>'));
          else
               l_values.EXTEND;
               l_values(l_col_num) := replace(l_header_val,'|','<br>');
          end if;

     end loop;

     v_dummy := DBMS_SQL.EXECUTE(c);
     row_counter2 := 1;
     loop
          if DBMS_SQL.FETCH_ROWS(c) = 0 then
               exit;
          end if;

          for l_col_num in 1..l_num_cols loop

               if l_sql_descr(l_col_num).col_type in (T_DATE, T_VARCHAR2, T_NUMBER, T_CHAR, T_ROWID) then
                    DBMS_SQL.COLUMN_VALUE(c, l_col_num, l_col_val);
               elsif l_sql_descr(l_col_num).col_type = T_LONG then
                    DBMS_SQL.COLUMN_VALUE(c, l_col_num, l_col_val);
               elsif l_sql_descr(l_col_num).col_type = T_CLOB then
                    DBMS_SQL.COLUMN_VALUE(c, l_col_num, l_col_val_clob);
               elsif l_sql_descr(l_col_num).col_type = T_BLOB then
                    DBMS_SQL.COLUMN_VALUE(c, l_col_num, l_col_val_blob);
               else
                    l_o('Unsupported datatype - '|| l_sql_descr(l_col_num).col_type);
               end if;

               l_col_opts := null;
               l_col_val := replace(l_col_val,' ','&nbsp;');

               if l_sql_descr(l_col_num).col_type in (T_DATE, T_NUMBER) then
                    l_col_opts := 'nowrap align=right';
               elsif l_sql_descr(l_col_num).col_type in (T_VARCHAR2, T_CHAR) then
                    l_col_val := replace(replace(l_col_val,'<','&lt;'),'>','&gt;');
                    if l_col_val != rtrim(l_col_val) then
                         l_col_opts := 'nowrap bgcolor=yellow';
                    else
                         l_col_opts := 'nowrap';
                    end if;
               else
                    null;
               end if;

               if l_col_num = 1 then
                    if l_col_val is null then
                         v_valuesN := V2T(null);
                    else
                         v_valuesN := V2T('n');
                    end if;
               else
                    v_valuesN.EXTEND;
                    if l_col_val is null then
                         v_valuesN(l_col_num) := null;
                    else
                         v_valuesN(l_col_num) := 'n';
                    end if;
               end if;

               v_valuesN2.EXTEND;
               v_valuesN2(l_col_num) := v_valuesN2(l_col_num)||v_valuesN(l_col_num);

          end loop;
          row_counter2 := row_counter2 + 1;
     end loop;

     if nvl(p_ind_level,0) != 0 then
          l_o('<div class=ind'||to_char(p_ind_level)||'>');
     end if;
     if p_table_alias is not null then
          l_o('<br><span class="BigPrint">'||p_table_alias||'</span>');
     end if;
     l_dummy := dbms_sql.EXECUTE(c);
     l_row_count := 1;
     loop
          if dbms_sql.FETCH_ROWS(c) = 0 then
               exit;
          end if;
          if l_row_count = 1 then
               Start_Table(p_table_alias);
               Show_Table_Header(l_values,null, v_valuesN2, p_null, p_spaces);   ------> jsh added for null columns
          end if;
          for l_col_num in 1..l_num_cols loop
               if l_sql_descr(l_col_num).col_type in (T_DATE, T_VARCHAR2, T_NUMBER, T_CHAR, T_ROWID) then
                    dbms_sql.column_value(c,l_col_num,l_col_val);
               elsif l_sql_descr(l_col_num).col_type =  T_LONG then
                    dbms_sql.column_value(c,l_col_num,l_col_val);
               elsif l_sql_descr(l_col_num).col_type =  T_CLOB then
                    dbms_sql.column_value(c,l_col_num,l_col_val_clob);
               elsif l_sql_descr(l_col_num).col_type =  T_BLOB then
                    dbms_sql.column_value(c,l_col_num,l_col_val_blob);
               else
                    l_col_val := 'Unsupported Datatype';
               end if;

               l_col_opts := null;
               l_col_val := nvl(l_col_val,'&nbsp;');

               if l_sql_descr(l_col_num).col_type in (T_DATE, T_NUMBER) then
                    l_col_opts := 'nowrap align=right';
               elsif l_sql_descr(l_col_num).col_type in (T_VARCHAR2, T_CHAR) then
                    l_col_val := replace(replace(l_col_val,'<','&lt;'),'>','&gt;');
                    l_col_val := replace(replace(l_col_val, chr(10),'<BR>'),chr(0),'^@');
--                    l_col_val := replace(l_col_val,'  ',' &nbsp;');
                    if l_col_val != rtrim(l_col_val) then
                         l_col_opts := 'nowrap bgcolor=yellow';
                    else
                         l_col_opts := 'nowrap';
                    end if;
               end if;

               if l_col_num = 1 then
                    l_values := V2T(l_col_val);
                    l_options := V2T(l_col_opts);
               else
                    l_values.EXTEND;
                    l_values(l_col_num) := l_col_val;
                    l_options.EXTEND;
                    l_options(l_col_num) := l_col_opts;
               end if;

          end loop;

          Show_Table_Row(l_values, l_options, v_valuesN2, p_null, p_spaces);   ------> jsh added for null columns

          l_row_count := l_row_count + 1;
          if l_row_count >  nvl(l_max_rows,l_row_count) then
               exit;
          end if;

     end loop;
     dbms_sql.close_cursor(c);
     End_Table;
     if p_feedback = 'Y' then
          if l_row_count = 1 then
               l_feedback_txt := '<BR><span class="SmallPrint">'||'0 Rows Selected</span><br>';
          elsif l_row_count = 2 then
               l_feedback_txt := '<span class="SmallPrint">'||'1 Row Selected</span><br>';
          else
               l_feedback_txt := '<span class="SmallPrint">'||ltrim(to_char(l_row_count - 1,'9999999')) ||' Rows Selected</span><br>';
          end if;
          l_o(l_feedback_txt);
     end if;
     if p_show_sql = 'Y' then
          l_o('<A HREF="javascript:document.write('||chr(39)||'<A HREF=javascript:window.history.go(-1);\>Back</A\><BR\>'||replace(replace(replace(replace(p_sql_statement,chr(34),chr(38)||'#34'),chr(39),chr(92)||chr(39)),chr(40),chr(38)||'#40'),chr(41),chr(38)||'#41')||'<BR\>'||chr(39)||');">See SQL</A><BR>');
     end if;
     if nvl(p_ind_level,0) != 0 then
          l_o('</div>');
     end if;
     execute immediate 'alter session set nls_date_format = ''' ||
     l_old_date_format || '''';
     return l_row_count-1;
exception when others then
     l_o('</table><br>');
     l_error_pos := dbms_sql.last_error_position;
     ErrorPrint(sqlerrm || ' occurred in Display_SQL');
     ActionErrorPrint('Please report the error below to Oracle Support Services');
     l_o('Position: ' || l_error_pos  || ' of ' ||
     length(p_sql_statement) || '<br>');
     l_o(replace(substr(p_sql_statement,1,l_error_pos),chr(10),'<br>'));
     l_error_len := instr(p_sql_statement,' ',l_error_pos+1) - l_error_pos;
     l_o('<span class="error">' ||
     replace(substr(p_sql_statement,l_error_pos+1,
     l_error_len),chr(10),'<br>') || '</span>');
     l_o(replace(substr(p_sql_statement,l_error_pos+
     l_error_len+1),chr(10),'<br>') || '<br>');
     dbms_sql.close_cursor(c);
     execute immediate 'alter session set nls_date_format = ''' ||
     l_old_date_format || '''';
     return -1;
end Display_SQL;


-- Function Name: Run_SQL
--
-- Usage:
--      a_number := Run_SQL('Heading', 'SQL statement');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Max Rows');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows', 'Indent Level');
--      a_number := Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows', 'Indent Level', 'Show Sql');
--
-- Parameters:
--      Heading - Text String to for heading the output
--      SQL Statement - Any valid SQL Select Statement
--      Feedback - Y or N to indicate whether to automatically print the
--                 number of rows returned (default 'Y')
--      Max Rows - Limit the output to this many rows.  NULL or ZERO values
--                 indicate unlimited rows (default NULL)
--      Indent Level - Indicate if table should be indented and by how much
--                     0=No indentation, 1=.25in, 2=.5in, 3=.75in (default 0)
--      Show Sql - create a link called See sql which shows the SQL-statement (Default = N)
--
-- Returns:
--      The function returns the # of rows selected.
--      If there is an error then the function returns -1.
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      declare
--         num_rows number;
--      begin
--         num_rows := Run_SQL('AR Parameters',
--                             'select * from ar_system_parameters_all');
--      end;
--
-- Comments:
--      The date format default is DD-MON-YYYY HH24:MI.  If a different
--      date format is required, set the value of the global variable
--      g_sql_date_format to the appropriate format string prior to calling
--      Run_SQL
--
function Run_SQL(p_title varchar2, p_sql_statement varchar2) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y','Y',null));
end Run_SQL;

function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y',p_feedback,null,0));
end Run_SQL;

function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_max_rows number) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y','Y',p_max_rows,0));
end Run_SQL;

function Run_SQL(p_title varchar2
               , p_sql_statement varchar2
               , p_feedback varchar2
               , p_max_rows number) return number is
begin
   return(Display_SQL(p_sql_statement , p_title ,'Y',p_feedback,p_max_rows,0));
end Run_SQL;

function Run_SQL(p_title         varchar2
               , p_sql_statement varchar2
               , p_feedback      varchar2
               , p_max_rows      number
               , p_ind_level     number) return number is
begin
   return(Display_SQL(p_sql_statement , p_title , 'Y', p_feedback, p_max_rows, p_ind_level));
end Run_SQL;

function Run_SQL(p_title         varchar2
               , p_sql_statement varchar2
               , p_feedback      varchar2
               , p_max_rows      number
               , p_ind_level     number
               , p_show_sql      varchar2 ) return number is
begin
   return(Display_SQL(p_sql_statement , p_title , 'Y', p_feedback, p_max_rows, p_ind_level, p_show_sql ));
end Run_SQL;

-- Procedure Name: Run_SQL
--
-- Usage:
--      Run_SQL('Heading', 'SQL statement');
--      Run_SQL('Heading', 'SQL statement', 'Feedback');
--      Run_SQL('Heading', 'SQL statement', 'Max Rows');
--      Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows');
--      Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows', 'Indent Level');
--      Run_SQL('Heading', 'SQL statement', 'Feedback', 'Max Rows', 'Indent Level', 'Show SQL');
--
-- Parameters:
--     Heading - Text String to for heading the output
--     SQL Statement - Any valid SQL Select Statement
--     Feedback - Y or N to indicate whether to automatically print the
--                number of rows returned (default 'Y')
--     Max Rows - Limit the output to this many rows.  NULL or ZERO values
--                indicate unlimited rows (default NULL)
--     Indent Level - Indicate if table should be indented and by how much
--                    0=No indentation, 1=.25in, 2=.5in, 3=.75in (default 0)
--     Show Sql - create a link called See sql which shows the SQL-statement (Default = N)
--
-- Output:
--      Displays the output of the SQL statement as an HTML table.
--
-- Examples:
--      begin
--         Run_SQL('AR Parameters', 'select * from ar_system_parameters_all');
--      end;
--
procedure Run_SQL(p_title varchar2, p_sql_statement varchar2) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y','Y',null,0);
end Run_SQL;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', p_feedback, null,0);
end Run_SQL;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_max_rows number) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', 'Y', p_max_rows,0);
end Run_SQL;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2
                , p_max_rows number) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', p_feedback, p_max_rows,0);
end Run_SQL;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2
                , p_max_rows number
                , p_ind_level number) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', p_feedback, p_max_rows, p_ind_level);
end Run_SQL;

procedure Run_SQL(p_title varchar2
                , p_sql_statement varchar2
                , p_feedback varchar2
                , p_max_rows number
                , p_ind_level number
                , p_show_sql varchar2 ) is
   dummy   number;
begin
   dummy := Display_SQL (p_sql_statement , p_title , 'Y', p_feedback, p_max_rows, p_ind_level, p_show_sql );
end Run_SQL;

-- Procedure Name: Display_Table
--
-- Usage:
--      Display_Table('Table Name', 'Heading', 'Where Clause', 'Order By', 'Long Flag');
--
-- Parameters:
--      Table Name - Any Valid Table or View
--      Heading - Text String to for heading the output
--      Where Clause - Where clause to apply to the table dump
--      Order By - Order By clause to apply to the table dump
--      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not output any LONG columns
--
-- Output:
--      Displays the output of the 'select * from table' as an HTML table.
--
-- Examples:
--      begin
--         Display_Table('AR_SYSTEM_PARAMETERS_ALL', 'AR Parameters', 'Where Org_id != -3113'
--                         , 'order by org_id, set_of_books_id', 'N');
--      end;
--
procedure Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') is
   dummy      number;
   hold_char   varchar(1) := null;
begin
   if p_where_clause is not null then
      hold_char := chr(10);
   end if;
   dummy := Display_SQL ('select * from ' ||
      replace(upper(p_table_name),'V_$','V$') || chr(10) || p_where_clause ||
      hold_char || nvl(p_order_by_clause,'order by 1')
      , nvl(p_table_alias, p_table_name)
      , p_display_longs);
end Display_Table;

-- Function Name: Display_Table
--
-- Usage:
--      a_number := Display_Table('Table Name', 'Heading', 'Where Clause', 'Order By', 'Long Flag');
--
-- Parameters:
--      Table Name - Any Valid Table or View
--      Heading - Text String to for heading the output
--      Where Clause - Where clause to apply to the table dump
--      Order By - Order By clause to apply to the table dump
--      Long Flag - 'Y' or 'N'  - If set to 'N' then this will not output any LONG columns
--
-- Output:
--      Displays the output of the 'select * from table' as an HTML table.
--
-- Returns:
--      Number of rows displayed.
--
-- Examples:
--      declare
--         num_rows   number;
--      begin
--         num_rows := Display_Table('AR_SYSTEM_PARAMETERS_ALL', 'AR Parameters', 'Where Org_id != -3113'
--                                     , 'order by org_id, set_of_books_id', 'N');
--      end;
--
function Display_Table (p_table_name   varchar2,
          p_table_alias   varchar2,
          p_where_clause   varchar2,
          p_order_by_clause varchar2 default null,
          p_display_longs   varchar2 default 'Y') return number is
begin
   return(Display_SQL ('select * from ' ||
      replace(upper(p_table_name),'V_$','V$') || chr(10) || p_where_clause ||
      chr(10) || nvl(p_order_by_clause,'order by 1')
      , nvl(p_table_alias, p_table_name)
      , p_display_longs));
end Display_Table;


procedure Show_Link(p_note varchar2) is
begin
   l_o('Note: <a href=https://support.oracle.com/oip/faces/secure/km/DocumentDisplay.jspx?id='  || p_note || ' target=_blank>' || p_note || '</a>');
end Show_Link;

procedure Show_Link(p_link varchar2, p_link_name varchar2 ) is
begin
   l_o('<a href='  || p_link || '>' || p_link_name || '</a>');
end Show_Link;



--------------------- Pl/SQL api end ------------------------------------------


begin  -- begin1

declare

	sqlTxt varchar2(32767);
	
	l_param1 varchar2(100) := '&&3';  --rtrim(ltrim('&&3'));
	l_param2 varchar2(100) := '&&4';  --rtrim(ltrim('&&4'));
	l_param3 varchar2(100) := '&&5';  --rtrim(ltrim('&&5'));
	l_param4 varchar2(100) := '&&8';  --rtrim(ltrim('&&7'));
	l_param5 varchar2(100) := '&&10';  --rtrim(ltrim('&&9'));
	
	l_var1 varchar2(32767);
	l_var2 varchar2(32767);
	l_var3 varchar2(32767);
	l_var4 varchar2(32767);
	l_var5 varchar2(32767);
	l_query1 varchar2(32767);
	l_query2 varchar2(32767);
	l_query3 varchar2(32767);
	l_query4 varchar2(32767);
	l_query5 varchar2(32767);
	l_num1 number;
	l_num2 number;
	l_num3 number;
	l_num4 number;
	l_num5 number;
	l_date1 date;
	l_date2 date;
	l_date3 date;
	l_date4 date;
	l_date5 date;

	l_timecard_id number;	
	l_ovn number;
	l_resource_id number;
	l_start_date varchar2(11);
	l_stop_date varchar2(11);
	l_timid number;
	v_person_name PER_ALL_PEOPLE_F.full_name%type;
	v_Approver_Id HXC_APP_PERIOD_SUMMARY.Approver_Id%type;
	v_system_person_type per_person_types.system_person_type%type;
	v_segment1 PA_PROJECTS_all.segment1%type;
	v_approval_style hxc_approval_styles.name%type :='';
	v_rows number;
	v_time_recipient_name hxc_application_set_comps_v.TIME_RECIPIENT_NAME%type;
	cursor c_TIME_RECIPIENT_NAME is 
		SELECT TIME_RECIPIENT_NAME FROM hxc_application_set_comps_v WHERE APPLICATION_SET_ID in 
		(select application_set_id from HXC_TIME_BUILDING_BLOCKS 
		where scope = 'TIMECARD' 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
		and date_to=to_date('31-DEC-4712')) 
		order by time_recipient_name;
	cursor c_TIME_RECIPIENT_NAME2 is 
		SELECT TIME_RECIPIENT_NAME FROM hxc_application_set_comps_v WHERE APPLICATION_SET_ID in 
		(select application_set_id from HXC_TIME_BUILDING_BLOCKS 
		where scope = 'TIMECARD' 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')) 
		order by time_recipient_name;
		
	v_layout_name hxc_layouts_vl.display_layout_name%type;
	v_attribute HXC_TIME_ATTRIBUTES.Attribute1%type;
	v_org_name hr_all_organization_units.name%type;
	v_user_name fnd_user.user_name%type;
	v_approval_status HXC_TIMECARD_SUMMARY.approval_status%type;
	v_Approval_Style_Id HXC_TIME_BUILDING_BLOCKS.Approval_Style_Id%type;
	v_recorded_hours HXC_TIMECARD_SUMMARY.recorded_hours%type;
	v_transferred_to VARCHAR2(240);
	v_approval_item_type HXC_TIMECARD_SUMMARY.approval_item_type%type;
	v_approval_item_key HXC_TIMECARD_SUMMARY.approval_item_key%type;
	cursor c_HXC_TIMECARD_SUMMARY is
					select Approval_status, Recorded_Hours,  Approval_Item_Type, Approval_Item_Key ,rowid
					from HXC_TIMECARD_SUMMARY 
					where timecard_id in 
					(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD'
					and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'));
	v_sql varchar2(10000);
	v_sql2 varchar2(10000);
	v_rowid varchar2(1000);
	v_cursorid number;
	v_column	VARCHAR2(30);
	v_dummy	INTEGER;

					
	cursor c_hxc_locks is
		select lock_date, locker_type_id from hxc_locks where resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
		union
		select lock_date, locker_type_id from hxc_locks where time_building_block_id in 
		(select time_building_block_id from hxc_time_building_blocks 
		where scope in ('TIMECARD','DAY','DETAIL','APPLICATION_PERIOD') 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'));
	v_locker varchar2(200);
	v_lock_date hxc_locks.lock_date%type;
	v_locker_type_id hxc_locks.locker_type_id%type;
	v_first boolean;
	cursor c_HXC_TIME_ATTRIBUTES is
		select distinct Attribute1  from HXC_TIME_ATTRIBUTES 
									where 
									Attribute_Category = 'SECURITY' and
									Attribute1 is not null and
									time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									)))) 
									order by Attribute1 desc;

	cursor c_MO_details is
		select   distinct pov.profile_option_value from   fnd_profile_options po, fnd_profile_option_values pov					  
		where  po.profile_option_name ='ORG_ID'
		and pov.level_id=10003
		and pov.level_value in 
		(
		select responsibility_id from fnd_responsibility_VL where responsibility_id in
											(select distinct attribute4
											 from HXC_TIME_ATTRIBUTES atr, HXC_TIME_ATTRIBUTE_USAGES usg, HXC_TIME_BUILDING_BLOCKS tbb
											 where Attribute_Category = 'SECURITY'
											 and scope = 'TIMECARD'
											 and atr.Time_Attribute_Id = usg.Time_Attribute_Id
											 and usg.Time_Building_Block_Id = tbb.Time_Building_Block_Id
											 and tbb.resource_id =  ('&&4')
											 and trunc(tbb.start_time) = to_date('&&5')
											 )
		)					
		and    pov.application_id = po.application_id				
		and    pov.profile_option_id = po.profile_option_id
		and pov.profile_option_value is not null;

	cursor c_HXC_APP_PERIOD_SUMMARY is
		select Time_Recipient_Id, Notification_Status, Approver_Id, Creation_Date, Approval_Status from HXC_APP_PERIOD_SUMMARY 
		where application_period_id in 
		(select application_period_id from HXC_TC_AP_LINKS where timecard_id in (
		select time_building_block_id from hxc_time_building_blocks 
				where scope in ('TIMECARD') 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
		)) order by Application_Period_Id; 

		
	v_start_time date;
	v_stop_time date;
	v_time_summary number;
	v_Time_Recipient_Id HXC_APP_PERIOD_SUMMARY.Time_Recipient_Id%type;
	v_Notification_Status HXC_APP_PERIOD_SUMMARY.Notification_Status%type;
	v_time_rec_name hxc_time_recipients.name%type;
	v_Time_Building_Block_Id HXC_TRANSACTION_DETAILS.Time_Building_Block_Id%type;
	v_Exception_Description HXC_TRANSACTION_DETAILS.Exception_Description%type;
	cursor c_HXC_TRANSACTION_DETAILS is
			  select distinct Time_Building_Block_Id , Exception_Description  from HXC_TRANSACTION_DETAILS 
				where time_building_block_id in 
				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))
				and upper(status) like '%ERROR%'
				order by Time_Building_Block_Id;
	cursor c_HXC_RETRIEVAL_PROCESSES
			is select TIME_RECIPIENT_ID,NAME from HXC_RETRIEVAL_PROCESSES where 
			retrieval_process_id in 
			(select transaction_process_id from hxc_transactions where type = 'RETRIEVAL' 
			and transaction_id in 
			(select transaction_id from HXC_TRANSACTION_DETAILS 
			where time_building_block_id in 
			(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS 
			where scope = 'DETAIL' and parent_building_block_id in 
			(select time_building_block_id from hxc_time_building_blocks 
			where scope = 'DAY' and parent_building_block_id in 
			(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
			and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))));
	v_retrival_proc_name HXC_RETRIEVAL_PROCESSES.name%type;
	
			

	v_run_recipient VARCHAR2(22);
	v_approval_name HXC_APPROVAL_STYLES.name%type;
	cursor c_HXC_APPROVAL_COMPS_app is
		select distinct Approval_Mechanism from HXC_APPROVAL_COMPS where 
		approval_style_id in 
		(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
		and date_to=to_date('31-DEC-4712'));
	cursor c_HXC_APPROVAL_COMPS is
		select approval_comp_id,Approval_Mechanism from HXC_APPROVAL_COMPS where 
		(Approval_Mechanism like '%WORKFLOW%' or Approval_Mechanism like '%FORMULA%')
		and approval_style_id in 
		(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
		and date_to=to_date('31-DEC-4712'));
	v_approval_id HXC_APPROVAL_COMPS.approval_comp_id%type;
	v_approval_mec HXC_APPROVAL_COMPS.Approval_Mechanism%type;
	v_payroll_id PER_ALL_ASSIGNMENTS_F.payroll_id%type;
	v_end_date date;
	v_supervisor_id PER_ALL_ASSIGNMENTS_F.Supervisor_Id%type;
	v_org_id PER_ALL_ASSIGNMENTS_F.Organization_Id%type;
	v_primary_flag PER_ALL_ASSIGNMENTS_F.primary_flag%type;
	v_id HXT_TIMECARDS_F.id%type;
	v_tc_details number;
	v_tc_summary number;
	v_pa_exped number;
	v_issue boolean:=FALSE;
	
	v_type_timecard varchar2(150);
	v_type_absences varchar2(150);
	v_retrieval_rule varchar2(150);
	v_per_as varchar2(150);
	v_per_ap varchar2(150);
	v_per_astyle varchar2(150);
	v_per_ter varchar2(150);
	l_pref_table hxc_preference_evaluation.t_pref_table;
	l_pref_row hxc_preference_evaluation.t_pref_table_row;
	
	v_Auto_Gen_Flag HXT_TIMECARDS_F.Auto_Gen_Flag%type;
	v_rows1 number;
	v_rows2 number;
	v_rows3 number;
	v_rows4 number;
	
	cursor c_HXT_BATCH_STATES is
	select Batch_Id, Status   from HXT_BATCH_STATES where 
					batch_id in 
					(select batch_id from HXT_TIMECARDS_F where id = '&&8' 
					union 
					select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8');
	v_batch_id HXT_BATCH_STATES.batch_id%type;
	v_batch_status HXT_BATCH_STATES.status%type;					
	v_batch_source PAY_BATCH_HEADERS.batch_source%type;
	v_status_hxt_states HXT_BATCH_STATES.status%type;
	cursor c_PAY_BATCH_HEADERS is
			select batch_id, batch_status, batch_source from PAY_BATCH_HEADERS
			where batch_id in 
			(select batch_id from HXT_TIMECARDS_F where id ='&&8' 
			union 
			select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8');
	v_Batch_Name PAY_BATCH_HEADERS.Batch_Name%type;
	
	cursor c_HXC_TRANSACTIONS is
		select creation_date,Status,transaction_code,exception_description
		from HXC_TRANSACTIONS 
				where type='RETRIEVAL' and transaction_id in 
				(select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in 
				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
				and parent_building_block_id in (select time_building_block_id 
				from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))))
				order by transaction_date;
	v_creation_date HXC_TRANSACTIONS.creation_date%type;
	v_status_trans HXC_TRANSACTIONS.status%type;
	v_transaction_code HXC_TRANSACTIONS.transaction_code%type;
	v_ex_desc_trans HXC_TRANSACTIONS.exception_description%type;

	v_Attribute1 HXC_TIME_ATTRIBUTES.Attribute1%type;
	cursor c_PROJECT_MANAGER is
		select distinct Attribute1  from HXC_TIME_ATTRIBUTES 
		where 
		Attribute_Category = 'PROJECTS' and
		time_attribute_id in 
		(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
		(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
		and parent_building_block_id in 
		(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
		and parent_building_block_id in 
		(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
		)))) 
		order by Attribute1;
	v_project_name pa_projects_all.name%type;
	
		v_Error_Message WF_ITEM_ACTIVITY_STATUSES.Error_Message%type;
	
	v_app_set_id1 	HXC_LATEST_DETAILS.Application_Set_Id%type;	
	v_app_set_id2 	HXC_LATEST_DETAILS.Application_Set_Id%type;	
	v_app_set_id3 	HXC_LATEST_DETAILS.Application_Set_Id%type;	
	issue_app_set_id boolean:=FALSE;
	
	v_org_id1 HXC_TIME_ATTRIBUTES.Attribute1%type;
	v_org_id2 HXC_TIME_ATTRIBUTES.Attribute1%type;
	v_org_id3 number(15);
	issue_org_id boolean:=FALSE;
	issue_compare boolean;
					
	v_Object_Version_Number HXC_LATEST_DETAILS.Object_Version_Number%type;
	
	cursor c_HXC_LATEST_DETAILS is 
		select Time_Building_Block_Id,Object_Version_Number from HXC_LATEST_DETAILS 
								where time_building_block_id in 
								(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
								and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))
		minus
		select Time_Building_Block_Id,Object_Version_Number from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
								and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
								)) ;
	cursor c_Expenditure_Item is
		select eia.Expenditure_Item_Id, substr(eia.orig_transaction_reference,instr(eia.orig_transaction_reference,':')+1,1), substr(eia.orig_transaction_reference,1,instr(eia.orig_transaction_reference,':')-1)
		   from pa_expenditure_items_all eia
			  , pa_expenditures_all ea
			  , hxc_timecard_summary tcs
		 where eia.expenditure_id = ea.expenditure_id
		   and ea.incurred_by_person_id = tcs.resource_id
		   and tcs.resource_id = ('&&4')
		   and tcs.start_time =  to_date('&&5')
		   and eia.Transaction_Source = 'ORACLE TIME AND LABOR'
		   and eia.expenditure_item_date between tcs.start_time and tcs.stop_time
		   and substr(eia.orig_transaction_reference,instr(eia.orig_transaction_reference,':')+1,1) not in
		   (
		   select object_version_number from hxc_time_building_blocks where time_building_block_id = substr(eia.orig_transaction_reference,1,instr(eia.orig_transaction_reference,':')-1)
		   )
		   order by expenditure_item_date;
	v_Expenditure_item_id pa_expenditure_items_all.Expenditure_item_id%type;
	cursor c_HXC_TEMPLATE_SUMMARY is
			select TEMPLATE_NAME from HXC_TEMPLATE_SUMMARY where resource_id = ('&&4') and trunc(start_time) = to_date('&&5');
	v_TEMPLATE_NAME HXC_TEMPLATE_SUMMARY.TEMPLATE_NAME%type;
	cursor c_timecard_created is
		select full_name
		  from per_all_people_f, fnd_user
		 where sysdate between effective_start_date and effective_end_date
		   and user_id in (select distinct created_by
							 from HXC_TIME_BUILDING_BLOCKS
							where scope = 'TIMECARD'
							  and resource_id = ('&&4')
							  and trunc(start_time) = to_date('&&5'))
		   and employee_id = person_id ;
		   
	cursor c_timecard_updated is
		select full_name
		  from per_all_people_f, fnd_user
		 where sysdate between effective_start_date and effective_end_date
		   and user_id in (select distinct last_updated_by
							 from HXC_TIME_BUILDING_BLOCKS
							where scope = 'TIMECARD'
							  and resource_id = ('&&4')
							  and trunc(start_time) = to_date('&&5'))
		   and employee_id = person_id ;
	v_responsibility_id fnd_responsibility_VL.responsibility_id%type;
	v_responsibility_name fnd_responsibility_VL.responsibility_name%type;
	cursor c_HXC_TIME_ATTR_RESP is
							select responsibility_id, responsibility_name 
							from fnd_responsibility_VL where responsibility_id in
									(select distinct attribute4
									 from HXC_TIME_ATTRIBUTES atr, HXC_TIME_ATTRIBUTE_USAGES usg, HXC_TIME_BUILDING_BLOCKS tbb
									 where Attribute_Category = 'SECURITY'
									 and scope = 'TIMECARD'
									 and atr.Time_Attribute_Id = usg.Time_Attribute_Id
									 and usg.Time_Building_Block_Id = tbb.Time_Building_Block_Id
									 and tbb.resource_id =  ('&&4')
									 and trunc(tbb.start_time) = to_date('&&5')
									 );
	v_profile_option_value fnd_profile_option_values.profile_option_value%type;
	v_security varchar2(42);
	v_custom_act varchar2(70);
	cursor c_Custom_Activities is
		select ap.name || '/' || pa.instance_label Activity
			from wf_item_activity_statuses ias,
			wf_process_activities     pa,
			wf_activities             ac,
			wf_activities             ap,
			wf_items                  i
			where (ias.item_type, ias.item_key) in 
			(select item_type, item_key from WF_ITEM_ATTRIBUTE_VALUES where item_type = 'HXCEMP' and name = 'TC_BLD_BLK_ID'
			and number_value in 
			(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD'
			and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))) 
			and (ap.name like '%CUSTOM%' or ap.name like '%FORMULA%' or ap.name like '%XX%' or pa.instance_label like '%CUSTOM%' or pa.instance_label like '%FORMULA%' or pa.instance_label like '%XX%')
			and ias.process_activity = pa.instance_id
			and pa.activity_name = ac.name
			and pa.activity_item_type = ac.item_type
			and pa.process_name = ap.name
			and pa.process_item_type = ap.item_type
			and pa.process_version = ap.version
			and i.item_type = 'HXCEMP'
			and i.item_key = ias.item_key
			and i.begin_date >= ac.begin_date
			and i.begin_date < nvl(ac.end_date, i.begin_date + 1);
	v_date_pref date default sysdate;
	l_old_date_format varchar2(40);
	v_mobile boolean:=FALSE;
		
begin -- begin MAIN

:g_curr_loc:=1;
DBMS_LOB.CREATETEMPORARY(:g_hold_output3,TRUE,DBMS_LOB.SESSION);
l_o('<BR>');	

select value
     into l_old_date_format
     from nls_session_parameters
     where parameter = 'NLS_DATE_FORMAT';
     execute immediate 'alter session set nls_date_format = ''' || g_sql_date_format || '''';
	 
-- Display HXC output

if upper('&&3') = 'Y' then
-- ************************
-- *** HXC_TC.. 
-- ************************
		begin
		declare

		type TBBR is record ( time_building_block_id  hxc.hxc_time_building_blocks.time_building_block_id%type
							, scope                   hxc.hxc_time_building_blocks.scope%type
							);
		type TBBT is varray(1000000) of TBBR;
		TBB TBBT;

		l_tbb_tim varchar2(32767);
		l_tbb_day varchar2(32767);
		l_tbb_det varchar2(32767);
		l_tbb_app varchar2(32767);
		l_tbb_tem varchar2(32767);

		l_apps varchar2(32767);

		l_show_ar boolean:=FALSE;

		function test_person return boolean is
		  l_dummy number;
		begin

			  select count(1)
			  into l_dummy
			  from per_all_people_f
			  where person_id = l_param2;

			  if l_dummy > 0 then
				return true;
			  else
				return false;
			  end if;

			exception
			  when others then
				return false;

		end test_person;

		function test_timecard return boolean is
		  l_dummy number;
		  v_sql varchar2(1000);
		begin

				 select count(1)
				   into l_dummy
				   from hxc_time_building_blocks
				  where scope = 'TIMECARD'
					and resource_id = l_param2
					and trunc(start_time) = to_date(l_param3);

			  if l_dummy > 0 then
				return true;
			  else
				 select count(1) into l_dummy from dba_tables where table_name='HXC_TIME_BUILDING_BLOCKS_AR';
				 if  l_dummy = 0 then
					ErrorPrint('There is no timecard with this id!');
					return false;
				 else
							 v_sql:='select count(1) 
										from hxc_time_building_blocks_AR
										where scope = ''TIMECARD''
										and resource_id = '||l_param2||
										'and trunc(start_time) = to_date('''||l_param3||''')';
							 execute immediate v_sql into l_dummy;
													

							 if l_dummy > 0 then

							   if l_param1 <> 'HXC_TC_AR' then
								  l_o('<BR>');
								  --ErrorPrint('This timecard is archived!');
								  l_param1 := 'HXC_TC_AR';
							   end if;

							   return true;
							 else
							   return false;
							 end if;
				  end if;
			  end if;

			exception
			  when others then
				return false;

		end test_timecard;

		function build_query1 ( p_ar varchar2 default null ) return varchar2 is
		  l_ar varchar2(10);
		  l_dummy varchar2(32767);
		begin

			  if p_ar is not null then
				l_ar := '_ar';
			  end if;

			  l_dummy := '
				select distinct time_building_block_id, scope
				from hxc_time_building_blocks'||l_ar||'
				start with time_building_block_id in (
				select distinct(time_building_block_id)
				  from hxc_time_building_blocks'||l_ar||'
				 where scope = ''TIMECARD''
				   and resource_id = '||l_param2||'
				   and trunc(start_time) = to_date('''||l_param3||'''))
				connect by prior time_building_block_id = parent_building_block_id
				UNION
				select distinct time_building_block_id, scope
				from hxc_time_building_blocks'||l_ar||'
				where scope in (''APPLICATION_PERIOD'', ''TIMECARD_TEMPLATE'')
				  and resource_id = '||l_param2||'
				  and trunc(start_time) = to_date('''||l_param3||''')'||chr(10);

			  return l_dummy;

		end build_query1;

		function build_tbbs ( TBB tbbt, p_scope varchar2) return varchar2 is
		  l_tbbs varchar2(32767);
				begin
				  for i in TBB.first..TBB.last loop
					if TBB(i).scope like p_scope then
					  if l_tbbs is null then
						 l_tbbs := '('||TBB(i).time_building_block_id;
					  else
						 l_tbbs := l_tbbs ||','||TBB(i).time_building_block_id;
					  end if;
					end if;
				  end loop;

				  if l_tbbs is not null then
					 l_tbbs := l_tbbs ||')';
				  else
					 l_tbbs := '(-1)';
				  end if;

				  return l_tbbs;

				exception
				  when others then
					return '(-1)';

		end build_tbbs;

		function build_apps return varchar2 is

		 type TAPPR is record ( time_recipient_name   hxc.hxc_time_recipients.name%type );
		 type TAPPT is varray(1000000) of TAPPR;
		 TAPP TAPPT;

		 l_query varchar2(32767);
		 l_apps varchar2(32767);

		begin

			  l_query := '
			  select distinct upper(time_recipient_name)
				from hxc_application_set_comps_v
			   where application_set_id in (select application_set_id
											  from hxc_time_building_blocks
											 where time_building_block_id in '||l_tbb_tim||')';

			  execute immediate l_query bulk collect into TAPP;

			  for i in TAPP.first..TAPP.last loop
				if l_apps is null then
					 l_apps := TAPP(i).time_recipient_name;
				else
					 l_apps := l_apps ||','||TAPP(i).time_recipient_name;
				end if;
			  end loop;

			  return l_apps;

			exception
			  when others then
				return 'x';

		end build_apps;

		procedure show_tbb_data ( p_tbbs varchar2, p_ar varchar2, p_title varchar2 ) is
		  l_ar varchar2(10);
		begin

			  if p_ar is not null then
				l_ar := '_AR';
			  end if;			
			  
			  if p_ar is null then
					  if p_title='Timecard' then
							l_o('<a name="HXC_Timecard"></a>');
					  elsif p_title='Detail' then
							l_o('<a name="HXC_Detail"></a>');
					  end if;
			  end if;
					  
			  sqlTxt := 'select * from HXC_TIME_BUILDING_BLOCKS'||l_ar||' where time_building_block_id in '||p_tbbs||' order by time_building_block_id, object_version_number';
			  run_sql('HXC_TIME_BUILDING_BLOCKS'||l_ar||' - '||p_title, sqltxt);
			  v_sql:='select count(1) from HXC_TIME_BUILDING_BLOCKS'||l_ar||' where time_building_block_id in '||p_tbbs||' and resource_id <> (''&&4'')';
			  execute immediate v_sql into v_rows;
			  if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
			  end if;
			  
			  if p_ar is null then
					  if p_title='Timecard' then
							-- HXC_TIME_BUILDING_BLOCKS - Timecard 
							select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
							and date_to=to_date('31-DEC-4712');
							if v_rows=0 then
									-- Timecard deleted
									:w3:=:w3+1;
									l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>This Timecard was deleted.</div><br>');
									select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
										and resource_id = ('&&4') and trunc(start_time) = to_date('&&5');
									if v_rows>0 then
											select *  into v_approval_style from
												(select name  from hxc_approval_styles where approval_style_id in
													(
													select Approval_Style_Id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
													and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
													)
												order by 1 desc)
												where rownum < 2;
												l_o('<div class="divok"> Approval Style effective on this Timecard is: </span><span class="sectionblue">'|| v_approval_style);
												l_o('</span>. For more information on this Approval Style please refer to section <a href="#HXC_APPROVAL_STYLES">HXC_APPROVAL_STYLES</a><br>');
												l_o(' Application(s) linked with this Timecard is(are): '); 
												v_rows:=0;
												open c_TIME_RECIPIENT_NAME2;
												loop
													  fetch c_TIME_RECIPIENT_NAME2 into v_time_recipient_name;
													  EXIT WHEN  c_TIME_RECIPIENT_NAME2%NOTFOUND;
													  if v_rows=1 then
															l_o('; ');
													  end if;
													  l_o('<span class="sectionblue">'||v_time_recipient_name||'</span>');
													  v_rows:=1;
												end loop;
												close c_TIME_RECIPIENT_NAME2;
												l_o('</div><br>');
												
												-- check if Application_Set_Id is null
												select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
													and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
													and Application_Set_Id is null;
												if v_rows>0 then
													l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
													:w3:=:w3+1;
												end if;												
												
									end if;
							else
									select *  into v_approval_style from
									(select name  from hxc_approval_styles where approval_style_id in
										(
										select Approval_Style_Id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
										and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
										and date_to=to_date('31-DEC-4712')
										)
									order by 1 desc)
									where rownum < 2;
									l_o('<div class="divok"> Approval Style effective on this Timecard is: </span><span class="sectionblue">'|| v_approval_style);
									l_o('</span>. For more information on this Approval Style please refer to section <a href="#HXC_APPROVAL_STYLES">HXC_APPROVAL_STYLES</a><br>');
									l_o(' Application(s) linked with this Timecard is(are): '); 
									v_rows:=0;
									open c_TIME_RECIPIENT_NAME;
									loop
										  fetch c_TIME_RECIPIENT_NAME into v_time_recipient_name;
										  EXIT WHEN  c_TIME_RECIPIENT_NAME%NOTFOUND;
										  if v_rows=1 then
												l_o('; ');
										  end if;
										  l_o('<span class="sectionblue">'||v_time_recipient_name||'</span>');
										  v_rows:=1;
									end loop;
									close c_TIME_RECIPIENT_NAME;
									l_o('</div><br>');
									
									-- check if Application_Set_Id is null
									select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
										and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
										and date_to=to_date('31-DEC-4712')
										and Application_Set_Id is null;
									if v_rows>0 then
										l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
										:w3:=:w3+1;
									end if;						
									

							end if;
							
							-- check if Application_Set_Id is having a different values in this table
							select count(distinct Application_Set_Id) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
							and Application_Set_Id is not null;
							if v_rows>1 then
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');
								:w3:=:w3+1;
								issue_app_set_id:=TRUE;
							elsif v_rows=1 then
								select distinct Application_Set_Id into v_app_set_id1 from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
									and Application_Set_Id is not null;
							end if;	
							
							
							
					  elsif p_title='Detail' then
							-- HXC_TIME_BUILDING_BLOCKS - Detail
							v_sql:='select count(1) from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
								and Translation_Display_Key is not null and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
								and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')
								))';
							execute immediate v_sql into v_rows;
							
							
							if v_rows=0 then
								l_o('<div class="divok"><span class="sectionblue"> This timecard was not entered from Self Service</span></div><br>');
							elsif v_rows=1 then
								l_o('<div class="divok"><span class="sectionblue"> This timecard was entered from Self Service</span></div><br>');
							end if;
							select count(1) into v_rows from dba_tables where table_name='HXC_MOB_TRANSIT_TIMECARDS';
							if v_rows>0 then
								v_sql:='select count(1) from hxc_mob_transit_timecards where resource_id = (''&&4'') and trunc(tc_start_time) = to_date(''&&5'')';
								execute immediate v_sql into v_rows;
								if v_rows>0 then
									v_mobile:=TRUE;
									l_o('<div class="divok"><span class="sectionblue"> This timecard was entered/edited using Mobile application</span></div><br>');
								end if;
							end if;									
							-- check if Application_Set_Id is having a different values in this table
							select count(distinct Application_Set_Id) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
								and Application_Set_Id is not null
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
								and parent_building_block_id in 
								(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
								and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
								)) ;
							if v_rows>1 then
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');
								issue_app_set_id:=TRUE;
								:w3:=:w3+1;
							elsif v_rows=1 then
								select distinct Application_Set_Id into v_app_set_id2 from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
									and Application_Set_Id is not null
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									)) ;
							end if;
							
							-- check if Application_Set_Id is null
							select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 								
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
											)) 
											and date_to=to_date('31-DEC-4712')
											and Application_Set_Id is null;
							if v_rows>0 then
										l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
										:w3:=:w3+1;
							end if;
							
							-- check if Approval_style_id is null
							select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 								
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
											)) 
											and date_to=to_date('31-DEC-4712')
											and Approval_style_id is null;
							if v_rows>0 then
										l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Approval_style_id is null in one or more active record(s).<br></div>');
										:w3:=:w3+1;
							end if;
							
							
					  elsif p_title='Application_Period' then
							-- HXC_TIME_BUILDING_BLOCKS - Application_Period 
							select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS 
							where scope = 'APPLICATION_PERIOD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
							order by object_version_number desc;
							if v_rows=1 then
									select Approval_Status into v_approval_status from
									(select Approval_Status from HXC_TIME_BUILDING_BLOCKS 
									where scope = 'APPLICATION_PERIOD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
									order by object_version_number desc)
									where rownum < 2;
									l_o('<div class="divok"> Last Approval Period Component status is: <span class="sectionblue">'||v_approval_status||'</span></div><br>');
							end if;
					  elsif p_title='Timecard Template' then
							-- HXC_TIME_BUILDING_BLOCKS - Timecard Template
							-- HXC_TEMPLATE_SUMMARY
							  sqlTxt := 'select * from HXC_TEMPLATE_SUMMARY where resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')';
							  run_sql('HXC_TEMPLATE_SUMMARY', sqltxt);
							  
							  select count(1) into v_rows from HXC_TEMPLATE_SUMMARY where resource_id = ('&&4') and trunc(start_time) = to_date('&&5');
							  if v_rows>0 then
								  l_o('<div class="divok"> The following Template was used to create this timecard: <span class="sectionblue">');
								  v_rows:=0;
								  open c_HXC_TEMPLATE_SUMMARY;
									loop
										  fetch c_HXC_TEMPLATE_SUMMARY into v_TEMPLATE_NAME;
										  EXIT WHEN  c_HXC_TEMPLATE_SUMMARY%NOTFOUND;
										  if v_rows=1 then
											l_o(' , ');
										  end if;
										  l_o(v_TEMPLATE_NAME);
										  v_rows:=1;
									end loop;
									close c_HXC_TEMPLATE_SUMMARY;
									l_o('<br></span></div>');
							  end if;

					  end if;
			  end if;
			  
			  sqlTxt := 'select * from HXC_TIME_ATTRIBUTE_USAGES'||l_ar||' where time_building_block_id in '||p_tbbs||' order by time_building_block_id, time_building_block_ovn';
			  run_sql('HXC_TIME_ATTRIBUTE_USAGES'||l_ar||' - '||p_title, sqltxt);
				
			  l_o('</ br>');
			  
			  if p_ar is null then
						if p_title='Timecard' then
							l_o('<a name="HXC_Attribute_Timecard"></a>');
						 elsif p_title='Detail' then
							l_o('<a name="HXC_Attribute_Detail"></a>');
						end if;
			  end if;
			  
			  sqlTxt := 'select * from HXC_TIME_ATTRIBUTES'||l_ar||' where time_attribute_id in (select time_attribute_id from hxc_time_attribute_usages'||l_ar||' where time_building_block_id in '||p_tbbs||') order by time_attribute_id';
			  run_sql('HXC_TIME_ATTRIBUTES'||l_ar||' - '||p_title, sqltxt);
			  if p_ar is null then
					  if p_title='Timecard' then
							-- HXC_TIME_ATTRIBUTES - Timecard 
							l_o('<div class="divok">');
							select count(1) into v_rows from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
							(select * from
							(select Attribute1 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))) 
							order by Time_Attribute_Id desc )
							where rownum < 2);
							if v_rows=1 then
									select display_layout_name into v_layout_name from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
									(select * from
									(select Attribute1 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))) 
									order by Time_Attribute_Id desc )
									where rownum < 2);
									l_o(' Timecard Layout is: <span class="sectionblue">'||v_layout_name||'</span><br>');
							end if;

							select count(1) into v_rows from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
							(select * from
							(select Attribute2 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2);
							if v_rows=1 then
									select display_layout_name into v_layout_name from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
									(select * from
									(select Attribute2 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2);
									l_o(' Review Layout is: <span class="sectionblue">'||v_layout_name||'</span><br>');
							end if;					

							select count(1) into v_rows from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
							(select * from
							(select Attribute3 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2);
							if v_rows=1 then
									select display_layout_name into v_layout_name from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
									(select * from
									(select Attribute3 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2);
									l_o(' Confirmation Layout is: <span class="sectionblue">'||v_layout_name||'</span><br>');
							end if;						

							select count(1) into v_rows from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
							(select * from
							(select Attribute4 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2);
							if v_rows=1 then
									select display_layout_name into v_layout_name from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
									(select * from
									(select Attribute4 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2);
									l_o(' Details Layout is: <span class="sectionblue">'||v_layout_name||'</span><br>');
							end if;		

							select count(1) into v_rows from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
							(select * from
							(select Attribute8 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2);
							if v_rows=1 then
									select display_layout_name into v_layout_name from hxc_layouts b, hxc_layouts_tl t where b.layout_id=t.layout_id and language='US' and b.layout_id=
									(select * from
									(select Attribute8 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2);
									l_o(' Notification Layout : <span class="sectionblue">'||v_layout_name||'</span><br>');
							end if;	
							
							select count(1) into v_rows from
							(select Attribute6 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'LAYOUT' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2;
							if v_rows=1 then
									select * into v_attribute from
									(select Attribute6 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'LAYOUT' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2;	
									if v_attribute is not null then
											l_o(' CLA Layout is used<br>');
									end if;
							end if;
							

							select count(1) into v_rows from
							(select Attribute2 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'SECURITY' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2;
							if v_rows=1 then
									select * into v_attribute from
									(select Attribute2 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'SECURITY' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2;	
									if v_attribute is not null then
											l_o(' Business Group is: <span class="sectionblue">'||v_attribute);
											select name into v_org_name from hr_all_organization_units where organization_id = v_attribute;
											l_o(' </span>- <span class="sectionblue">'||v_org_name ||'</span><br>');
									end if;
							end if;
							

							select count(1) into v_rows from
							(select Attribute1 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'SECURITY' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2;
							if v_rows=1 then
									select * into v_attribute from
									(select Attribute1 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'SECURITY' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2;	
									if v_attribute is not null then
											l_o(' Organization is: <span class="sectionblue">'||v_attribute);
											select name into v_org_name from hr_all_organization_units where organization_id = v_attribute;
											l_o(' </span>- <span class="sectionblue">'||v_org_name ||'</span><br>');									
									end if;
							end if;

							select count(1) into v_rows from
							(select Attribute3 from HXC_TIME_ATTRIBUTES 
							where Attribute_Category = 'SECURITY' and 
							time_attribute_id in 
								(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
							order by Time_Attribute_Id desc )
							where rownum < 2;
							if v_rows=1 then
									select * into v_attribute from
									(select Attribute3 from HXC_TIME_ATTRIBUTES 
									where Attribute_Category = 'SECURITY' and 
									time_attribute_id in 
										(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
											in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))  
									order by Time_Attribute_Id desc )
									where rownum < 2;	
									if v_attribute is not null then
											l_o(' Username who entered this timecard is: <span class="sectionblue">'||v_attribute);
											select count(1) into v_rows from fnd_user where user_id=v_attribute;
											if v_rows=1 then
													select user_name into v_user_name
													from fnd_user
													where user_id=v_attribute;
													l_o(' </span>- <span class="sectionblue">'||v_user_name);
											end if;
											l_o('</span><br>');
											
									end if;
							end if;	
							
							-- check if Attribute1 where attribute_category = SECURITY  is having a different values in this table							
							select count(distinct Attribute1) into v_rows from HXC_TIME_ATTRIBUTES 
									where  	time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))
							and Attribute1 is not null
							and upper(attribute_category) like '%SECURITY%';
							if v_rows>1 then
								l_o(' Organization (<span class="sectionblue">Org_Id</span>) has been changed for this timecard.<br>');																						
							end if;
							
							-- Include Responsibility used to create this timecard
							
							l_o(' Responsibility used to create this timecard is: <br>');
							open c_HXC_TIME_ATTR_RESP;							
							loop
								  fetch c_HXC_TIME_ATTR_RESP into v_responsibility_id,v_responsibility_name;
								  EXIT WHEN  c_HXC_TIME_ATTR_RESP%NOTFOUND;								 
								  l_o('   # Responsibility: <span class="sectionblue">'||v_responsibility_id||' - '||v_responsibility_name||' </span><br>');
								  select   count(1) into v_rows 
										from   fnd_profile_options po,
											   fnd_profile_option_values pov					  
										where  po.profile_option_name ='ORG_ID'
										and pov.level_id=10003
										and pov.level_value=v_responsibility_id					
										and    pov.application_id = po.application_id				
										and    pov.profile_option_id = po.profile_option_id
										and pov.profile_option_value is not null;
								  l_o('   # MO: Operating Unit (');
								  if v_rows=1 then
										  select   pov.profile_option_value into v_profile_option_value
												from   fnd_profile_options po,
													   fnd_profile_option_values pov					  
												where  po.profile_option_name ='ORG_ID'
												and pov.level_id=10003
												and pov.level_value=v_responsibility_id					
												and    pov.application_id = po.application_id				
												and    pov.profile_option_id = po.profile_option_id;												
												
												select count(1) into v_rows from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;
												if v_rows=1 then									
														select NAME into v_org_name from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;										
														l_o('<span class="sectionblue">'||v_profile_option_value||' - '||v_org_name||'</span>');									
												else
														l_o('<span class="sectionblue">'||v_profile_option_value||' - null</span>');
												end if;
												l_o(')');
								   else
										select   count(1) into v_rows 
										from   fnd_profile_options po,
											   fnd_profile_option_values pov					  
										where  po.profile_option_name ='ORG_ID'
										and pov.level_id=10001
										and pov.level_value=v_responsibility_id					
										and    pov.application_id = po.application_id				
										and    pov.profile_option_id = po.profile_option_id
										and pov.profile_option_value is not null;
										if v_rows=1 then
											select   pov.profile_option_value into v_profile_option_value
												from   fnd_profile_options po,
													   fnd_profile_option_values pov					  
												where  po.profile_option_name ='ORG_ID'
												and pov.level_id=10001
												and pov.level_value=v_responsibility_id					
												and    pov.application_id = po.application_id				
												and    pov.profile_option_id = po.profile_option_id;												
												
												select count(1) into v_rows from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;
												if v_rows=1 then									
														select NAME into v_org_name from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;										
														l_o('<span class="sectionblue">'||v_profile_option_value||' - '||v_org_name||'</span>');									
												else
														l_o('<span class="sectionblue">'||v_profile_option_value||' - null</span>');
												end if;
												l_o(')');
										else
												l_o('<span class="sectionblue">null   </span>)');
												select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
													and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
													and date_to=to_date('31-DEC-4712');
												if v_rows>0 then
														SELECT count(1) into v_rows FROM hxc_application_set_comps_v WHERE APPLICATION_SET_ID in 
																		(select application_set_id from HXC_TIME_BUILDING_BLOCKS 
																		where scope = 'TIMECARD' 
																		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
																		and date_to=to_date('31-DEC-4712')) 
																		and TIME_RECIPIENT_NAME in ('Purchasing','Projects');
														if v_rows>0 then
															l_o('<div class="diverr" id="sigte2"><img class="error_ico"><font color="red">Error:</font> You must have a value for profile "MO: Operating Unit" on the level of the responsibility that is creating this timecard.</div>');
															:e3:=:e3+1;
														end if;
												end if;
										end if;		
								   end if;
								   
								   select   count(1) into v_rows 
										from   fnd_profile_options po,
											   fnd_profile_option_values pov					  
										where  po.profile_option_name ='PER_SECURITY_PROFILE_ID'
										and pov.level_id=10003
										and pov.level_value=v_responsibility_id					
										and    pov.application_id = po.application_id				
										and    pov.profile_option_id = po.profile_option_id
										and pov.profile_option_value is not null;
								   l_o('<br>   # HR: Security Profile (');
								  if v_rows=1 then
										  select   pov.profile_option_value into v_profile_option_value
												from   fnd_profile_options po,
													   fnd_profile_option_values pov					  
												where  po.profile_option_name ='PER_SECURITY_PROFILE_ID'
												and pov.level_id=10003
												and pov.level_value=v_responsibility_id					
												and    pov.application_id = po.application_id				
												and    pov.profile_option_id = po.profile_option_id;												
												
												select count(1) into v_rows from PER_SECURITY_PROFILES 
													where SECURITY_PROFILE_ID = v_profile_option_value;
												if v_rows=1 then									
														select substr(SECURITY_PROFILE_NAME,1,40) into v_security from PER_SECURITY_PROFILES 
															where SECURITY_PROFILE_ID = v_profile_option_value;										
														l_o('<span class="sectionblue">'||v_profile_option_value||' - '||v_security||'</span>');									
												else
														l_o('<span class="sectionblue">'||v_profile_option_value||' - null</span>');
												end if;
								   else
										l_o('<span class="sectionblue">null</span>');
								   end if;
								   l_o(')<br>');

							end loop;
							close c_HXC_TIME_ATTR_RESP;
							l_o('</span><br>');
							
							l_o('</div>');
							
							-- check if Attribute1 where attribute_category = SECURITY  is having a different values in this table	for active rows						
							select count(distinct Attribute1) into v_rows from HXC_TIME_ATTRIBUTES 
									where  	time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									and date_to=to_date('31-DEC-4712')))
							and Attribute1 is not null
							and upper(attribute_category) like '%SECURITY%';
							if v_rows>1 then
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Attribute1 (<span class="sectionblue">Org_Id</span>) is having different values in the active records of this table.<br></div>');
								:w3:=:w3+1;
								issue_org_id:=TRUE;
							elsif v_rows=1 then
								select distinct Attribute1 into v_org_id1 from HXC_TIME_ATTRIBUTES 
									where  	time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id 
									in (select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									and date_to=to_date('31-DEC-4712')))
									and Attribute1 is not null
									and upper(attribute_category) like '%SECURITY%';
							end if;
							
							
							
							
					  elsif p_title='Detail' then
							-- HXC_TIME_ATTRIBUTES - Detail
							issue_compare:=TRUE;
							select count(distinct Attribute1) into v_rows   from HXC_TIME_ATTRIBUTES 
							where 
							Attribute_Category = 'SECURITY' and
							Attribute1 is not null and
							time_attribute_id in 
							(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
							)))) ;
							
							v_first:= TRUE;
							l_o('<div class="divok">');
							if v_rows=1 then
									select distinct Attribute1 into v_attribute from HXC_TIME_ATTRIBUTES 
									where 
									Attribute_Category = 'SECURITY' and
									Attribute1 is not null and
									time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									))));
									l_o(' Attributes on this timecard were stored on org_id: <span class="sectionblue">'||v_attribute);
									select name into v_org_name from hr_all_organization_units where organization_id = v_attribute;
									l_o(' </span>- <span class="sectionblue">'||v_org_name ||'</span><br>');
									issue_compare:=FALSE;
									
							elsif v_rows>1 then
									l_o(' Attributes on this timecard were stored on org_id: ');									
									open c_HXC_TIME_ATTRIBUTES;
									loop
										  fetch c_HXC_TIME_ATTRIBUTES into v_Attribute;
										  EXIT WHEN  c_HXC_TIME_ATTRIBUTES%NOTFOUND;
										  if not v_first then
											  l_o(' ; ');
										  end if;
										  l_o('<span class="sectionblue">'||v_attribute);
										  select name into v_org_name from hr_all_organization_units where organization_id = v_attribute;
										  l_o(' </span>- <span class="sectionblue">'||v_org_name ||'</span>');
										  v_first:=FALSE;										   
									end loop;
									l_o('<br>');
									close c_HXC_TIME_ATTRIBUTES;
							end if;
							
							l_o('"MO: Operating Unit" linked with this timecard''s responsibilities: ');
							v_first:= TRUE;
							open c_MO_details;
							loop
								  fetch c_MO_details into v_profile_option_value;
								  EXIT WHEN  c_MO_details%NOTFOUND;
										if not v_first then
											  l_o(' ; ');
										  end if;										  
										  select count(1) into v_rows from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;
										  if v_rows=1 then									
														select NAME into v_org_name from HR_ALL_ORGANIZATION_UNITS
															where ORGANIZATION_ID=v_profile_option_value;										
														l_o('<span class="sectionblue">'||v_profile_option_value||' - '||v_org_name||'</span>');									
												else
														l_o('<span class="sectionblue">'||v_profile_option_value||' - null</span>');
										  end if;
										  v_first:=FALSE;
							end loop;
							close c_MO_details;
							l_o('<br>');
							
							select count(1) into v_rows from per_all_assignments_f 
									where person_id = '&&4' and sysdate between effective_start_date and effective_end_date and primary_flag = 'Y' and assignment_type IN ('E', 'C');
							if v_rows=1 then
									select organization_id into v_org_id from per_all_assignments_f 
									where person_id = '&&4' and sysdate between effective_start_date and effective_end_date and primary_flag = 'Y' and assignment_type IN ('E', 'C');
									l_o(' Org ID of the Employee''s Assignment is: <span class="sectionblue">'|| v_org_id||' </span>');
									if v_org_id is not null then
										issue_compare:=FALSE;
										select count(1) into v_rows from hr_all_organization_units where organization_id = v_org_id;
										if v_rows=1 then									
											select name into v_org_name from hr_all_organization_units where organization_id = v_org_id;									
											l_o('- <span class="sectionblue">'||v_org_name ||'</span>');
										end if;
										l_o('<br>');
									end if;
							end if;
							
							select count(1) into v_rows from HXC_APPLICATION_SET_COMPS_V where application_set_id in 
														(select application_set_id from hxc_time_building_blocks where scope = 'TIMECARD' 			
																	and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
														)
														and upper(Time_Recipient_Name) like '%PROJECT%';
							if v_rows>0 then
								select count(1) into v_rows from ((select distinct Attribute1  from HXC_TIME_ATTRIBUTES 
															where 
															Attribute_Category = 'SECURITY' and
															Attribute1 is not null and
															time_attribute_id in 
															(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
															(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
															and parent_building_block_id in 
															(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
															and parent_building_block_id in 
															(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
															and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
															)))) ) minus (select   distinct pov.profile_option_value from   fnd_profile_options po, fnd_profile_option_values pov					  
								where  po.profile_option_name ='ORG_ID'
								and pov.level_id=10003
								and pov.level_value in 
								(
								select responsibility_id from fnd_responsibility_VL where responsibility_id in
																	(select distinct attribute4
																	 from HXC_TIME_ATTRIBUTES atr, HXC_TIME_ATTRIBUTE_USAGES usg, HXC_TIME_BUILDING_BLOCKS tbb
																	 where Attribute_Category = 'SECURITY'
																	 and scope = 'TIMECARD'
																	 and atr.Time_Attribute_Id = usg.Time_Attribute_Id
																	 and usg.Time_Building_Block_Id = tbb.Time_Building_Block_Id
																	 and tbb.resource_id =  ('&&4')
																	 and trunc(tbb.start_time) = to_date('&&5')
																	 )
								)					
								and    pov.application_id = po.application_id				
								and    pov.profile_option_id = po.profile_option_id
								and pov.profile_option_value is not null));
								if v_rows>0 then
									l_o('<br><div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>If you have unexpected values/behavior in your timecard LOVs or Retrieval process, please review ');
									Show_Link('1576602.1');
									l_o(' "Timecard List Of Values For Projects Are Not Based On the Operating Unit Of OTL" to fix that.</div><br>');
									:w3:=:w3+1;
								end if;
							end if;		
										
							l_o('</div>');							
					
							-- check if Attribute1 where attribute_category = SECURITY  is having a different values in this table							
							select count(distinct Attribute1) into v_rows from HXC_TIME_ATTRIBUTES 
							where time_attribute_id in 
							(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
							))))
							and Attribute1 is not null
							and upper(attribute_category) like '%SECURITY%';
							if v_rows>1 then
								l_o('<div class="divok"> Organization (<span class="sectionblue">Org_Id</span>) has been changed for this timecard.<br></div>');									
							end if;
							
							-- check if Attribute1 where attribute_category = SECURITY  is having a different values in this table for active rows							
							select count(distinct Attribute1) into v_rows from HXC_TIME_ATTRIBUTES 
							where time_attribute_id in 
							(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
							and date_to=to_date('31-DEC-4712')
							))))
							and Attribute1 is not null
							and upper(attribute_category) like '%SECURITY%';
							if v_rows>1 then
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Attribute1 (Org_Id) is having a different values in the active records of this table.<br></div>');
								issue_org_id:=TRUE;
								:w3:=:w3+1;
							elsif v_rows=1 then
								select distinct Attribute1 into v_org_id2 from HXC_TIME_ATTRIBUTES 
									where time_attribute_id in 
									(select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DETAIL' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
									and date_to=to_date('31-DEC-4712')
									))))
									and Attribute1 is not null
									and upper(attribute_category) like '%SECURITY%';
							end if;
					
							-- Display Elements used on this timecard
							sqlTxt := 'select element_type_id, element_name from pay_element_types_f where element_type_id in (select distinct substr(attribute_category,instr(attribute_category,''-'')+2) 
							from HXC_TIME_ATTRIBUTES where Attribute_Category like ''ELEMENT%'' and
							time_attribute_id in (select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in '||p_tbbs||'))';							
							run_sql('Elements used on this timecard', sqltxt);
							-- Display Projects used on this timecard
							sqlTxt := 'select Project_id, pj.name Project_Name, pj.carrying_out_organization_id Project_Org_Id, (select name from hr_all_organization_units where organization_id = pj.carrying_out_organization_id) Project_Org_Name
							from pa_projects_all pj	 where project_id in (select distinct Attribute1  from HXC_TIME_ATTRIBUTES where Attribute_Category like ''PROJECTS%'' and Attribute1 is not null and
							time_attribute_id in (select time_attribute_id from hxc_time_attribute_usages where time_building_block_id in '||p_tbbs||'))';
							run_sql('Projects used on this timecard', sqltxt);			
							
						end if;
				end if;
		end show_tbb_data;

		procedure show_app_data ( p_tbbs varchar2, p_ar varchar2 ) is
		  l_ar varchar2(10);
		begin

			  if p_ar is not null then
				l_ar := '_AR';
			  end if;

			  sqlTxt := 'select * from HXC_TC_AP_LINKS'||l_ar||' where timecard_id in '||p_tbbs;
			  run_sql('HXC_TC_AP_LINKS'||l_ar, sqltxt);
				
			  l_o('<a name="HXC_APP_PERIOD_SUMMARY"></a>');
			  sqlTxt := 'select * from HXC_APP_PERIOD_SUMMARY'||l_ar||' where application_period_id in (select application_period_id from HXC_TC_AP_LINKS'||l_ar||' where timecard_id in '||p_tbbs||')';
			  run_sql('HXC_APP_PERIOD_SUMMARY'||l_ar, sqltxt);
			  v_sql:='select count(1) from HXC_APP_PERIOD_SUMMARY'||l_ar||' where application_period_id in (select application_period_id from HXC_TC_AP_LINKS'||l_ar||' where timecard_id in '||p_tbbs||') and resource_id <> (''&&4'')';
			  execute immediate v_sql into v_rows;
			  if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
			  end if;
			  
			  -- HXC_APP_PERIOD_SUMMARY
			  
			  if p_ar is null then
					
					v_sql:= 'select min(trunc(start_time)) from HXC_APP_PERIOD_SUMMARY'||l_ar||' where application_period_id in (select application_period_id from HXC_TC_AP_LINKS'||l_ar||' where timecard_id in '||p_tbbs||')';
					execute immediate v_sql into v_start_time;
					v_sql:= 'select max(trunc(stop_time)) from HXC_APP_PERIOD_SUMMARY'||l_ar||' where application_period_id in (select application_period_id from HXC_TC_AP_LINKS'||l_ar||' where timecard_id in '||p_tbbs||')';
					execute immediate v_sql into v_stop_time;				
					if (v_stop_time-v_start_time) <> v_time_summary then
						:w3:=:w3+1;
						l_o('<div class="divwarn" id="siga8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Approval Period is not identical to Timecard Period and this might cause a delay in Approval. Please refer ');  
						l_o('<a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=551412.1" target="_blank"> Doc ID 551412.1</a> Timecard Status Stuck "Submitted" After Approval</div>');
					end if;
					
					l_o('<div class="divok">');
					open c_HXC_APP_PERIOD_SUMMARY;
					loop
							fetch c_HXC_APP_PERIOD_SUMMARY into v_Time_Recipient_Id, v_Notification_Status, v_Approver_Id, v_creation_date, v_Approval_Status;
							EXIT WHEN  c_HXC_APP_PERIOD_SUMMARY%NOTFOUND;
							select count(1) into v_rows from hxc_time_recipients where Time_Recipient_Id =v_Time_Recipient_Id;
							if v_rows=1 then
									select name into v_time_rec_name from hxc_time_recipients where Time_Recipient_Id =v_Time_Recipient_Id;
									l_o(' Approval Period Component: <span class="sectionblue">'||v_time_rec_name||'</span>');
							end if;
							l_o(' | Current Notification Status:  <span class="sectionblue">'||v_Notification_Status||' </span>  | Approval Status:  <span class="sectionblue">'||v_Approval_Status||' </span> ');							
							select count(1) into v_rows from per_all_people_f where person_id = v_Approver_Id
									and sysdate between effective_start_date and effective_end_date;
							if v_rows=1 then
									select full_name into v_person_name from per_all_people_f where person_id = v_Approver_Id
										and sysdate between effective_start_date and effective_end_date;
									l_o('|     Approver: <span class="sectionblue">'||v_person_name||'</span>     ');
							end if;
							select count(distinct typ.system_person_type) into v_rows from per_person_types typ, per_all_people_f pep 
								where pep.person_type_id = typ.person_type_id 
								and sysdate between pep.effective_start_date 
								and pep.effective_end_date 
								and pep.person_id = v_Approver_Id;
							if v_rows=1 then
									select distinct typ.system_person_type into v_system_person_type from per_person_types typ, per_all_people_f pep 
										where pep.person_type_id = typ.person_type_id 
										and sysdate between pep.effective_start_date 
										and pep.effective_end_date 
										and pep.person_id = v_Approver_Id;
									l_o('|     Approver Status: <span class="sectionblue">'||v_system_person_type||'</span>');
							end if;
							l_o('|     Approval Date: <span class="sectionblue">'||v_creation_date||'</span><br>');													 
 
					end loop;
					close c_HXC_APP_PERIOD_SUMMARY;
					l_o('</div>');
			 end if;
			 
			 
		end show_app_data;

		procedure show_trx_data ( p_tbbs varchar2, p_ar varchar2 ) is
		  l_ar varchar2(10);
		begin

			  if p_ar is not null then
				l_ar := '_AR';
			  end if;

			  sqlTxt := 'select * from HXC_AP_DETAIL_LINKS'||l_ar||' where time_building_block_id in '||p_tbbs;
			  run_sql('HXC_AP_DETAIL_LINKS'||l_ar, sqltxt);
			
			  
			  if p_ar is null then
					
					-- HXC_LATEST_DETAILS
					l_o('<a name="HXC_Latest_Detail"></a>');
					
					sqlTxt := 'select * from HXC_LATEST_DETAILS where time_building_block_id in '||p_tbbs;
					run_sql('HXC_LATEST_DETAILS', sqltxt);
					-- check if there are 2 different resource_id
					v_sql:='select count(1) from HXC_LATEST_DETAILS where time_building_block_id in '||p_tbbs||' and resource_id <> (''&&4'')';
					  execute immediate v_sql into v_rows;
					  if v_rows>0 then
							:e3:=:e3+1;
							l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
					  end if;
					-- check if Application_Set_Id is having a different values in this table
					-- check if Application_Set_Id is having a different value at one of the tables HXC_TIME_BUILDING_BLOCKS - Timecard, HXC_TIME_BUILDING_BLOCKS - Detail, HXC_LATEST_DETAILS
					select count(distinct Application_Set_Id) into v_rows from HXC_LATEST_DETAILS 
						where Application_Set_Id is not null
						and time_building_block_id in 
						(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
						and parent_building_block_id in 
						(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
						and parent_building_block_id in 
						(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
						and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))));
							if v_rows>1 then
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');														
								issue_app_set_id:=TRUE;
								:w3:=:w3+1;
								
							elsif v_rows=1 then
								select distinct Application_Set_Id into v_app_set_id3 from HXC_LATEST_DETAILS 
									where Application_Set_Id is not null
									and time_building_block_id in 
									(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))));
								if 	issue_app_set_id or (v_app_set_id1<>v_app_set_id2) or (v_app_set_id2<>v_app_set_id3) or (v_app_set_id1<>v_app_set_id3) then
									l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different value at one of the tables ');
									l_o('<a href="#HXC_Timecard">HXC_TIME_BUILDING_BLOCKS-Timecard</a>, ');
									l_o('<a href="#HXC_Detail">HXC_TIME_BUILDING_BLOCKS - Detail</a> or ');
									l_o('<a href="#HXC_Latest_Detail">HXC_LATEST_DETAILS</a><br></div>');
									:w3:=:w3+1;									
								end if;
							end if;						
				
					-- check if Application_Set_Id is null
					select count(1) into v_rows from HXC_LATEST_DETAILS where  time_building_block_id in 
											(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))
										and Application_Set_Id is null;
					if v_rows>0 then
							l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
							:w3:=:w3+1;
					end if;
					
					-- Check if HXC_LATEST_DETAILS.Object_Version_Number is having value not in HXC_TIME_BUILDING_BLOCKS - Detail.Object_Version_Number for the same Time_Building_Block_Id in both tables	
					select count(1) into v_rows from
					(select Time_Building_Block_Id,Object_Version_Number from HXC_LATEST_DETAILS 
							where time_building_block_id in 
							(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
							and parent_building_block_id in 
							(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
							and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))
					minus
					select Time_Building_Block_Id,Object_Version_Number from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
											and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
											)) );
					if v_rows>0 then
							:e3:=:e3+1;
							l_o('<div class="diverr" id="sigte3"><img class="error_ico"><font color="red">Error:</font> HXC_LATEST_DETAILS is having value Object_Version_Number that is not available in the original ');
							l_o('<a href="#HXC_Detail">HXC_TIME_BUILDING_BLOCKS - Detail</a> for the same Time_Building_Block_Id:<br>');
							open c_HXC_LATEST_DETAILS;
							loop
								fetch c_HXC_LATEST_DETAILS into v_Time_Building_Block_Id,v_Object_Version_Number;
								EXIT WHEN  c_HXC_LATEST_DETAILS%NOTFOUND;
								l_o('Object_Version_Number: <span class="sectionblue">'||v_Object_Version_Number||'</span>');
								l_o(' - Time_Building_Block_Id: <span class="sectionblue">'||v_Time_Building_Block_Id||'</span><br>');					  
							end loop;
							close c_HXC_LATEST_DETAILS;	
							l_o('Please apply the Patches in ');
							Show_Link('1576674.1');
							l_o(' Blanked OTL Hours Not Reversed By PRC: Transaction Import and ');
							Show_Link('1436945.1');
							l_o(' Some Timecard Adjustments Are Not Getting Picked Up And Transferred after reviewing the prerequisites.<br></div>');
							
					end if;
					
					select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='ORG_ID' and TABLE_NAME='HXC_LATEST_DETAILS';
					if v_rows>0 then
						-- check if HXC_LATEST_DETAILS.Org_Id is having values different from: HXC_TIME_ATTRIBUTES - Timecard.Attribute1 where attribute_category = SECURITY HXC_TIME_ATTRIBUTES - Detail.Attribute1 where attribute_category = SECURITY 							
						v_sql:='select count(distinct Org_Id ) from HXC_LATEST_DETAILS 
									where Org_Id  is not null
									and time_building_block_id in 
									(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
									and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
						execute immediate v_sql into v_rows;					
															
						if v_rows>1 then
									l_o('<div class="divok"> Organization (<span class="sectionblue">Org_Id</span>) has been changed for this timecard.<br></div>');									
						end if;
					
					
						-- check if HXC_LATEST_DETAILS.Org_Id is having values different from: HXC_TIME_ATTRIBUTES - Timecard.Attribute1 where attribute_category = SECURITY HXC_TIME_ATTRIBUTES - Detail.Attribute1 where attribute_category = SECURITY 
						-- for active rows
						v_sql:='select count(distinct Org_Id ) from HXC_LATEST_DETAILS 
									where Org_Id  is not null
									and time_building_block_id in 
									(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
									and parent_building_block_id in 
									(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
									and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')
									and date_to=to_date(''31-DEC-4712''))))';
						execute immediate v_sql into v_rows;		
														
						if v_rows>1 then
									l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Org_Id is having different values in the active records of this table.<br></div>');								
									issue_org_id:=TRUE;
									:w3:=:w3+1;
						elsif v_rows=1 then
									v_sql:='select distinct Org_Id from HXC_LATEST_DETAILS 
											where Org_Id  is not null
											and time_building_block_id in 
											(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
											and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')
											and date_to=to_date(''31-DEC-4712''))))';
									execute immediate v_sql into v_org_id3;
									
									if 	issue_org_id or (v_org_id1<>v_org_id2) or (v_org_id2<>v_org_id3) or (v_org_id1<>v_org_id3) then
										l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Org_id is having a different value at one of the tables ');
										l_o('<a href="#HXC_Attribute_Timecard">HXC_TIME_ATTRIBUTES - Timecard</a>, ');
										l_o('<a href="#HXC_Attribute_Detail">HXC_TIME_ATTRIBUTES - Detail</a> or ');
										l_o('<a href="#HXC_Latest_Detail">HXC_LATEST_DETAILS</a><br></div>');
										:w3:=:w3+1;
									end if;
						end if;
						
					end if;
						

					
					-- HXC_PA_LATEST_DETAILS		
					select count(1) into v_rows from dba_tables where table_name='HXC_PA_LATEST_DETAILS';
					if v_rows>0 then
						sqlTxt := 'select * from HXC_PA_LATEST_DETAILS where time_building_block_id in '||p_tbbs;
						run_sql('HXC_PA_LATEST_DETAILS', sqltxt);
						select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='APPLICATION_SET_ID' and TABLE_NAME='HXC_PA_LATEST_DETAILS';
								if v_rows>0 then
									-- check if Application_Set_Id is having a different values in this table
									v_sql:='select count(distinct Application_Set_Id) from HXC_PA_LATEST_DETAILS 
										where Application_Set_Id is not null
										and time_building_block_id in 
										(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
										and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
										execute immediate v_sql into v_rows;
										if v_rows>1 then
											l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');								
											:w3:=:w3+1;
										end if;
										
									-- check if Application_Set_Id is null
									v_sql:='select count(1) from HXC_PA_LATEST_DETAILS 
											where Application_Set_Id is null
											and time_building_block_id in 
											(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
											and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
											execute immediate v_sql into v_rows;									
										if v_rows>0 then
											l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
											:w3:=:w3+1;
										end if;
								end if;
					end if;
					
					select count(1) into v_rows from dba_tables where table_name='HXC_PAY_LATEST_DETAILS';
					if v_rows>0 then
						sqlTxt := 'select * from HXC_PAY_LATEST_DETAILS where time_building_block_id in '||p_tbbs;
						run_sql('HXC_PAY_LATEST_DETAILS', sqltxt);
						select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='APPLICATION_SET_ID' and TABLE_NAME='HXC_PAY_LATEST_DETAILS';
								if v_rows>0 then
									-- check if Application_Set_Id is having a different values in this table
									v_sql:='select count(distinct Application_Set_Id) from HXC_PAY_LATEST_DETAILS 
										where Application_Set_Id is not null
										and time_building_block_id in 
										(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
										and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
										execute immediate v_sql into v_rows;
										if v_rows>1 then
											l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');								
											:w3:=:w3+1;
										end if;
										
									-- check if Application_Set_Id is null
									v_sql:='select count(1) from HXC_PAY_LATEST_DETAILS 
											where Application_Set_Id is null
											and time_building_block_id in 
											(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
											and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
											execute immediate v_sql into v_rows;									
										if v_rows>0 then
											l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
											:w3:=:w3+1;
										end if;
								end if;
					end if;
					
					select count(1) into v_rows from dba_tables where table_name='HXC_RET_PA_LATEST_DETAILS';	
					if v_rows>0 then
						sqlTxt := 'select * from HXC_RET_PA_LATEST_DETAILS where time_building_block_id in '||p_tbbs;
						run_sql('HXC_RET_PA_LATEST_DETAILS', sqltxt);
						-- check if there are 2 resource_id
						v_sql:='select count(1) from HXC_RET_PA_LATEST_DETAILS where time_building_block_id in '||p_tbbs||' and resource_id <> (''&&4'')';
							  execute immediate v_sql into v_rows;
							  if v_rows>0 then
									:e3:=:e3+1;
									l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
							  end if;
						select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='APPLICATION_SET_ID' and TABLE_NAME='HXC_RET_PA_LATEST_DETAILS';
								if v_rows>0 then
									-- check if Application_Set_Id is having a different values in this table
									v_sql:='select count(distinct Application_Set_Id) from HXC_RET_PA_LATEST_DETAILS 
										where Application_Set_Id is not null
										and time_building_block_id in 
										(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
										and parent_building_block_id in 
										(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
										and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
										execute immediate v_sql into v_rows;
										if v_rows>1 then
											l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_Set_Id is having a different values in this table.<br></div>');
											:w3:=:w3+1;
										end if;
										
									-- check if Application_Set_Id is null
									v_sql:='select count(1) from HXC_RET_PA_LATEST_DETAILS 
											where Application_Set_Id is null
											and time_building_block_id in 
											(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
											and parent_building_block_id in 
											(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
											and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))';
											execute immediate v_sql into v_rows;									
										if v_rows>0 then
											l_o('<div class="divwarn" id="sigr8"><img class="warn_ico"><span class="sectionorange">Warning: </span>Application_set_id is null in one or more active record(s).<br></div>');
											:w3:=:w3+1;
										end if;
								end if;
					end if;
					
					
					select count(1) into v_rows from dba_tables where table_name='HXC_RET_PAY_LATEST_DETAILS';
					if v_rows>0 then
																
								sqlTxt := 'select * from HXC_RET_PAY_LATEST_DETAILS where time_building_block_id in '||p_tbbs;
								run_sql('HXC_RET_PAY_LATEST_DETAILS', sqltxt);
								-- check if there are 2 resource_id
								v_sql:='select count(1) from HXC_RET_PAY_LATEST_DETAILS where time_building_block_id in '||p_tbbs||' and resource_id <> (''&&4'')';
									  execute immediate v_sql into v_rows;
									  if v_rows>0 then
											:e3:=:e3+1;
											l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
									  end if;
								
								l_o('<div class="divok">');
								-- BEE batches
								select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='BATCH_ID' and TABLE_NAME='HXC_RET_PAY_LATEST_DETAILS';
								if v_rows>0 then
										v_cursorid := DBMS_SQL.OPEN_CURSOR;

										v_sql := 'select distinct batch_name from pay_batch_headers where batch_id in
																				(select distinct batch_id from HXC_RET_PAY_LATEST_DETAILS
																				where time_building_block_id in 
																				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
																				and parent_building_block_id in 
																				(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
																				and parent_building_block_id in 
																				(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
																				and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))
																				and batch_id is not null)
																				and batch_name is not null';


										 --Parse the query.
										 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
										 v_rows:=0;

										 --Define output columns
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_column, 30);

										 --Execute dynamic sql
										 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);
										 
										 LOOP
											  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											  END IF;
								
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_column);
											  if v_rows=0 then
													l_o(' This timecard is included in the following BEE Batch(es): ');
											  else
													l_o('; ');
											  end if;
											  l_o('<span class="sectionblue">'||v_column||'</span>');								  
											  v_rows:=1;

										 END LOOP;
										 if v_rows=1 then
												l_o('<br>');
										 end if;										

										 DBMS_SQL.CLOSE_CURSOR(v_cursorid);
								end if;
								
											
								-- Retro batches
								select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='RETRO_BATCH_ID' and TABLE_NAME='HXC_RET_PAY_LATEST_DETAILS';
								if v_rows>0 then
											v_cursorid := DBMS_SQL.OPEN_CURSOR;

											 v_sql := 'select distinct batch_name from pay_batch_headers where batch_id in
																					(select distinct retro_batch_id from HXC_RET_PAY_LATEST_DETAILS
																					where time_building_block_id in 
																					(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
																					and parent_building_block_id in 
																					(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
																					and parent_building_block_id in 
																					(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
																					and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))
																					and retro_batch_id is not null)
																					and batch_name is not null';


											 --Parse the query.
											 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
											 v_rows:=0;

											 --Define output columns
											 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_column, 30);

											 --Execute dynamic sql
											 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);
											 
											 
											 LOOP
												  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
													   exit;
												  END IF;
									
												  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_column);
												  if v_rows=0 then
														l_o(' This timecard is included in the following Retro Batch(es): ');
												  else
														l_o('; ');
												  end if;
												  l_o('<span class="sectionblue">'||v_column||'</span>');								  
												  v_rows:=1;

											 END LOOP;
											 if v_rows=1 then
												l_o('<br>');
											 end if;
											
											 DBMS_SQL.CLOSE_CURSOR(v_cursorid);
								end if; 

				
								-- HXT batches
								select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='HXT_BATCH_ID' and TABLE_NAME='HXC_RET_PAY_LATEST_DETAILS';
								if v_rows>0 then
											v_cursorid := DBMS_SQL.OPEN_CURSOR;

											v_sql := 'select distinct batch_name from pay_batch_headers where batch_id in
																					(select distinct Hxt_Batch_Id from HXC_RET_PAY_LATEST_DETAILS
																					where time_building_block_id in 
																					(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = ''DETAIL'' 
																					and parent_building_block_id in 
																					(select time_building_block_id from hxc_time_building_blocks where scope = ''DAY'' 
																					and parent_building_block_id in 
																					(select time_building_block_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
																					and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))))
																					and Hxt_Batch_Id is not null)
																					and batch_name is not null';


											 --Parse the query.
											 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
											 v_rows:=0;

											 --Define output columns
											 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_column, 30);

											 --Execute dynamic sql
											 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);
											 
											 
											 LOOP
												  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
													   exit;
												  END IF;
									
												  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_column);
												  if v_rows=0 then
														l_o(' This timecard is included in the following HXT Batch(es): ');
												  else
														l_o('; ');
												  end if;
												  l_o('<span class="sectionblue">'||v_column||'</span>');								  
												  v_rows:=1;

											 END LOOP;
											 if v_rows=1 then
												l_o('<br>');
											 end if;
											

											 DBMS_SQL.CLOSE_CURSOR(v_cursorid);
								end if;
								
								l_o('</div>');			
					end if;
	
			  end if;

			if p_ar is null then 
				select count(1) into v_rows from dba_tables where table_name='HXC_DEP_TRANSACTION_DETAILS';
				if v_rows>0 then
					  sqlTxt := 'select * from HXC_DEP_TRANSACTION_DETAILS'||l_ar||' where time_building_block_id in '||p_tbbs;
					  run_sql('HXC_DEP_TRANSACTION_DETAILS'||l_ar, sqltxt);
					  v_sql:='select count(1) from HXC_DEP_TRANSACTION_DETAILS'||l_ar||' where time_building_block_id in '||p_tbbs ||' and upper(status)=''ERROR''';
					  execute immediate v_sql into v_rows;
					  if v_rows>0 then
							:e3:=:e3+1;
							l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> Errors encoutered by the Timecard Deposit Process, please check the above table.</div>');	
					  end if;
				end if;
			end if;

			
				select count(1) into v_rows from dba_tables where table_name='HXC_DEP_TRANSACTIONS';
				if v_rows>0 then
					  sqlTxt := 'select * from HXC_DEP_TRANSACTIONS'||l_ar||' where transaction_id in (select transaction_id from HXC_DEP_TRANSACTION_DETAILS where time_building_block_id in '||p_tbbs||'
																								   union
																								   select transaction_id from HXC_DEP_TXN_DETAILS_AR where time_building_block_id in '||p_tbbs||'
																								  ) order by transaction_date';
					  run_sql('HXC_DEP_TRANSACTIONS'||l_ar, sqltxt);
					  v_sql:='select count(1) from HXC_DEP_TRANSACTIONS'||l_ar||' where transaction_id in (select transaction_id from HXC_DEP_TRANSACTION_DETAILS where time_building_block_id in '||p_tbbs||'
																								   union
																								   select transaction_id from HXC_DEP_TXN_DETAILS_AR where time_building_block_id in '||p_tbbs||'
																								  )  and upper(status)=''ERROR''';
					  execute immediate v_sql into v_rows;
					  if v_rows>0 then
							:e3:=:e3+1;
							l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> Errors encoutered by the Timecard Deposit Process, please check the above table.</div>');	
					  end if;
				end if;
			
			  v_sql:='select count(1) from 	HXC_TRANSACTION_DETAILS'||l_ar||' where time_building_block_id in '||p_tbbs;
			  execute immediate v_sql into v_rows;
			  if v_rows<101 then
				  sqlTxt := 'select * from HXC_TRANSACTION_DETAILS'||l_ar||' where time_building_block_id in '||p_tbbs;
				  run_sql('HXC_TRANSACTION_DETAILS'||l_ar, sqltxt);
			  else
			     sqlTxt := 'select * from HXC_TRANSACTION_DETAILS'||l_ar||' where time_building_block_id in '||p_tbbs||' and ROWID IN (SELECT rowid FROM(SELECT rowid, status, ROW_NUMBER() OVER (PARTITION BY status order by rowid) rc FROM HXC_TRANSACTION_DETAILS '||l_ar||' where time_building_block_id in '||p_tbbs||' ) where rc<=20)';
				 run_sql('HXC_TRANSACTION_DETAILS'||l_ar, sqltxt);
				 l_o('There are '||v_rows||' rows available. You will see only first 20 rows for each status.<br>');
			  end if;
			 
			  select count(1) into v_rows from HXC_TRANSACTION_DETAILS 
				where time_building_block_id in 
				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))
				and upper(status) like '%ERROR%';
				
				if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> The following transactions have errors:<br>');
					open c_HXC_TRANSACTION_DETAILS;
					loop
							fetch c_HXC_TRANSACTION_DETAILS into v_Time_Building_Block_Id , v_Exception_Description;
							EXIT WHEN  c_HXC_TRANSACTION_DETAILS%NOTFOUND;
							l_o('<Time_Building_Block_Id:  <span class="sectionblue">'||v_Time_Building_Block_Id);
							l_o('</span> with exception: <span class="sectionblue">');
							l_o(v_Exception_Description||'</span><br>');
					end loop;
					close c_HXC_TRANSACTION_DETAILS;
					l_o('</div>');
				end if;	
			 

			  sqlTxt := 'select * from HXC_TRANSACTIONS'||l_ar||' where transaction_id in (select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in '||p_tbbs||'
																						   union
																						   select transaction_id from HXC_TRANSACTION_DETAILS_AR where time_building_block_id in '||p_tbbs||'
																						  ) order by transaction_date';
			  run_sql('HXC_TRANSACTIONS'||l_ar, sqltxt);
			  -- HXC_TRANSACTIONS
			  select count(1) into v_rows from HXC_TRANSACTIONS 
				where type='RETRIEVAL' and transaction_id in 
				(select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in 
				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'DETAIL' 
				and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'DAY' 
				and parent_building_block_id in (select time_building_block_id 
				from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))));
			 if v_rows=0 then
				l_o('<div class="divok"> This timecard was never transferred to any application.</div>');
			 else
				l_o('<div class="divok">');
				open c_HXC_TRANSACTIONS;
					loop
							fetch c_HXC_TRANSACTIONS into v_creation_date,v_status_trans,v_transaction_code,v_ex_desc_trans;
							EXIT WHEN  c_HXC_TRANSACTIONS%NOTFOUND;
							l_o(' Transfer Date:  <span class="sectionblue">'||to_char(v_creation_date,'DD-Mon-YYYY HH24:MI:SS'));							
							l_o('</span> | Transfer Status: <span class="sectionblue">'||v_status_trans);
							l_o('</span> | Transaction Code: <span class="sectionblue">'||v_transaction_code||'</span>');
							if v_ex_desc_trans is not null then
								l_o(' | Transfer Message: <span class="sectionblue">'||v_ex_desc_trans||'</span>');
							end if;
							l_o('<br>');
					end loop;
					close c_HXC_TRANSACTIONS;
					l_o('</div>');					
			 end if;
			 l_o('<div class="divok"> For information on the recipient application please refer to section ');
			 l_o('<a href="#HXC_APP_PERIOD_SUMMARY">HXC_APP_PERIOD_SUMMARY</a></div><br>');
		end show_trx_data;

		
		begin
		
		l_o('<div id="page3" style="display: none;">');
		l_o('<a name="hxc"></a><div class="divSection"><div class="divSectionTitle">');
		l_o('<div class="left"  id="hxc" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">HXC Timecard (Self Service/Timekeeper/API): '); 
		l_o('</div></div><br>');
			
		:n := dbms_utility.get_time;
		
		if test_person then
		  if test_timecard then

		if l_param1 = 'HXC_TC_AR' then
		  l_show_ar := true;
		end if;

		l_query1 := build_query1;
		if l_show_ar then
		  l_query1 := l_query1 || ' UNION '||build_query1('AR');
		end if;

		execute immediate l_query1 bulk collect into TBB;

		l_tbb_tim := build_tbbs(TBB, 'TIMECARD');
		l_tbb_day := build_tbbs(TBB, 'DAY');
		l_tbb_det := build_tbbs(TBB, 'DETAIL');
		l_tbb_app := build_tbbs(TBB, 'APPLICATION_PERIOD');
		l_tbb_tem := build_tbbs(TBB, 'TIMECARD_TEMPLATE');
		
		
		l_apps := build_apps;
		
		l_o('<div class="divItem"><div class="divItemTitle">In This Section</div>');
			l_o('<table border="0" width="90%" align="center" cellspacing="0" cellpadding="0"><tr><td class="toctable">');
			l_o('<a href="#hxc1">Timecard details</a> <br>');	  
			l_o('<a href="#hxc2">Time Store</a> <br>');
			if v_mobile then
			l_o('<a href="#hxc10">Data from Mobile App</a> <br>');
			end if;
			l_o('<a href="#hxc3">Timecard Related Setup</a> <br>');
			
			l_o('<a href="#hxc4">Workflow</a> <br></td><td class="toctable">');
			l_o('<a href="#hxc5">Person</a> <br>');
			if l_apps like '%PROJECTS%' then
			l_o('<a href="#hxc6">Projects</a> <br>');
			end if;
			if l_apps like '%PAYROLL%' or l_apps like '%HUMAN RESOURCES%' then
			l_o('<a href="#hxc7">HR / Payroll</a> <br>');
			end if;
			l_o('<a href="#hxc8">Data Integrity Tests</a> <br>');
			l_o('<a href="#hxc9">Past Timecards</a> <br>');			  
			  l_o('</td></tr></table>');
			l_o('</div></div><br>');
			
		l_o('<br><div class="divSection">');
		l_o('<a name="hxc1"></a><div class="divSectionTitle">Timecard Details</div><br>');
		
		-- Header for HXC TC
		l_o('<div class="divok">');
		l_o('# Timecard for person: <span class="sectionblue">'||l_param2||'</span>');
		
		select * into v_person_name from (select full_name from PER_ALL_PEOPLE_F where person_id = '&&4' order by 1 desc)
		where rownum<2;
		l_o(' - <span class="sectionblue">"'|| v_person_name||'"</span><br>');
		l_o('# Start date: <span class="sectionblue">'||l_param3||'</span><br>');
		
		v_date_pref := to_date('&&5');
		
		begin
		hxc_preference_evaluation.resource_preferences(p_resource_id => '&4',
															p_start_evaluation_date  => v_date_pref,
															p_end_evaluation_date    => v_date_pref,
															p_pref_table  => l_pref_table);
		IF l_pref_table.COUNT > 0
							 THEN
								FOR i IN l_pref_table.FIRST..l_pref_table.LAST
								LOOP
								   if l_pref_table(i).preference_code = 'TC_W_RULES_EVALUATION' then 
											v_type_timecard:=l_pref_table(i).attribute1;									
								   end if;
								END LOOP;
		END IF;
	
		if upper(v_type_timecard) like '%Y%' then
				l_o('# <span class="sectionblue">This is an OTLR Timecard.</span>');
		else
				l_o('# <span class="sectionblue">This is a Non-OTLR Timecard.</span>');
		end if;
		EXCEPTION
		when others then
		  l_o('<br>'||sqlerrm ||' occurred in test');
		  l_o('<br>Procedure hxc_preference_evaluation.resource_preferences failed for this person');
		  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1 <br>');
		end;	
		
		select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD_TEMPLATE'
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5');
		if v_rows>0 then
				l_o('<br># <span class="sectionblue">This Timecard was created using a Template.</span>');
		end if;
		
		l_o('<br>');
		

		
		select count(1) into v_rows
			from per_all_people_f, fnd_user
			where sysdate between effective_start_date and effective_end_date
			and user_id in (select distinct created_by
							 from HXC_TIME_BUILDING_BLOCKS
							where scope = 'TIMECARD'
							  and resource_id = ('&&4')
							  and trunc(start_time) = to_date('&&5'))
			and employee_id = person_id ;		
		if v_rows>0 then   
				l_o('# Timecard created by Person: <span class="sectionblue">');
				v_rows:=0;
				open c_timecard_created;
				loop
					  fetch c_timecard_created into v_person_name;
					  EXIT WHEN  c_timecard_created%NOTFOUND;
					  if v_rows=1 then
						l_o(' ; ');
					  end if;
					  l_o('"'||v_person_name||'"');
					  v_rows:=1;			  
				end loop;
				close c_timecard_created;
				l_o('</span><br>');		
		end if;
		
		select count(1) into v_rows
				from per_all_people_f, fnd_user
				where sysdate between effective_start_date and effective_end_date
			    and user_id in (select distinct last_updated_by
							 from HXC_TIME_BUILDING_BLOCKS
							where scope = 'TIMECARD'
							  and resource_id = ('&&4')
							  and trunc(start_time) = to_date('&&5'))
			and employee_id = person_id ;
		if v_rows>0 then
				l_o('# Timecard updated by Person:<span class="sectionblue">');
				v_rows:=0;
				open c_timecard_updated;
				loop
					  fetch c_timecard_updated into v_person_name;
					  EXIT WHEN  c_timecard_updated%NOTFOUND;
					  if v_rows=1 then
						l_o(' ; ');
					  end if;
					  l_o('"'||v_person_name||'"');
					  v_rows:=1;			  
				end loop;
				close c_timecard_updated;
				l_o('</span>');
		end if;
		l_o('</div>');
		
		if l_show_ar then
			:w3:=:w3+1;
			l_o('<div class="divwarn">This timecard is Archived.</div>');
		end if;
		
		l_o('</div><br/>');
		
	
	if not l_show_ar then	
		-- Time Store	
	
		l_o('<br><div class="divSection">');
		l_o('<a name="hxc2"></a><div class="divSectionTitle">Time Store</div><br>');

		show_tbb_data(l_tbb_tim, null, 'Timecard');
		show_tbb_data(l_tbb_day, null, 'Day');
		show_tbb_data(l_tbb_det, null, 'Detail');
		show_tbb_data(l_tbb_app, null, 'Application_Period');
		show_tbb_data(l_tbb_tem, null, 'Timecard Template');
		

		-- HXC_LOCKS
		sqlTxt := 'select * from hxc_locks where resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')
				   union
				   select * from hxc_locks where time_building_block_id in '||l_tbb_tim||'
				   union
				   select * from hxc_locks where time_building_block_id in '||l_tbb_day||'
				   union
				   select * from hxc_locks where time_building_block_id in '||l_tbb_det||'
				   union
				   select * from hxc_locks where time_building_block_id in '||l_tbb_app;
		run_sql('HXC_LOCKS', sqltxt);
				
		open c_hxc_locks;
		loop
				fetch c_hxc_locks into v_lock_date,v_locker_type_id;
				EXIT WHEN  c_hxc_locks%NOTFOUND;
				:w3:=:w3+1;
				l_o('<div class="divwarn" id="sigr9"><img class="warn_ico"><span class="sectionorange">Warning: </span>This timecard was locked since </span><span class="sectionblue">'||v_lock_date);
				l_o('</span> by ');
				select count(1) into v_rows from hxc_locker_types where locker_type_id = v_locker_type_id;
				if v_rows=1 then
						select locker_type||' - '||process_type into v_locker from hxc_locker_types where locker_type_id = v_locker_type_id;
						l_o('<span class="sectionblue">'||v_locker||'</span><br>');
				end if;
				 l_o('</div>'); 
		end loop;
		close c_hxc_locks;
		
	

		
		-- HXC_TIMECARD_SUMMARY
		sqlTxt := 'select * from HXC_TIMECARD_SUMMARY where timecard_id in '||l_tbb_tim;
		run_sql('HXC_TIMECARD_SUMMARY', sqltxt);
		v_sql:='select count(1) from HXC_TIMECARD_SUMMARY where timecard_id in '||l_tbb_tim||' and resource_id <> (''&&4'')';
			  execute immediate v_sql into v_rows;
			  if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
			  end if;
		
		select count(1) into v_rows from HXC_TIMECARD_SUMMARY 
		where timecard_id in 
		(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD'
		and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'));
		if v_rows>1 then
				:e3:=:e3+1;
				l_o('<div class="diverr" id="sigr3"><img class="error_ico"><font color="red">Error:</font> There are duplicate timecards for this period, please contact Oracle Support to fix the issue.</div>');
		end if;
		if v_rows>0 then
			v_sql:= 'select max(trunc(stop_time)-trunc(start_time)) from HXC_TIMECARD_SUMMARY where timecard_id in '||l_tbb_tim;
			execute immediate v_sql into v_time_summary;
			select count(1) into v_rows from dba_tab_columns where TABLE_NAME='HXC_TIMECARD_SUMMARY' and COLUMN_NAME='TRANSFERRED_TO';
			l_o('<div class="divok">');
			open c_HXC_TIMECARD_SUMMARY;
			loop
									fetch c_HXC_TIMECARD_SUMMARY into v_approval_status,v_recorded_hours,v_approval_item_type,v_approval_item_key,v_rowid;
									EXIT WHEN  c_HXC_TIMECARD_SUMMARY%NOTFOUND;
									l_o(' Timecard Current Approval Status is: <span class="sectionblue">'||v_approval_status||'</span><br>');
									l_o(' Timecard Total Hours(at summary level): <span class="sectionblue">'||v_recorded_hours||'</span><br>');
									if v_rows=1 then
										v_sql:='select Transferred_To from HXC_TIMECARD_SUMMARY where rowid='''||v_rowid||'''';
										execute immediate v_sql into v_Transferred_To;
										if v_Transferred_To is not null then
											l_o(' This timecard was transferred to:<span class="sectionblue">'||v_Transferred_To ||'</span><br>');
										end if;
									end if;
									if v_Approval_Item_Type is not null then
										l_o(' Workflow Item Type: <span class="sectionblue">'||v_Approval_Item_Type ||'</span><br>');
									end if;
									if v_Approval_Item_Key is not null then
										l_o(' Workflow Item Key: <span class="sectionblue">'||v_Approval_Item_Key ||'</span><br>');										
									end if;
									
			end loop;
			close c_HXC_TIMECARD_SUMMARY;
			l_o('</div>');
				
		end if;
		
		
		show_app_data(l_tbb_tim, null);
		show_trx_data(l_tbb_det, null);
		
		
	end if;
	
	if l_show_ar then
		  l_o('<br><div class="divSection">');
		  l_o('<div class="divSectionTitle">Archive</div><br>');
		  show_tbb_data(l_tbb_tim, 'AR', 'Timecard');
		  show_tbb_data(l_tbb_day, 'AR', 'Day');
		  show_tbb_data(l_tbb_det, 'AR', 'Detail');
		  show_tbb_data(l_tbb_app, 'AR', 'Application_Period');
		  show_app_data(l_tbb_tim, 'AR');
		  show_trx_data(l_tbb_det, 'AR');
		  l_o('</div><br/>');
	end if;

	if l_show_ar then
		  null;
	else

		  sqlTxt := 'select * from HXC_RETRIEVAL_RANGES where transaction_id in (select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in '||l_tbb_det||')';
		  run_sql('HXC_RETRIEVAL_RANGES', sqltxt);

		  sqlTxt := 'select * from HXC_RETRIEVAL_RANGE_RESOURCES where retrieval_range_id in (select retrieval_range_id from hxc_retrieval_ranges where transaction_id in (select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in '||l_tbb_det||')) and resource_id = (''&&4'')';
		  run_sql('HXC_RETRIEVAL_RANGE_RESOURCES', sqltxt);
		 
		  sqlTxt := 'select * from HXC_DEPOSIT_PROCESSES where deposit_process_id in (select transaction_process_id from hxc_transactions where type = ''DEPOSIT'' and transaction_id in (select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in '||l_tbb_det||'))';
		  run_sql('HXC_DEPOSIT_PROCESSES', sqltxt);

		  -- HXC_RETRIEVAL_PROCESSES
		  sqlTxt := 'select * from HXC_RETRIEVAL_PROCESSES where retrieval_process_id in (select transaction_process_id from hxc_transactions where type = ''RETRIEVAL'' and transaction_id in (select transaction_id from HXC_TRANSACTION_DETAILS where time_building_block_id in '||l_tbb_det||'))';
		  run_sql('HXC_RETRIEVAL_PROCESSES', sqltxt);
		  select count(1) into v_rows from HXC_RETRIEVAL_PROCESSES where 
				retrieval_process_id in 
				(select transaction_process_id from hxc_transactions where type = 'RETRIEVAL' 
				and transaction_id in 
				(select transaction_id from HXC_TRANSACTION_DETAILS 
				where time_building_block_id in 
				(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS 
				where scope = 'DETAIL' and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks 
				where scope = 'DAY' and parent_building_block_id in 
				(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'))))));
		  if v_rows>0 then
				  l_o('<div class="divok">');
				  l_o(' Retrieval Processes ran on this timecard:<br>');
				  open c_HXC_RETRIEVAL_PROCESSES;
					loop
											fetch c_HXC_RETRIEVAL_PROCESSES into v_Time_Recipient_Id,v_retrival_proc_name;
											EXIT WHEN  c_HXC_RETRIEVAL_PROCESSES%NOTFOUND;																				
											select count(1) into v_rows from hxc_time_recipients 
												where Time_Recipient_Id = v_Time_Recipient_Id;
											if v_rows=1 then
												l_o(' Application: <span class="sectionblue">');
												select name into v_time_rec_name from hxc_time_recipients 
													where Time_Recipient_Id = v_Time_Recipient_Id;
												l_o(v_time_rec_name||'</span> - ');
											end if;	
											l_o('Retrieval Process: <span class="sectionblue">'||v_retrival_proc_name ||'</span><br>');									
					end loop;
					close c_HXC_RETRIEVAL_PROCESSES;
					l_o('</div>');
		  end if;
		  l_o('</div><br/>');
		 		  
		-- ********** MOBILE **********
		if v_mobile then
		l_o('<div class="divSection">');
		l_o('<a name="hxc10"></a><div class="divSectionTitle">Data from Mobile App</div><br>');
		sqlTxt := 'select * from hxc_mob_transit_timecards where resource_id = (''&&4'') and trunc(tc_start_time) = to_date(''&&5'')';
		run_sql('HXC_MOB_TRANSIT_TIMECARDS', sqltxt);
		sqlTxt := 'select * from hxc_mob_transit_details where resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')';
		run_sql('HXC_MOB_TRANSIT_DETAILS', sqltxt);
		l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR></div>');
		end if;
		
		  l_o('<br><div class="divSection">');
		  l_o('<a name="hxc3"></a><div class="divSectionTitle">Timecard Related Setup</div><br>');		 
			
			
		  sqlTxt := 'select * from HXC_APPLICATION_SET_COMPS_V where application_set_id in (select application_set_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||')';
		  run_sql('HXC_APPLICATION_SET_COMPS_V', sqltxt);
		  
		  -- HXC_APPROVAL_STYLES
		  l_o('<a name="HXC_APPROVAL_STYLES"></a>');
		  sqlTxt := 'select * from HXC_APPROVAL_STYLES where approval_style_id in (select approval_style_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||')';
		  run_sql('HXC_APPROVAL_STYLES', sqltxt);  
		  l_o('<div class="divok"> Approval Style effective on this Timecard is: <span class="sectionblue">'|| v_approval_style||'</span></div> ');
		  select count(1) into v_rows from dba_tab_columns where COLUMN_NAME='RUN_RECIPIENT_EXTENSIONS' and TABLE_NAME='HXC_APPROVAL_STYLES';
		  if v_rows>0 then
				v_sql:='select count(1) from HXC_APPROVAL_STYLES where approval_style_id in 
					(select approval_style_id from hxc_time_building_blocks where scope = ''TIMECARD'' 			
					and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5'')
					and date_to=to_date(''31-DEC-4712''))
					and Run_Recipient_Extensions=''Y''';
				execute immediate v_sql into v_rows;
				if v_rows>0 then
					:w3:=:w3+1;
					l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>PA Client Extensions is turned ON, this will bypass the workflow and use your PA Extensions Code. ');
					l_o('If you are not using PA Client Extensions please uncheck the box "Enable Client Extensions" in your Approval Style: <span class="sectionblue">');
					v_cursorid := DBMS_SQL.OPEN_CURSOR;

					v_sql := 'select Run_Recipient_Extensions, name from HXC_APPROVAL_STYLES where approval_style_id in 
							(select approval_style_id from hxc_time_building_blocks where scope = ''TIMECARD'' 
							and Run_Recipient_Extensions=''Y''
							and resource_id = (''&&4'') and trunc(start_time) = to_date(''&&5''))';


										 --Parse the query.
										 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);
										 v_rows:=0;

										 --Define output columns
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_run_recipient, 22);
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 2, v_approval_name, 180);										 

										 --Execute dynamic sql
										 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

										 LOOP
											  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											  END IF;
								
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_run_recipient);
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,2,v_approval_name);
											  l_o(v_approval_name||' <br>');
						
										 END LOOP;
										 

										 DBMS_SQL.CLOSE_CURSOR(v_cursorid);	
					
					l_o('</span></div>');
			end if;
		  end if;
		  
		  -- HXC_APPROVAL_COMPS
		  select count(1) into v_rows from HXC_APPROVAL_COMPS where 
				approval_style_id in 
				(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
				and resource_id = ('&&4') and trunc(start_time) = to_date('&&5'));
		  if v_rows<=50 then		
			sqlTxt := 'select * from HXC_APPROVAL_COMPS where approval_style_id in (select approval_style_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||')';		  
			run_sql('HXC_APPROVAL_COMPS', sqltxt);
		  else
			sqlTxt := 'select APPROVAL_MECHANISM, count(1) Count_of_records from HXC_APPROVAL_COMPS 
			where approval_style_id in (select approval_style_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||') group by APPROVAL_MECHANISM';
			run_sql('HXC_APPROVAL_COMPS', sqltxt);
			for app_rec in c_HXC_APPROVAL_COMPS_app loop
				sqlTxt := 'select * from HXC_APPROVAL_COMPS where APPROVAL_MECHANISM='''|| app_rec.APPROVAL_MECHANISM||''' and  approval_style_id in (select approval_style_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||') and rownum=1';		  
				run_sql('One example of HXC_APPROVAL_COMPS for '||app_rec.APPROVAL_MECHANISM, sqltxt);
			end loop;
		  end if;	  
		    
		  
		  if v_rows>0 then
		  
				  select count(1) into v_rows from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
									and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
									and date_to=to_date('31-DEC-4712');
				  if v_rows=1 then
					  select Approval_Style_Id into v_Approval_Style_Id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD' 
										and resource_id = ('&&4') and trunc(start_time) = to_date('&&5') 
										and date_to=to_date('31-DEC-4712');
					  l_o('<div class="divok"> The currently effective Approval Style ID on this timecard is: <span class="sectionblue">'|| v_Approval_Style_Id||'</span></div>'); 
				  end if;
		  
		  
				  open c_HXC_APPROVAL_COMPS;
						loop
								fetch c_HXC_APPROVAL_COMPS into v_approval_id, v_approval_mec;
								EXIT WHEN  c_HXC_APPROVAL_COMPS%NOTFOUND;
								if v_approval_mec like '%WORKFLOW%' then
									l_o('<div class="diverr"> Custom Workflow. You have these Custom workflow for approval comp id: <span class="sectionblue">'||v_approval_id||' </span></div><br>');																		
								else
									l_o('<div class="diverr" id="sigs1"> Custom Formula. You have these Custom formula for approval comp id: <span class="sectionblue">'||v_approval_id||' </span></div><br>');
								end if;
						end loop;
				  close c_HXC_APPROVAL_COMPS;
		  
				  select count(1) into v_rows from HXC_APPROVAL_COMPS where 
						approval_style_id in 
						(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
						and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
						and date_to=to_date('31-DEC-4712'))
						and Approval_Mechanism like '%PROJECT_MANAGER%';
				  if v_rows>0 then
						open c_PROJECT_MANAGER;
						loop
								fetch c_PROJECT_MANAGER into v_Attribute1;
								EXIT WHEN  c_PROJECT_MANAGER%NOTFOUND;
								select count(1) into v_rows
										from PA_PROJECT_PLAYERS prj, per_all_people_f pep, per_person_types ptp, PA_PROJECTS_all pap 
										where project_role_type = 'PROJECT MANAGER'
										and prj.project_id = v_Attribute1
										and sysdate between pep.effective_start_date and pep.effective_end_date
										and pep.person_id = prj.person_id
										and ( (sysdate between prj.start_date_active and prj.end_date_active) OR (sysdate >= prj.start_date_active and prj.end_date_active is null))
										and pep.person_type_id = ptp.person_type_id
										and prj.project_id = pap.project_id;
								if v_rows=1 then
									select pap.segment1, pep.full_name,ptp.system_person_type into v_segment1, v_person_name, v_system_person_type
										from PA_PROJECT_PLAYERS prj, per_all_people_f pep, per_person_types ptp, PA_PROJECTS_all pap 
										where project_role_type = 'PROJECT MANAGER'
										and prj.project_id = v_Attribute1
										and sysdate between pep.effective_start_date and pep.effective_end_date
										and pep.person_id = prj.person_id
										and ( (sysdate between prj.start_date_active and prj.end_date_active) OR (sysdate >= prj.start_date_active and prj.end_date_active is null))
										and pep.person_type_id = ptp.person_type_id
										and prj.project_id = pap.project_id;
									l_o('<div class="divok"> Project ID: </span><span class="sectionblue">'||v_Attribute1);
									l_o('</span> - <span class="sectionblue">'|| v_segment1 );
									l_o('</span>   |     Project Manager: <span class="sectionblue">' || v_person_name);
									l_o('</span>  |     Project Manager Status: <span class="sectionblue">' || v_system_person_type);
									l_o('</span>.</div><br>');
									if v_system_person_type not in ('CWK', 'EMP', 'EMP_APL') then
											:e3:=:e3+1;
											l_o('<div class="diverr" id="siga2"><img class="error_ico"><font color="red">Error:</font> Project <span class="sectionblue">' || v_segment1);
											l_o('</span> ''s Project Manager is not active.</div><br>');
									end if;
								elsif v_rows=0 then
									:e3:=:e3+1;
									l_o('<div class="diverr" id="siga3"><img class="error_ico"><font color="red">Error:</font> Project ID: <span class="sectionblue">'||v_Attribute1||'</span>');
									select count(1) into v_rows from pa_projects_all where project_id = v_Attribute1;
									if v_rows=1 then
										select name into v_project_name from pa_projects_all where project_id = v_Attribute1;
										l_o(' - <span class="sectionblue">'|| v_project_name||'</span>');
									end if;
									l_o(' doesn''t have a Project Manager assigned.</div><br>');
									
								end if;
						end loop;
						close c_PROJECT_MANAGER;
				  end if;
		

				select count(1) into v_rows from HXC_APPROVAL_COMPS where 
						approval_style_id in 
						(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
						and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
						and date_to=to_date('31-DEC-4712'))
						and Approval_Mechanism like '%HR_SUPERVISOR%';
				 if v_rows>0 then
						select count(supervisor_id) into v_rows from per_all_assignments_f where person_id = ('&&4') and sysdate between effective_start_date and effective_end_date and primary_flag = 'Y' and assignment_type IN ('E', 'C');
						if v_rows=0 then
							:e3:=:e3+1;
							l_o('<div class="diverr" id="siga4"><img class="error_ico"><font color="red">Error:</font> This employee doesn''t not have a Supervisor assigned.</div><br>');
						elsif v_rows=1 then
							select supervisor_id into v_supervisor_id from per_all_assignments_f where person_id = ('&&4') and sysdate between effective_start_date and effective_end_date and primary_flag = 'Y' and assignment_type IN ('E', 'C');
							if v_supervisor_id is null then
								:e3:=:e3+1;
								l_o('<div class="diverr" id="siga4"><img class="error_ico"><font color="red">Error:</font> This employee doesn''t not have a Supervisor assigned.</div><br>');
							else				
								select count(distinct typ.system_person_type) into v_rows from per_person_types typ, per_all_people_f pep where pep.person_type_id = typ.person_type_id 
								and sysdate between pep.effective_start_date and pep.effective_end_date 
								and pep.person_id = v_supervisor_id;
								if v_rows=1 then
									select distinct typ.system_person_type, pep.full_name into v_system_person_type, v_person_name  from per_person_types typ, per_all_people_f pep 
									where pep.person_type_id = typ.person_type_id 
									and sysdate between pep.effective_start_date 
									and pep.effective_end_date and pep.person_id = v_supervisor_id;								
									if v_system_person_type not in ('CWK', 'EMP', 'EMP_APL')  then
											l_o('<div class="diverr" id="siga5"><img class="error_ico"><font color="red">Error:</font> Employee''s Supervisor <span class="sectionblue">' || v_person_name);
											l_o('is not active.</div><br>');
											:e3:=:e3+1;
									end if;
								elsif v_rows=0 then
									l_o('<div class="diverr" id="siga4"><img class="error_ico"><font color="red">Error:</font> This employee doesn''t not have a Supervisor assigned.</div><br>');
									:e3:=:e3+1;
								end if;
							end if;
						end if;
							
				 end if;
		 		 		 
		end if; 
		
			
		
		sqlTxt := 'SELECT TIMEOUTS_ENABLED,
				NUMBER_RETRIES,
				APPROVER_TIMEOUT,
				PREPARER_TIMEOUT,
				ADMIN_TIMEOUT,
				ADMIN_ROLE,
				ERROR_ADMIN_ROLE,
				APPROVAL_STYLE_ID,
				NOTIFY_SUPERVISOR,
				NOTIFY_WORKER_ON_SUBMIT,
				NOTIFY_WORKER_ON_AA,
				NOTIFY_PREPARER_APPROVED,
				NOTIFY_PREPARER_REJECTED,
				NOTIFY_PREPARER_TRANSFER
				FROM hxc_approval_styles_v
				WHERE APPROVAL_STYLE_ID in (select approval_style_id from hxc_time_building_blocks where time_building_block_id in '||l_tbb_tim||')';
		run_sql('Approval Style Other Attributes', sqlTxt);
		
		sqlTxt := 'select * from PAY_ALL_PAYROLLS_F where payroll_id = (select payroll_id from per_all_assignments_f where sysdate between effective_start_date and effective_end_date and primary_flag=''Y'' and assignment_type IN (''E'', ''C'') and person_id = (''&&4''))';
		run_sql('PAY_ALL_PAYROLLS_F', sqltxt);
		
		sqlTxt := 'select * from pay_element_types_f where element_type_id in (select distinct to_number(substr(Attribute_Category, 11)) from HXC_TIME_ATTRIBUTES where substr(Attribute_Category, 1, 7) = ''ELEMENT'' and   time_attribute_id in (select time_attribute_id from hxc_time_attribute_usages  where time_building_block_id in '||l_tbb_det||'))';
		run_sql('PAY_ELEMENT_TYPE_ID', sqltxt);		
	
		sqlTxt := 'select * from PAY_ELEMENT_CLASSIFICATIONS where classification_id in (select classification_id  from pay_element_types_f  where element_type_id in (select distinct to_number(substr(Attribute_Category, 11)) from HXC_TIME_ATTRIBUTES  where substr(Attribute_Category, 1, 7) = ''ELEMENT'' and Time_Attribute_Id in (select time_attribute_id from hxc_time_attribute_usages  where time_building_block_id in '||l_tbb_det||')))';
        run_sql('PAY_ELEMENT_CLASSIFICATIONS', sqltxt);
		
		sqlTxt := 'select * from PAY_INPUT_VALUES_F where element_type_id in (select distinct to_number(substr(Attribute_Category, 11))  from HXC_TIME_ATTRIBUTES  where substr(Attribute_Category, 1, 7) = ''ELEMENT''  and Time_Attribute_Id in (select time_attribute_id from hxc_time_attribute_usages  where time_building_block_id in '||l_tbb_det||'))'; 
        run_sql('PAY_INPUT_VALUES_F', sqltxt);

		

		l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		
		l_o('</div><br/>');
		
		-- ********** WORKFLOW **********
		l_o('<div class="divSection">');
		l_o('<a name="hxc4"></a><div class="divSectionTitle">Workflow</div><br>');

		sqlTxt := '
			select item_type
			,item_key
			,name
			,text_value
			,number_value
			,date_value
			,security_group_id
			from WF_ITEM_ATTRIBUTE_VALUES
			where item_type = ''HXCEMP''
			and name = ''TC_BLD_BLK_ID''
			and number_value in '||l_tbb_tim||'
			order by item_key';
		run_sql('WF_ITEM_ATTRIBUTE_VALUES', sqltxt);

		sqlTxt := '
			select *
			from WF_ITEMS
			where (item_type, item_key) in (select item_type, item_key
											  from WF_ITEM_ATTRIBUTE_VALUES
											 where item_type = ''HXCEMP''
											   and name = ''TC_BLD_BLK_ID''
											   and number_value in '||l_tbb_tim||'
											)
			order by item_key';
		run_sql('WF_ITEMS', sqltxt);
		sqlTxt := '
			select count(1)
			from WF_ITEMS
			where (item_type, item_key) in (select item_type, item_key
											  from WF_ITEM_ATTRIBUTE_VALUES
											 where item_type = ''HXCEMP''
											   and name = ''TC_BLD_BLK_ID''
											   and number_value in '||l_tbb_tim||'
											)
			and (Root_Activity like ''%CUSTOM%'' or Root_Activity like ''%FORMULA%'' or Root_Activity like ''%XX%'') ';
		execute immediate sqlTxt into v_rows;
		if v_rows>0 then
			l_o('<div class="diverr" id="siga9"> The following appears to be custom objects found in workflow activities:<br>');
			v_cursorid := DBMS_SQL.OPEN_CURSOR;

										v_sql := 'select Root_Activity
												from WF_ITEMS
												where (item_type, item_key) in (select item_type, item_key
													  from WF_ITEM_ATTRIBUTE_VALUES
													 where item_type = ''HXCEMP''
													   and name = ''TC_BLD_BLK_ID''
													   and number_value in '||l_tbb_tim||'
													)
													order by item_key';
										 --Parse the query.
										 DBMS_SQL.PARSE(v_cursorid, v_sql, dbms_sql.native);										
										 --Define output columns
										 DBMS_SQL.DEFINE_COLUMN(v_cursorid, 1, v_custom_act, 50);									 
										 --Execute dynamic sql
										 v_dummy := DBMS_SQL.EXECUTE(v_cursorid);
										 LOOP
											  IF DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
												   exit;
											  END IF;								
											  DBMS_SQL.COLUMN_VALUE(v_cursorid,1,v_custom_act);											
											  l_o(v_custom_act||'<br>');						
										 END LOOP;								 

										 DBMS_SQL.CLOSE_CURSOR(v_cursorid);			
			l_o('</div><br>');			
		end if;

		-- WF_ITEM_ACTIVITY_STATUSES
		l_o(' <a name="WF_ITEM_ACTIVITY_STATUSES"></a>');
		sqlTxt := '
		select ias.item_type,
			   ias.item_key,
			   to_char(ias.begin_date, ''DD-MON-RR HH24:MI:SS'') begin_date,
			   to_char(ias.end_date, ''DD-MON-RR HH24:MI:SS'') end_date,
			   ap.name || ''/'' || pa.instance_label Activity,
			   ias.activity_status Status,
			   ias.activity_result_code Result,
			   ias.assigned_user assigned_user,
			   ias.notification_id,
			   ntf.status "Notification Status",
			   ias.Execution_Time,
			   ias.Error_Name,
			   ias.Error_Message,
			   ias.Error_Stack,
			   ias.action,
			   ias.performed_by
		  from wf_item_activity_statuses ias,
			   wf_process_activities     pa,
			   wf_activities             ac,
			   wf_activities             ap,
			   wf_items                  i,
			   wf_notifications          ntf
		 where (ias.item_type, ias.item_key) in 
			   (select item_type, item_key from WF_ITEM_ATTRIBUTE_VALUES
				 where item_type = ''HXCEMP''
				   and name = ''TC_BLD_BLK_ID''
				   and number_value in
					   (select time_building_block_id
						  from hxc_time_building_blocks
						 where scope = ''TIMECARD''
						   and resource_id = (''&&4'')
						   and trunc(start_time) = to_date(''&&5'')))		 
		   and ias.process_activity = pa.instance_id
		   and pa.activity_name = ac.name
		   and pa.activity_item_type = ac.item_type
		   and pa.process_name = ap.name
		   and pa.process_item_type = ap.item_type
		   and pa.process_version = ap.version
		   and i.item_type = ''HXCEMP''
		   and i.item_key = ias.item_key
		   and i.begin_date >= ac.begin_date
		   and i.begin_date < nvl(ac.end_date, i.begin_date + 1)
		   and ntf.notification_id(+) = ias.notification_id
		 order by ias.begin_date, ias.execution_time';
		run_sql('Activity Statuses', sqltxt);
		
		select count(1) into v_rows
			from wf_item_activity_statuses ias,
			wf_process_activities     pa,
			wf_activities             ac,
			wf_activities             ap,
			wf_items                  i
			where (ias.item_type, ias.item_key) in 
			(select item_type, item_key from WF_ITEM_ATTRIBUTE_VALUES where item_type = 'HXCEMP' and name = 'TC_BLD_BLK_ID'
			and number_value in 
			(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD'
			and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')))
			and (ap.name like '%CUSTOM%' or ap.name like '%FORMULA%' or ap.name like '%XX%' or pa.instance_label like '%CUSTOM%' or pa.instance_label like '%FORMULA%' or pa.instance_label like '%XX%')
			and ias.process_activity = pa.instance_id
			and pa.activity_name = ac.name
			and pa.activity_item_type = ac.item_type
			and pa.process_name = ap.name
			and pa.process_item_type = ap.item_type
			and pa.process_version = ap.version
			and i.item_type = 'HXCEMP'
			and i.item_key = ias.item_key
			and i.begin_date >= ac.begin_date
			and i.begin_date < nvl(ac.end_date, i.begin_date + 1);
		if v_rows>0 then
			l_o('<div class="diverr"> The following appears to be custom objects found in workflow activities:<br>');
			open c_Custom_Activities;
						loop
								fetch c_Custom_Activities into v_custom_act;
								EXIT WHEN  c_Custom_Activities%NOTFOUND;
								l_o(v_custom_act||'<br>');
						end loop;
				  close c_Custom_Activities;
			l_o('</div><br>');			
		end if;
		select count(Error_Message) into v_rows from WF_ITEM_ACTIVITY_STATUSES where 
			(item_type, item_key) in 
			(select item_type, item_key from WF_ITEM_ATTRIBUTE_VALUES where item_type = 'HXCEMP' and name = 'TC_BLD_BLK_ID'
			and number_value in 
			(select time_building_block_id from hxc_time_building_blocks where scope = 'TIMECARD'
			 and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')));
		if v_rows>0 then
			:e3:=:e3+1;
			l_o('<div class="diverr"> This timecard has workflow errors (please review above table ');
			l_o('<a href="#WF_ITEM_ACTIVITY_STATUSES"> for errors and error stacks</a>):<br>');	
			l_o('</div>');
		end if;
		
		
		sqlTxt := '
		select wn.notification_id,
				   wn.context,
				   wn.group_id,
				   wn.status,
				   wn.mail_status,
				   wn.message_type,
				   wn.message_name,
				   wn.access_key,
				   wn.priority,
				   wn.begin_date,
				   wn.end_date,
				   wn.due_date,
				   wn.callback,
				   wn.recipient_role,
				   wn.responder,
				   wn.original_recipient,
				   wn.from_user,
				   wn.to_user,
				   wn.subject
			  from wf_notifications wn, wf_item_activity_statuses wias
			 where wn.group_id = wias.notification_id
			   and wias.item_type in
				   (select distinct item_type
					  from WF_ITEM_ATTRIBUTE_VALUES
					 where item_type = ''HXCEMP''
					   and name = ''TC_BLD_BLK_ID''
					   and number_value in
						   (select time_building_block_id
							  from hxc_time_building_blocks
							 where scope = ''TIMECARD''
							   and resource_id = (''&&4'')
							   and trunc(start_time) = to_date(''&&5'')))
			   and wias.item_key in
				   (select distinct item_key
					  from WF_ITEM_ATTRIBUTE_VALUES
					 where item_type = ''HXCEMP''
					   and name = ''TC_BLD_BLK_ID''
					   and number_value in
						   (select time_building_block_id
							  from hxc_time_building_blocks
							 where scope = ''TIMECARD''
							   and resource_id = (''&&4'')
							   and trunc(start_time) = to_date(''&&5'')))
			 order by wn.begin_date asc';
		run_sql('Notifications', sqltxt);		
		
		l_o('<br><A   href="#top"><font size="-1">Back to Top</font></A><BR>');
		
		l_o('</div><br/>');
		
	end if;
	
		-- ********** PERSON **********
		
		
		l_o('<div class="divSection">');
		l_o('<a name="hxc5"></a><div class="divSectionTitle">Person</div><br>');

		  sqlTxt := 'select Person_Id, Effective_Start_Date, Effective_End_Date, Business_Group_Id, Person_Type_Id, Last_Name, Start_Date, Applicant_Number, Current_Applicant_Flag, Current_Emp_Or_Apl_Flag, Current_Employee_Flag, 
		  Employee_Number, First_Name Full_Name, Last_Update_Date, Last_Updated_By, Last_Update_Login, Created_By, Creation_Date, Original_Date_Of_Hire, Party_Id, Global_Name, Local_Name 
		  from PER_ALL_PEOPLE_F where person_id = (''&&4'') order by effective_start_date';
		   run_sql('PER_ALL_PEOPLE_F ', sqltxt);		  

		--  sqlTxt := 'select * from PER_PERSON_TYPE_USAGES_F where person_id = (''&&4'')';
		--  run_sql('PER_PERSON_TYPE_USAGES_F', sqltxt);

		  -- PER_PERSON_TYPES
		  sqlTxt := 'select * from PER_PERSON_TYPES where person_type_id in (select person_type_id from PER_ALL_PEOPLE_F where person_id = (''&&4''))';
		  run_sql('PER_PERSON_TYPES', sqltxt);
		  
		  select count(1) into v_rows from PER_PERSON_TYPES 
			where person_type_id in (select person_type_id from PER_ALL_PEOPLE_F where person_id = ('&&4') 
			and sysdate between effective_start_date and effective_end_date)
			and upper(System_Person_Type) not in ('CWK', 'EMP', 'EMP_APL','OTHER');
		  if v_rows>0 then
				:e3:=:e3+1;
				l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> Timecard Owner might not be an active person.</div><br>');
		  end if;
			
		  sqlTxt := 'select * from PER_PERIODS_OF_SERVICE where person_id = (''&&4'')';
		  run_sql('PER_PERIODS_OF_SERVICE', sqltxt);

		  -- PER_ALL_ASSIGNMENTS_F
		  sqlTxt := 'select * from PER_ALL_ASSIGNMENTS_F where person_id = (''&&4'') order by effective_start_date';
		  run_sql('PER_ALL_ASSIGNMENTS_F', sqltxt);
		  
		  select count(1) into v_rows 
			from PER_ALL_ASSIGNMENTS_F where person_id = ('&&4')
			and sysdate between Effective_Start_Date and effective_end_date
			and primary_flag = 'Y' and assignment_type IN ('E', 'C');
		  if v_rows=0 then
				:e3:=:e3+1;
				l_o('<div class="diverr" id="sigte9"><img class="error_ico"><font color="red">Error:</font> There is no active primary assignment.<br></div>');		  
		  elsif v_rows=1 then	
			select Supervisor_Id into v_supervisor_id
				from PER_ALL_ASSIGNMENTS_F where person_id = ('&&4')
				and sysdate between Effective_Start_Date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C');	
		      
			  if v_supervisor_id is Null then
						:w3:=:w3+1;
						l_o('<div class="divwarn" id="siga4"><img class="warn_ico"><span class="sectionorange">Warning: </span>This employee does not have a Supervisor assigned.<br></div>');
			  else
					  select count(distinct typ.system_person_type) into v_rows from per_person_types typ, per_all_people_f pep where pep.person_type_id = typ.person_type_id 
						and sysdate between pep.effective_start_date and pep.effective_end_date and pep.person_id = v_supervisor_id;
					  
					  if v_rows=0 then
							:w3:=:w3+1;
							l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>The supervisor is not active.<br></div>');
					  elsif v_rows=1 then
							select distinct typ.system_person_type into v_system_person_type 
							from per_person_types typ, per_all_people_f pep where pep.person_type_id = typ.person_type_id 
								and sysdate between pep.effective_start_date and pep.effective_end_date and pep.person_id = v_supervisor_id;
							if v_system_person_type not in ('CWK', 'EMP', 'EMP_APL') then
								:w3:=:w3+1;
								l_o('<div class="divwarn" id="siga5"><img class="warn_ico"><span class="sectionorange">Warning: </span>Employee''s Supervisor is not active.</div><br>');
							end if;
					   end if;
			    end if;
		  end if;
		
		
		  select count(1) into v_rows from HXC_APPLICATION_SET_COMPS_V where application_set_id in 
			(select application_set_id from hxc_time_building_blocks where scope = 'TIMECARD' 
			and resource_id = ('&&4')  and trunc(start_time) = to_date('&&5') )
			and Time_Recipient_Name like '%Projects%';
		  if v_rows>0 then
			  select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F 
				where person_id = ('&&4')  
				and sysdate between effective_start_date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C')
				and job_id is NULL;
			  if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigte5"><img class="error_ico"><font color="red">Error:</font> Assignment Job cannot be NULL for Projects Timecard.<br></div>');
			  end if;
		  end if;

		  select count(1) into v_rows from HXC_APPLICATION_SET_COMPS_V where application_set_id in 
			(select application_set_id from hxc_time_building_blocks where scope = 'TIMECARD' 
			and resource_id = ('&&4')  and trunc(start_time) = to_date('&&5') )
			and Time_Recipient_Name like '%Payroll%';
		  if v_rows>0 then
			  select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F 
				where person_id = ('&&4')  
				and sysdate between effective_start_date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C')
				and payroll_id is NULL;
			  if v_rows>0 then
					:e3:=:e3+1;
					l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> Payroll Timecards must have a Payroll Assignment.<br></div>');
			  else
			  	  select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F 
						where person_id = ('&&4')  
						and sysdate between effective_start_date and effective_end_date
						and primary_flag = 'Y' and assignment_type IN ('E', 'C');
				  if v_rows=1 then
							select payroll_id into v_payroll_id from PER_ALL_ASSIGNMENTS_F 
							where person_id = ('&&4')  
							and sysdate between effective_start_date and effective_end_date
							and primary_flag = 'Y' and assignment_type IN ('E', 'C');
							select max(end_date) into v_end_date from per_time_periods where payroll_id = v_payroll_id;
							if v_end_date< sysdate then
									:e3:=:e3+1;
									l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> Payroll assigned to this assignment has no future open periods.<br></div>');
							end if;
				
				  end if;
				 
			  end if;	  

		  end if;		  
		 
		  
		  select count(1) into v_rows from HXC_APPROVAL_COMPS where 
			Approval_Mechanism like '%HR_SUPERVISOR%'
			and approval_style_id in 
			(select approval_style_id from hxc_time_building_blocks where scope = 'TIMECARD' 
			and resource_id = ('&&4') and trunc(start_time) = to_date('&&5')
			and date_to=to_date('31-DEC-4712'));

		  if v_rows>0 then
				select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F where person_id = ('&&4') 
				and sysdate between effective_start_date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C');
				if v_rows=1 then
					select Supervisor_Id into v_supervisor_id from PER_ALL_ASSIGNMENTS_F where person_id = ('&&4') 
					and sysdate between effective_start_date and effective_end_date
					and primary_flag = 'Y' and assignment_type IN ('E', 'C');
					if v_supervisor_id is Null then
						:e3:=:e3+1;
						l_o('<div class="diverr" id="siga4"><img class="error_ico"><font color="red">Error:</font> Timecard Owner must have a Supervisor assigned in order to use HR Supervisor Approvals.<br></div>');
					end if;
				end if;
		  end if;
		  
		  		  
		  select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F where person_id = ('&&4')
		  and Effective_End_Date = to_date('31-DEC-4712') and Assignment_Status_Type_Id = 1;
		  if v_rows>1 then
				:e3:=:e3+1;
				l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> OTL Does not work properly with Multiple Assignments. Please refer to: ');
				Show_Link('577411.1'); 
				l_o(' OTL: Multiple Assignments Functionality and ');
				Show_Link('364880.1'); 
				l_o(' Enabling OTL Self-Service Timecard Entries for Multiple Assignments.</div><br>');
		  end if;
		  
		  select count(1) into v_rows from PER_ALL_ASSIGNMENTS_F 
		  where person_id = ('&&4') and sysdate between effective_start_date and effective_end_date;
		  if v_rows=1 then
				select primary_flag into v_primary_flag from PER_ALL_ASSIGNMENTS_F 
				where person_id = ('&&4') and sysdate between effective_start_date and effective_end_date;
				if upper(v_primary_flag)='N' then
						:e3:=:e3+1;
						l_o('<div class="diverr" id="sigte6"><img class="error_ico"><font color="red">Error:</font> Active Assignment of Timcard Owner is not a Primary Assignment.</div><br>');
				end if;
		  		  
				l_o('<div class="divok"> Organization of the Timecard Owner''s Assignment is: </span><span class="sectionblue">');
				select Organization_Id into v_org_id from PER_ALL_ASSIGNMENTS_F 
					where person_id = ('&&4') and sysdate between effective_start_date and effective_end_date;
				select name into v_org_name from hr_all_organization_units where organization_id = v_org_id;
				l_o(v_org_id||' </span>- <span class="sectionblue">'||v_org_name||'</span></div><br>');
		  end if;
		  
		  
		  sqlTxt := 'select * from PER_ASSIGNMENT_STATUS_TYPES where assignment_status_type_id in (select assignment_status_type_id from PER_ALL_ASSIGNMENTS_F where person_id = (''&&4''))';
		  run_sql('PER_ASSIGNMENT_STATUS_TYPES', sqltxt);
		  
		  select count(1) into v_rows from PER_ASSIGNMENT_STATUS_TYPES 
				where assignment_status_type_id in 
				(select assignment_status_type_id from PER_ALL_ASSIGNMENTS_F 
				where person_id = ('&&4') 
				and sysdate between effective_start_date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C')) 
				and ((Per_System_Status like '%ACTIVE_ASSIGN%') or (Per_System_Status like '%ACTIVE_CWK%')) ;
		  if v_rows=0 then
				:e3:=:e3+1;
				l_o('<div class="diverr" id="sigte7"><img class="error_ico"><font color="red">Error:</font> Timecard Owner''s Assignment is not Active.</div><br>');
		  end if;
		  
		  sqlTxt := 'select typ.name Absence_Type, abs.date_start Start_date, abs.date_end End_date, abs.absence_days Absence_days, abs.time_start Time_start, abs.time_end Time_end, abs.absence_hours Absence_hours, abs.sickness_start_date Sickness_start_date, abs.sickness_end_date Sickness_end_date
		  from PER_ABSENCE_ATTENDANCES abs, per_absence_attendance_types typ  where person_id = (''&&4'')
		  and abs.absence_attendance_type_id = typ.absence_attendance_type_id
		  and date_start between to_date(''&&5'') and (select distinct Stop_Time from hxc_timecard_summary where Resource_Id = (''&&4'') and trunc(start_time) = to_date(''&&5'') and rownum < 2)';
		  run_sql('Absences for this person in the same period', sqltxt);
		  
		  sqlTxt := 'select * from HR_SOFT_CODING_KEYFLEX where soft_coding_keyflex_id in (select soft_coding_keyflex_id from PER_ALL_ASSIGNMENTS_F where person_id = (''&&4''))';
		  run_sql('HR_SOFT_CODING_KEYFLEX', sqltxt);

		  sqlTxt:='
		  select USER_ID
			   , USER_NAME
			   , LAST_UPDATE_DATE
			   , LAST_UPDATED_BY
			   , CREATION_DATE
			   , CREATED_BY
			   , LAST_UPDATE_LOGIN
		--       , ENCRYPTED_FOUNDATION_PASSWORD
		--       , ENCRYPTED_USER_PASSWORD
			   , SESSION_NUMBER
			   , START_DATE
			   , END_DATE
			   , DESCRIPTION
			   , LAST_LOGON_DATE
			   , PASSWORD_DATE
			   , PASSWORD_ACCESSES_LEFT
			   , PASSWORD_LIFESPAN_ACCESSES
			   , PASSWORD_LIFESPAN_DAYS
			   , EMPLOYEE_ID
			   , EMAIL_ADDRESS
			   , FAX
			   , CUSTOMER_ID
			   , SUPPLIER_ID
			   , WEB_PASSWORD
		--  , SECURITY_GROUP_ID
		--  , USER_GUID
			   , GCN_CODE_COMBINATION_ID
			   , PERSON_PARTY_ID
			from FND_USER
		   where employee_id = (''&&4'')';
		  run_sql('FND_USER', sqltxt);

		  sqlTxt := 'select * from WF_ROLES where orig_system = ''PER'' and orig_system_id = (''&&4'')';
		  run_sql('WF_ROLES', sqltxt);

		  sqlTxt := 'select * from HXT_ADD_ASSIGN_INFO_F where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id = (''&&4'')) order by id, effective_start_date';
		  run_sql('HXT_ADD_ASSIGN_INFO_F', sqltxt);
		  
		  l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		  
		  l_o('</div><br/>');
		  
		-- ********** PROJECTS **********
		
	if not l_show_ar then
	
		if l_apps like '%PROJECTS%' then

				l_o('<div class="divSection">');
				l_o('<a name="hxc6"></a><div class="divSectionTitle">Projects</div><br>');
/*
				sqlTxt := '
				select ''TC Details'' source, sum(det.measure) total
				  from hxc_timecard_summary sum
					 , hxc_time_building_blocks tim
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
					 , hxc_time_attribute_usages use
					 , hxc_time_attributes att
				 where sum.resource_id = (''&&4'')
				   and trunc(sum.start_time) = to_date(''&&5'')
				   and tim.time_building_block_id = sum.timecard_id
				   and tim.object_version_number = sum.timecard_ovn
				   and day.parent_building_block_id = tim.time_building_block_id
				   and day.parent_building_block_ovn = tim.object_version_number
				   and det.parent_building_block_id = day.time_building_block_id
				   and det.parent_building_block_ovn = day.object_version_number
				   and det.date_to = to_date(''31-DEC-4712'')
				   and use.time_building_block_id = det.time_building_block_id
				   and use.time_building_block_ovn = det.object_version_number
				   and att.time_attribute_id = use.time_attribute_id
				   and att.attribute_category = ''PROJECTS''
				UNION ALL
				select ''TC Summary'' source, sum(recorded_hours) total
				  from hxc_timecard_summary sum
				 where sum.resource_id = (''&&4'')
				   and trunc(sum.start_time) = to_date(''&&5'')
				UNION ALL
				select ''PA Expenditures'' source, sum(exp.quantity) total
				  from hxc_timecard_summary sum
					 , hxc_time_building_blocks tim
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
					 , hxc_time_attribute_usages use
					 , hxc_time_attributes att
					 , pa_expenditure_items_all exp
				 where sum.resource_id = (''&&4'')
				   and trunc(sum.start_time) = to_date(''&&5'')
				   and tim.time_building_block_id = sum.timecard_id
				   and tim.object_version_number = sum.timecard_ovn
				   and day.parent_building_block_id = tim.time_building_block_id
				   and day.parent_building_block_ovn = tim.object_version_number
				   and det.parent_building_block_id = day.time_building_block_id
				--   and det.parent_building_block_ovn = day.object_version_number
				--   and det.date_to = to_date(''31-DEC-4712'')
				   and use.time_building_block_id = det.time_building_block_id
				   and use.time_building_block_ovn = det.object_version_number
				   and att.time_attribute_id = use.time_attribute_id
				   and att.attribute_category = ''PROJECTS''
				   and det.time_building_block_id || '':'' || det.object_version_number = exp.orig_transaction_reference (+)';
				run_sql('OTL/PA Totals Compare', sqltxt);

				select sum(det.measure) into v_tc_details
				  from hxc_timecard_summary sum
					 , hxc_time_building_blocks tim
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
					 , hxc_time_attribute_usages use
					 , hxc_time_attributes att
				 where sum.resource_id = ('&4')
				   and trunc(sum.start_time) = to_date('&5')
				   and tim.time_building_block_id = sum.timecard_id
				   and tim.object_version_number = sum.timecard_ovn
				   and day.parent_building_block_id = tim.time_building_block_id
				   and day.parent_building_block_ovn = tim.object_version_number
				   and det.parent_building_block_id = day.time_building_block_id
				   and det.parent_building_block_ovn = day.object_version_number
				   and det.date_to = to_date('31-DEC-4712')
				   and use.time_building_block_id = det.time_building_block_id
				   and use.time_building_block_ovn = det.object_version_number
				   and att.time_attribute_id = use.time_attribute_id
				   and att.attribute_category = 'PROJECTS';


				select sum(recorded_hours) into v_tc_summary
				 from hxc_timecard_summary sum
				 where sum.resource_id = ('&4')
				 and trunc(sum.start_time) = to_date('&5');

				select sum(exp.quantity) into v_pa_exped
				 from hxc_timecard_summary sum
				 , hxc_time_building_blocks tim
				 , hxc_time_building_blocks day
				 , hxc_time_building_blocks det
				 , hxc_time_attribute_usages use
				 , hxc_time_attributes att
				 , pa_expenditure_items_all exp
				 where sum.resource_id = ('&4')
				 and trunc(sum.start_time) = to_date('&5')
				 and tim.time_building_block_id = sum.timecard_id
				 and tim.object_version_number = sum.timecard_ovn
				 and day.parent_building_block_id = tim.time_building_block_id
				 and day.parent_building_block_ovn = tim.object_version_number
				 and det.parent_building_block_id = day.time_building_block_id
				 --   and det.parent_building_block_ovn = day.object_version_number
				 --   and det.date_to = to_date('31-DEC-4712')
				 and use.time_building_block_id = det.time_building_block_id
				 and use.time_building_block_ovn = det.object_version_number
				 and att.time_attribute_id = use.time_attribute_id
				 and att.attribute_category = 'PROJECTS'
				 and det.time_building_block_id || ':' ||  det.object_version_number = exp.orig_transaction_reference (+);
				
				if v_tc_details<>v_tc_summary or v_tc_summary<>v_pa_exped or v_pa_exped<>v_tc_details then
					:e3:=:e3+1;
					l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> You are having data corruption issue in this timecard. Please refer to the following note:');
					if :APPS_REL like '11.5%' then
						Show_link('471430.1');
						l_o(' Steps to Fix Corrupt Data for Time Entry Rules Bug 5945823');
					elsif :APPS_REL like '12%' then
						Show_link('1076544.1');
						l_o(' Timecard Summary Has More Than Timecard Details');
					end if;
					l_o('And we strongly recommend that you log a service request with Oracle Support showing them this section in the output.</div><br>');
				end if;
*/
				

				sqlTxt := 'select *
				from pa_expenditures_all
				where expenditure_id in (
				select exp.expenditure_id
				  from hxc_timecard_summary sum
					 , hxc_time_building_blocks tim
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
					 , hxc_time_attribute_usages use
					 , hxc_time_attributes att
					 , pa_expenditure_items_all exp
				 where sum.resource_id = (''&&4'')
				   and trunc(sum.start_time) = to_date(''&&5'')
				   and tim.time_building_block_id = sum.timecard_id
				   and tim.object_version_number = sum.timecard_ovn
				   and day.parent_building_block_id = tim.time_building_block_id
				   and day.parent_building_block_ovn = tim.object_version_number
				   and det.parent_building_block_id = day.time_building_block_id
				--   and det.parent_building_block_ovn = day.object_version_number
				--   and det.date_to = to_date(''31-Dec-4712'')
				   and use.time_building_block_id = det.time_building_block_id
				   and use.time_building_block_ovn = det.object_version_number
				   and att.time_attribute_id = use.time_attribute_id
				   and att.attribute_category = ''PROJECTS''
				   and det.time_building_block_id || '':'' || det.object_version_number = exp.orig_transaction_reference (+))';
				run_sql('PA_EXPENDITURES_ALL', sqltxt);
				-- check if there are 2 resource_id
				v_sql:='select count(1) from pa_expenditures_all
				where expenditure_id in (
					select exp.expenditure_id
					  from hxc_timecard_summary sum
						 , hxc_time_building_blocks tim
						 , hxc_time_building_blocks day
						 , hxc_time_building_blocks det
						 , hxc_time_attribute_usages use
						 , hxc_time_attributes att
						 , pa_expenditure_items_all exp
					 where sum.resource_id = (''&&4'')
					   and trunc(sum.start_time) = to_date(''&&5'')
					   and tim.time_building_block_id = sum.timecard_id
					   and tim.object_version_number = sum.timecard_ovn
					   and day.parent_building_block_id = tim.time_building_block_id
					   and day.parent_building_block_ovn = tim.object_version_number
					   and det.parent_building_block_id = day.time_building_block_id
					--   and det.parent_building_block_ovn = day.object_version_number
					--   and det.date_to = to_date(''31-Dec-4712'')
					   and use.time_building_block_id = det.time_building_block_id
					   and use.time_building_block_ovn = det.object_version_number
					   and att.time_attribute_id = use.time_attribute_id
					   and att.attribute_category = ''PROJECTS''
					   and det.time_building_block_id || '':'' || det.object_version_number = exp.orig_transaction_reference (+))
				   and INCURRED_BY_PERSON_ID <> (''&&4'')';
				   execute immediate v_sql into v_rows;
							  if v_rows>0 then
									:e3:=:e3+1;
									l_o('<div class="diverr" id="sigr2"><img class="error_ico"><font color="red">Error:</font> Some of the records in this table were linked to a different person_id. This causes discrepancy for the two employees. Please log an SR referring this section.<br></div>');					
							  end if;


				sqlTxt := 'select eia.*
						 from pa_expenditure_items_all eia
							, pa_expenditures_all ea
							, hxc_timecard_summary tcs
					   where eia.expenditure_id = ea.expenditure_id
						 and ea.incurred_by_person_id = tcs.resource_id
						 and tcs.resource_id = (''&&4'')
						 and tcs.start_time = to_date(''&&5'')
						 and eia.expenditure_item_date between tcs.start_time and tcs.stop_time
						 order by expenditure_item_date';
				run_sql('PA_EXPENDITURE_ITEMS_ALL', sqltxt);
				
				select count(*) into v_rows
					   from pa_expenditure_items_all eia
						  , pa_expenditures_all ea
						  , hxc_timecard_summary tcs
					 where eia.expenditure_id = ea.expenditure_id
					   and ea.incurred_by_person_id = tcs.resource_id
					   and tcs.resource_id = ('&4')
					   and tcs.start_time =  to_date('&5')
					   and eia.Transaction_Source = 'ORACLE TIME AND LABOR'
					   and eia.expenditure_item_date between tcs.start_time and tcs.stop_time
					   and substr(eia.orig_transaction_reference,instr(eia.orig_transaction_reference,':')+1,1) not in
					   (
					   select object_version_number from hxc_time_building_blocks where time_building_block_id = substr(eia.orig_transaction_reference,1,instr(eia.orig_transaction_reference,':')-1)
					   );
				if v_rows>0 then
						:e3:=:e3+1;
						l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> The follow Expenditure Item Ids are linked to an Object Version Number of a Time Building Block ID that do not exist in the original OTL Timecard:<br>');
						open c_Expenditure_Item;
						loop
							  fetch c_Expenditure_Item into v_Expenditure_item_id,v_Object_Version_Number,v_Time_Building_Block_Id;							  							  
							  EXIT WHEN  c_Expenditure_Item%NOTFOUND;
							  l_o('Expenditure_item_id: <span class="sectionblue">'||v_Expenditure_item_id);
							  l_o('</span> | Time_Building_Block_ID: <span class="sectionblue">'||v_Time_Building_Block_Id);
							  l_o('</span> | Wrong Object_Version_Number: <span class="sectionblue">'||v_Object_Version_Number||'</span><br>');							  
						end loop;
						close c_Expenditure_Item;
						l_o('Please log a service request with Oracle support refering notes:<br>');
						Show_link('1330321.1');
						l_o(' Getting  Pa_Otc_Api ::: ->Upload_Otc_Timecards->GetOrigTrxRef : Search ei  table for available ei record. -- ORA-01403: no data found in PRC:  Transaction Import<br>');
						Show_link('1345680.1');
						l_o(' Hours On Timecard Do Not Match Hours Transferred to Projects<br>');
						Show_link('1359353.1');
						l_o(' PRC: Transaction Import Error ORA-20002: pre_import:ORA-01422<br></div>');
				end if;
				

				sqlTxt := 'select det.time_building_block_id, det.object_version_number, exp.orig_transaction_reference, exp.transaction_source
					 , exp.expenditure_id, exp.expenditure_item_id
					 , day.start_time otl_day, exp.expenditure_item_date
					 , decode(to_char(det.date_to, ''DD-MON-YYYY''), ''31-DEC-4712'', ''ACTIVE'', ''INACTIVE'') OTL_STATE
					 , det.measure otl_hours, exp.quantity
					 , att.attribute1 otl_project_id, exp.project_id
					 , att.attribute2 otl_task_id, exp.task_id
					 , att.attribute3 otl_expenditure_type, exp.expenditure_type
				  from hxc_timecard_summary sum
					 , hxc_time_building_blocks tim
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
					 , hxc_time_attribute_usages use
					 , hxc_time_attributes att
					 , pa_expenditure_items_all exp
				 where sum.resource_id = (''&&4'')
				   and trunc(sum.start_time) = to_date(''&&5'')
				   and tim.time_building_block_id = sum.timecard_id
				   and tim.object_version_number = sum.timecard_ovn
				   and day.parent_building_block_id = tim.time_building_block_id
				   and day.parent_building_block_ovn = tim.object_version_number
				   and det.parent_building_block_id = day.time_building_block_id
				--   and det.parent_building_block_ovn = day.object_version_number
				--   and det.date_to = to_date(''31-DEC-4712'')
				   and use.time_building_block_id = det.time_building_block_id
				   and use.time_building_block_ovn = det.object_version_number
				   and att.time_attribute_id = use.time_attribute_id
				   and att.attribute_category = ''PROJECTS''
				   and det.time_building_block_id || '':'' || det.object_version_number = exp.orig_transaction_reference (+)
				 order by day.start_time, det.time_building_block_id, object_version_number';
				run_sql('OTL/PA Details Compare', sqltxt);
				
				
								
				l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
				
				l_o('</div><br/>');

		end if; -- Projects

		
		
		-- ********** PAYROLL or HUMAN RESOURCES **********
				
		
		if l_apps like '%PAYROLL%'
		or l_apps like '%HUMAN RESOURCES%'
		then				
				l_o('<div class="divSection">');
				l_o('<a name="hxc7"></a><div class="divSectionTitle">HR / Payroll</div><br>');

				sqlTxt := '
				select *
				from HXT_TIMECARDS_F
				where for_person_id = '||l_param2||'
				and Time_Period_Id in (
				select ptp.TIME_PERIOD_ID
				from PER_TIME_PERIODS ptp
				   , HXC_TIMECARD_SUMMARY sum
				where sum.TIMECARD_ID in '||l_tbb_tim||'
				and ( ptp.START_DATE between sum.START_TIME and sum.STOP_TIME
				   or ptp.END_DATE between sum.START_TIME and sum.STOP_TIME )
				)';
				run_sql('HXT_TIMECARDS_F', sqltxt);
				
				select count(1) into v_rows from HXT_TIMECARDS_F
				where for_person_id = '&4'
				and Time_Period_Id in (
				select ptp.TIME_PERIOD_ID
				from PER_TIME_PERIODS ptp
				   , HXC_TIMECARD_SUMMARY sum
				where sum.TIMECARD_ID in 
					(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD'
					and resource_id = ('&4') and trunc(start_time) = to_date('&5'))
				and ( ptp.START_DATE between sum.START_TIME and sum.STOP_TIME
				   or ptp.END_DATE between sum.START_TIME and sum.STOP_TIME )
				);
				
				if v_rows=1 then
					l_o('<div class="divok">  Use the value in column "ID" (<span class="sectionblue">');
					select id into v_id from HXT_TIMECARDS_F
						where for_person_id = '&4'
						and Time_Period_Id in (
						select ptp.TIME_PERIOD_ID
						from PER_TIME_PERIODS ptp
						   , HXC_TIMECARD_SUMMARY sum
						where sum.TIMECARD_ID in 
							(select time_building_block_id from HXC_TIME_BUILDING_BLOCKS where scope = 'TIMECARD'
							and resource_id = ('&4') and trunc(start_time) = to_date('&5'))
						and ( ptp.START_DATE between sum.START_TIME and sum.STOP_TIME
						   or ptp.END_DATE between sum.START_TIME and sum.STOP_TIME )
						);
					l_o(v_id||'</span>');
					l_o(') if you want to output the HXT version of this timecard from OTL Analyzer, put this ID at Tim ID of the required timecard.<br></div>');
				end if;
				
				l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
				l_o('</div><br/>');

		end if; -- Payroll or HR

	end if; -- end archive
		-- ***************  Data Integrity Test  ***************
		
		
		
		l_o('<div class="divSection">');
		l_o('<a name="hxc8"></a><div class="divSectionTitle">Data Integrity Tests</div><br>');
		v_issue:=FALSE;
		
		v_sql2:='select count(1) 
				from hxc_time_building_blocks det1
						 , hxc_time_building_blocks det2
					 where det1.time_building_block_id in '||l_tbb_det||'
					   and det2.time_building_block_id in '||l_tbb_det||'
					   and det1.date_to = to_date(''31-Dec-4712'')
					   and det2.date_to = det1.date_to
					   and det1.translation_display_key = det2.translation_display_key
					   and det1.time_building_block_id <> det2.time_building_block_id
					   order by det1.translation_display_key, det1.time_building_block_id
					';
		execute immediate v_sql2 into v_rows;								
	
		if v_rows>0 then
					v_issue:=TRUE;
					sqlTxt := '
					select det1.time_building_block_id time_building_block_id
						 , det1.date_to date_to
						 , det1.translation_display_key translation_display_key
					  from hxc_time_building_blocks det1
						 , hxc_time_building_blocks det2
					 where det1.time_building_block_id in '||l_tbb_det||'
					   and det2.time_building_block_id in '||l_tbb_det||'
					   and det1.date_to = to_date(''31-Dec-4712'')
					   and det2.date_to = det1.date_to
					   and det1.translation_display_key = det2.translation_display_key
					   and det1.time_building_block_id <> det2.time_building_block_id
					   order by det1.translation_display_key, det1.time_building_block_id
					';
					--Tab0Print(replace(sqlTxt, chr(10),'<br>'));
					run_sql('Translation_Display_Key - Duplicates', sqltxt);

					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigte81"><img class="error_ico"><font color="red">Error:</font> You have data corruption issue in this timecard. Please refer to the following note:');
					if :APPS_REL like '11.5%' then
						Show_link('471430.1');
						l_o(' Steps to Fix Corrupt Data for Time Entry Rules Bug 5945823');
					elsif :APPS_REL like '12%' then
						Show_link('1076544.1');
						l_o(' Timecard Summary Has More Than Timecard Details');
					end if;
					l_o('<br>And we strongly recommend that you log a service request with Oracle Support showing them this section in the output.</div><br>');
		end if;	
			
		
		v_sql2:='select count(1) 
				from 
				(with tab as (
					select det.time_building_block_id, det.object_version_number, det.measure otl_hours, det.comment_text, det.translation_display_key
						 , substr(det.translation_display_key,instr(det.translation_display_key,''|'',1,1)+1,instr(det.translation_display_key,''|'',1,2)-(instr(det.translation_display_key,''|'',1,1)+1)) det_row
						 , att.attribute_category
						 , att.attribute1, att.attribute2, att.attribute3, att.attribute4, att.attribute5, att.attribute6, att.attribute7, att.attribute8, att.attribute9, att.attribute10
						 , att.attribute11, att.attribute12, att.attribute13, att.attribute14, att.attribute15, att.attribute16, att.attribute17, att.attribute18, att.attribute19, att.attribute20
						 , att.attribute21, att.attribute22, att.attribute23, att.attribute24, att.attribute25, att.attribute26, att.attribute27, att.attribute28, att.attribute29, att.attribute30
					  from hxc_time_building_blocks det
						 , hxc_time_attribute_usages use
						 , hxc_time_attributes att
					 where 1=1
					   and det.time_building_block_id in '||l_tbb_det||'
					   and det.date_to = to_date(''31-Dec-4712'')
					   and use.time_building_block_id = det.time_building_block_id
					   and use.time_building_block_ovn = det.object_version_number
					   and att.time_attribute_id = use.time_attribute_id
					   and (att.attribute_category = ''PROJECTS''
						 or att.attribute_category like ''ELEMENT%''))
					select a.time_building_block_id
						 , a.translation_display_key
						 , a.det_row detail_row
						 , a.attribute_category
						 , a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5, a.attribute6, a.attribute7, a.attribute8, a.attribute9, a.attribute10
						 , a.attribute11, a.attribute12, a.attribute13, a.attribute14, a.attribute15, a.attribute16, a.attribute17, a.attribute18, a.attribute19, a.attribute20
						 , a.attribute21, a.attribute22, a.attribute23, a.attribute24, a.attribute25, a.attribute26, a.attribute27, a.attribute28, a.attribute29, a.attribute30
					  from tab a
					 where exists (select 1
									 from tab b
									where a.time_building_block_id <> b.time_building_block_id
									  and a.det_row = b.det_row
									  and substr(a.attribute_category,1,8) = substr(b.attribute_category,1,8)
									  and (a.attribute_category = b.attribute_category
										   and (nvl(a.attribute1,''.'') <> nvl(b.attribute1,''.'')
											or  nvl(a.attribute2,''.'') <> nvl(b.attribute2,''.'')
											or  nvl(a.attribute3,''.'') <> nvl(b.attribute3,''.'')
											or  nvl(a.attribute4,''.'') <> nvl(b.attribute4,''.'')
											or  nvl(a.attribute5,''.'') <> nvl(b.attribute5,''.'')
											or  nvl(a.attribute6,''.'') <> nvl(b.attribute6,''.'')
											or  nvl(a.attribute7,''.'') <> nvl(b.attribute7,''.'')
											or  nvl(a.attribute8,''.'') <> nvl(b.attribute8,''.'')
											or  nvl(a.attribute9,''.'') <> nvl(b.attribute9,''.'')
											or  nvl(a.attribute10,''.'') <> nvl(b.attribute10,''.'')
											or  nvl(a.attribute11,''.'') <> nvl(b.attribute11,''.'')
											or  nvl(a.attribute12,''.'') <> nvl(b.attribute12,''.'')
											or  nvl(a.attribute13,''.'') <> nvl(b.attribute13,''.'')
											or  nvl(a.attribute14,''.'') <> nvl(b.attribute14,''.'')
											or  nvl(a.attribute15,''.'') <> nvl(b.attribute15,''.'')
											or  nvl(a.attribute16,''.'') <> nvl(b.attribute16,''.'')
											or  nvl(a.attribute17,''.'') <> nvl(b.attribute17,''.'')
											or  nvl(a.attribute18,''.'') <> nvl(b.attribute18,''.'')
											or  nvl(a.attribute19,''.'') <> nvl(b.attribute19,''.'')
											or  nvl(a.attribute20,''.'') <> nvl(b.attribute20,''.'')
											or  nvl(a.attribute21,''.'') <> nvl(b.attribute21,''.'')
											or  nvl(a.attribute22,''.'') <> nvl(b.attribute22,''.'')
											or  nvl(a.attribute23,''.'') <> nvl(b.attribute23,''.'')
											or  nvl(a.attribute24,''.'') <> nvl(b.attribute24,''.'')
											or  nvl(a.attribute25,''.'') <> nvl(b.attribute25,''.'')
											or  nvl(a.attribute26,''.'') <> nvl(b.attribute26,''.'')
											or  nvl(a.attribute27,''.'') <> nvl(b.attribute27,''.'')
											or  nvl(a.attribute28,''.'') <> nvl(b.attribute28,''.'')
											or  nvl(a.attribute29,''.'') <> nvl(b.attribute29,''.'')
											or  nvl(a.attribute30,''.'') <> nvl(b.attribute30,''.'')
								  ))))
					';
		execute immediate v_sql2 into v_rows;
		
		if v_rows>0 then
					v_issue:=TRUE;
					sqlTxt := '
					with tab as (
					select det.time_building_block_id, det.object_version_number, det.measure otl_hours, det.comment_text, det.translation_display_key
						 , substr(det.translation_display_key,instr(det.translation_display_key,''|'',1,1)+1,instr(det.translation_display_key,''|'',1,2)-(instr(det.translation_display_key,''|'',1,1)+1)) det_row
						 , att.attribute_category
						 , att.attribute1, att.attribute2, att.attribute3, att.attribute4, att.attribute5, att.attribute6, att.attribute7, att.attribute8, att.attribute9, att.attribute10
						 , att.attribute11, att.attribute12, att.attribute13, att.attribute14, att.attribute15, att.attribute16, att.attribute17, att.attribute18, att.attribute19, att.attribute20
						 , att.attribute21, att.attribute22, att.attribute23, att.attribute24, att.attribute25, att.attribute26, att.attribute27, att.attribute28, att.attribute29, att.attribute30
					  from hxc_time_building_blocks det
						 , hxc_time_attribute_usages use
						 , hxc_time_attributes att
					 where 1=1
					   and det.time_building_block_id in '||l_tbb_det||'
					   and det.date_to = to_date(''31-Dec-4712'')
					   and use.time_building_block_id = det.time_building_block_id
					   and use.time_building_block_ovn = det.object_version_number
					   and att.time_attribute_id = use.time_attribute_id
					   and (att.attribute_category = ''PROJECTS''
						 or att.attribute_category like ''ELEMENT%''))
					select a.time_building_block_id
						 , a.translation_display_key
						 , a.det_row detail_row
						 , a.attribute_category
						 , a.attribute1, a.attribute2, a.attribute3, a.attribute4, a.attribute5, a.attribute6, a.attribute7, a.attribute8, a.attribute9, a.attribute10
						 , a.attribute11, a.attribute12, a.attribute13, a.attribute14, a.attribute15, a.attribute16, a.attribute17, a.attribute18, a.attribute19, a.attribute20
						 , a.attribute21, a.attribute22, a.attribute23, a.attribute24, a.attribute25, a.attribute26, a.attribute27, a.attribute28, a.attribute29, a.attribute30
					  from tab a
					 where exists (select 1
									 from tab b
									where a.time_building_block_id <> b.time_building_block_id
									  and a.det_row = b.det_row
									  and substr(a.attribute_category,1,8) = substr(b.attribute_category,1,8)
									  and (a.attribute_category = b.attribute_category
										   and (nvl(a.attribute1,''.'') <> nvl(b.attribute1,''.'')
											or  nvl(a.attribute2,''.'') <> nvl(b.attribute2,''.'')
											or  nvl(a.attribute3,''.'') <> nvl(b.attribute3,''.'')
											or  nvl(a.attribute4,''.'') <> nvl(b.attribute4,''.'')
											or  nvl(a.attribute5,''.'') <> nvl(b.attribute5,''.'')
											or  nvl(a.attribute6,''.'') <> nvl(b.attribute6,''.'')
											or  nvl(a.attribute7,''.'') <> nvl(b.attribute7,''.'')
											or  nvl(a.attribute8,''.'') <> nvl(b.attribute8,''.'')
											or  nvl(a.attribute9,''.'') <> nvl(b.attribute9,''.'')
											or  nvl(a.attribute10,''.'') <> nvl(b.attribute10,''.'')
											or  nvl(a.attribute11,''.'') <> nvl(b.attribute11,''.'')
											or  nvl(a.attribute12,''.'') <> nvl(b.attribute12,''.'')
											or  nvl(a.attribute13,''.'') <> nvl(b.attribute13,''.'')
											or  nvl(a.attribute14,''.'') <> nvl(b.attribute14,''.'')
											or  nvl(a.attribute15,''.'') <> nvl(b.attribute15,''.'')
											or  nvl(a.attribute16,''.'') <> nvl(b.attribute16,''.'')
											or  nvl(a.attribute17,''.'') <> nvl(b.attribute17,''.'')
											or  nvl(a.attribute18,''.'') <> nvl(b.attribute18,''.'')
											or  nvl(a.attribute19,''.'') <> nvl(b.attribute19,''.'')
											or  nvl(a.attribute20,''.'') <> nvl(b.attribute20,''.'')
											or  nvl(a.attribute21,''.'') <> nvl(b.attribute21,''.'')
											or  nvl(a.attribute22,''.'') <> nvl(b.attribute22,''.'')
											or  nvl(a.attribute23,''.'') <> nvl(b.attribute23,''.'')
											or  nvl(a.attribute24,''.'') <> nvl(b.attribute24,''.'')
											or  nvl(a.attribute25,''.'') <> nvl(b.attribute25,''.'')
											or  nvl(a.attribute26,''.'') <> nvl(b.attribute26,''.'')
											or  nvl(a.attribute27,''.'') <> nvl(b.attribute27,''.'')
											or  nvl(a.attribute28,''.'') <> nvl(b.attribute28,''.'')
											or  nvl(a.attribute29,''.'') <> nvl(b.attribute29,''.'')
											or  nvl(a.attribute30,''.'') <> nvl(b.attribute30,''.'')
								  )))
					order by a.det_row, a.attribute_category, a.attribute1, a.attribute2, a.attribute3
					';
					--Tab0Print(replace(sqlTxt, chr(10),'<br>'));
					run_sql('Translation_Display_Key - Wrong Line', sqltxt);
		
		
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigte82"><img class="error_ico"><font color="red">Error:</font> You have data corruption issue in this timecard. Please refer to the following notes:<br>');
					Show_link('1547463.1');
					l_o(' Profile OTL: Debug Check Enabled<br>');
					Show_link('1462822.1');
					l_o(' After Editing Timecard by Nulling Out Hours, Timecard Gets Corrupted');
					l_o('<br>And we strongly recommend that you log a service request with Oracle Support showing them this section in the output.</div><br>');
		end if;	
		

		v_sql2:='select count(1) 
				from hxc_time_building_blocks tc
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
				 where tc.time_building_block_id in '||l_tbb_tim||'
				   and tc.date_to = to_date(''31-DEC-4712'', ''DD-MON-YYYY'')
				   and day.parent_building_block_id = tc.time_building_block_id
				   and day.parent_building_block_ovn = tc.object_version_number
				   and day.date_to = tc.date_to
				   and det.parent_building_block_id = day.time_building_block_id
				   and det.parent_building_block_ovn = day.object_version_number
				   and det.date_to = day.date_to
				   and substr(det.translation_display_key,instr(det.translation_display_key,''|'',1,2)+1,length(det.translation_display_key))
					   <> to_number(day.start_time-tc.start_time)
				';
		execute immediate v_sql2 into v_rows;
		
		if v_rows>0 then
				v_issue:=TRUE;
				sqlTxt := '
				select tc.time_building_block_id timecard_id
					 , tc.resource_id
					 , tc.start_time
					 , det.time_building_block_id time_building_block_id
					 , day.start_time day
					 , day.translation_display_key day_tdk
					 , det.translation_display_key det_tdk
					 , to_number(day.start_time-tc.start_time)  correct_segment3
				  from hxc_time_building_blocks tc
					 , hxc_time_building_blocks day
					 , hxc_time_building_blocks det
				 where tc.time_building_block_id in '||l_tbb_tim||'
				   and tc.date_to = to_date(''31-DEC-4712'', ''DD-MON-YYYY'')
				   and day.parent_building_block_id = tc.time_building_block_id
				   and day.parent_building_block_ovn = tc.object_version_number
				   and day.date_to = tc.date_to
				   and det.parent_building_block_id = day.time_building_block_id
				   and det.parent_building_block_ovn = day.object_version_number
				   and det.date_to = day.date_to
				   and substr(det.translation_display_key,instr(det.translation_display_key,''|'',1,2)+1,length(det.translation_display_key))
					   <> to_number(day.start_time-tc.start_time)
				';
				--Tab0Print(replace(sqlTxt, chr(10),'<br>'));
				run_sql('Translation_Display_Key - Wrong Day', sqltxt);
		
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigte83"><img class="error_ico"><font color="red">Error:</font> You have data corruption issue in this timecard.');
					l_o('<br>Please log a service request with Oracle Support showing them this section in the output to ask a data fix from development.</div><br>');
		end if;	

		
	
		v_sql:='select count(1) 
				from hxc_time_building_blocks day
						 , hxc_time_building_blocks det
					 where day.time_building_block_id in '||l_tbb_day||'
					   and det.parent_building_block_id = day.time_building_block_id
					   and det.parent_building_block_ovn = day.object_version_number
					   and det.date_to = to_date(''31-DEC-4712'', ''DD-MON-YYYY'')
					   and day.date_to <> det.date_to
					';
		execute immediate v_sql into v_rows;
		
		if v_rows>0 then
					v_issue:=TRUE;
					sqlTxt := '
					select det.time_building_block_id
						 , det.object_version_number
						 , det.date_to det_date_to
						 , day.date_to day_date_to
					  from hxc_time_building_blocks day
						 , hxc_time_building_blocks det
					 where day.time_building_block_id in '||l_tbb_day||'
					   and det.parent_building_block_id = day.time_building_block_id
					   and det.parent_building_block_ovn = day.object_version_number
					   and det.date_to = to_date(''31-DEC-4712'', ''DD-MON-YYYY'')
					   and day.date_to <> det.date_to
					';
					--Tab0Print(replace(sqlTxt, chr(10),'<br>'));
					run_sql('Active Detail / Inactive Day', sqltxt);
					:e3:=:e3+1;
					l_o('<div class="diverr" id="sigte84"><img class="error_ico"><font color="red">Error:</font> You have data corruption issue in this timecard.');
					l_o('<br>Please log a service request with Oracle Support showing them this section in the output to ask a data fix from development.</div><br>');
		end if;	
		
		if not v_issue then
				l_o('<div class="divok1"> <img class="check_ico">OK! All verifications passed! This timecard doesn''t fall under any of the known data corruption problems in OTL.</div>');
		end if;
		
		l_o('<br><br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		l_o('</div><br/>');
		
		-- ***************  Past Timecards  ***************
	

		l_o('<div class="divSection">');
		l_o('<a name="hxc9"></a><div class="divSectionTitle">Past Timecards</div><br>');
		
		sqlTxt := 'select to_char(start_time, ''DD-MON-YYYY'') "Start Date" from HXC_TIMECARD_SUMMARY where resource_id = (''&&4'') and start_time > sysdate - 180 order by start_time';
		run_sql('Timecard Start Dates for last 6 Months', sqltxt);
		
		select count(1) into v_rows from HXC_TIMECARD_SUMMARY 
			where resource_id = ('&4') and start_time > sysdate - 180;
		if v_rows>0 then
					l_o('<div class="divok"> Notice this section tells you the start dates of each timecard you have for this person to help you provide the correct output when required by Oracle Support.</div><br>');					
		end if;
		
		l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		

		-- ***************  Invalid Parameter Handling  ***************

		else -- test timecard

		 l_o('<BR>');
		 :e3:=:e3+1;
		 ErrorPrint(''''||l_param3||''' is not a valid timecard start date for this person.');

		  sqlTxt := 'select * from PER_ALL_PEOPLE_F where person_id = (''&&4'') order by effective_start_date';
		  run_sql('PER_ALL_PEOPLE_F', sqltxt);

		  sqlTxt := 'select * from PER_ALL_ASSIGNMENTS_F where person_id = (''&&4'') order by effective_start_date';
		  run_sql('PER_ALL_ASSIGNMENTS_F', sqltxt);

		  sqlTxt := 'select to_char(start_time, ''DD-MON-YYYY'') "Start Date" from HXC_TIMECARD_SUMMARY where resource_id = (''&&4'') and start_time > sysdate - 180 order by start_time';
		  run_sql('Timecard Start Dates for last 6 Months', sqltxt);

		end if; -- test timecard

		else -- test_person

		 l_o('<BR>');
		 :e3:=:e3+1;
		 ErrorPrint(''''||l_param2||''' is not a valid person_id.');

		end if; -- test_person

		-- ***************  Invalid Parameter Handling  ***************
		
		l_o('</div><br/>');
		
		 :n := round((dbms_utility.get_time - :n)/100/60,4);
	     l_o('<br><br><i> Elapsed time '||:n|| ' minutes</i> <br>');
	
		end;
		end;
		
		l_o('</div>');
end if; -- HXC_TC

		
		
-- Display Preference section

if upper('&&6') = 'Y' then
		begin    
		declare
		v_pref_date date;
		TYPE VARCHARTAB IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(50);
		g_vset_query  VARCHARTAB;
		cursor c_preference is
			SELECT 
			PREF_HIERARCHY_NAME "Node Name",
			NAME "Rule Name",
			RULE_EVALUATION_ORDER "Precedence",
			MEANING "Link By",
			nvl(ELIGIBILITY_CRITERIA,'-') "Linked To",start_date
			from hxc_resource_rules_person_v
			WHERE person_id = ('&&4')
			and sysdate between start_date and end_date
			and sysdate between effective_start_date and effective_end_date
			order by rule_evaluation_order;
		v_node_name hxc_resource_rules_person_v.PREF_HIERARCHY_NAME%type;
		v_rule_name hxc_resource_rules_person_v.NAME%type;
		v_precedence hxc_resource_rules_person_v.RULE_EVALUATION_ORDER%type;
		v_link_by hxc_resource_rules_person_v.MEANING%type;
		v_linked_to hxc_resource_rules_person_v.ELIGIBILITY_CRITERIA%type;
		v_retrival_rules varchar2(100);
		v_status hxc_retrieval_rule_comps_v.STATUS%type;
		v_sd date;
		issue_retrieval boolean :=FALSE;
		type pref_type is table of varchar2(150);
		pref pref_type:= pref_type(null,null,null,null,null,null,null,null,null,null);
		cursor element (c_attribute_value number) is
			select to_number(attribute1)
				from hxc_alias_values
				where attribute_category in ('PAYROLL_ELEMENTS', 'EXPENDITURE_ELEMENTS' , 'ELEMENTS_EXPENDITURE_SLF')
				and alias_definition_id = c_attribute_value 
				and ((sysdate between date_from and date_to) OR (sysdate > date_from and date_to is null))
				and enabled_flag = 'Y';

   
		cursor element_link (c_element_type_id number) is
			select element_link_id from PAY_ELEMENT_LINKS_f where element_type_id = c_element_type_id and sysdate between effective_start_date and effective_end_date;
		issue boolean;
		v_is_ok boolean;
		v_assignment_id per_all_assignments_f.assignment_id%type;
		v_alias_definition 	hxc_alias_definitions.ALIAS_DEFINITION_NAME%type;
		v_element_type_id number;
		v_element_link_id PAY_ELEMENT_LINKS_f.element_link_id%type;
		v_element_name   pay_element_types_f.element_name%type;
		v_rows number;
		Elig varchar2(3);
		timp number;		
		v_pref_hierarchy_name hxc_resource_rules_v.pref_hierarchy_name%type;		


		FUNCTION display_value(p_sql  IN VARCHAR2,
							   p_id   IN VARCHAR2)
		RETURN VARCHAR2
		IS

		 l_cursor sys_refcursor;
		 l_return  VARCHAR2(150);
		BEGIN
			IF p_sql IS NOT NULL
			THEN
			   OPEN l_cursor for p_sql USING p_id;
			   FETCH l_cursor INTO l_return;
			   CLOSE l_cursor;
			ELSE
			   l_return := p_id;
			END IF;
			RETURN l_return;
		END display_value;

		FUNCTION get_vset_query(p_id   IN  NUMBER)
		RETURN VARCHAR2
		IS

		l_select VARCHAR2(4000);
		l_where  VARCHAR2(4000);

			CURSOR get_query
				IS SELECT 'SELECT '||value_column_name||
						  ' FROM '||application_table_name||
						  ' WHERE '||id_column_name||' = :1 ',
						  additional_where_clause
					 FROM fnd_flex_validation_tables t
					WHERE flex_value_set_id = p_id; 

		BEGIN
			OPEN get_query;
			FETCH get_query INTO l_select,l_where;

			IF l_where IS NOT NULL
			THEN
			   l_where := LTRIM(LTRIM(l_where,'WHERE'),'where');
			   l_where := REPLACE(l_where,':$PROFILES$.PER_BUSINESS_GROUP_ID','FND_PROFILE.VALUE(''PER_BUSINESS_GROUP_ID'')');
			   l_select := l_select||' AND '||l_where;
			END IF;

			RETURN l_select;
		END get_vset_query;

		FUNCTION get_context_name(p_code  IN VARCHAR2)
		RETURN VARCHAR2
		IS

		l_name  VARCHAR2(150);

		BEGIN
			SELECT DESCRIPTIVE_FLEX_CONTEXT_NAME
			  INTO l_name
			  FROM FND_DESCR_FLEX_CONTEXTS_tl
			 WHERE application_id = 809
			   AND descriptive_flexfield_name = 'OTC PREFERENCES'
			   AND DESCRIPTIVE_FLEX_CONTEXT_CODE = p_code
			   AND language = USERENV('LANG');
		   RETURN l_name;
		 EXCEPTION 
		   WHEN NO_DATA_FOUND
		   THEN
			  RETURN p_code;
		END get_context_name;


		PROCEDURE get_segment_name(p_pref_row  IN  hxc_preference_evaluation.t_pref_table_row)
		IS

		l_name  VARCHAR2(150);
		l_column VARCHAR2(50);
		l_display VARCHAR2(150);
		l_vset NUMBER;
		v_entity_group_name hxc_entity_groups.name%type;
		v_alias_def_name hxc_alias_definitions.alias_definition_name%type;
		v_approval_period_name 	hxc_approval_period_sets.name%type;
		v_rec_period_name 	hxc_recurring_periods.name%type;
		v_layout_name hxc_layouts_vl.display_layout_name%type;		
		v_style_name hxc_approval_styles.name%type;


		   CURSOR get_segments( p_code   VARCHAR2)
			   IS SELECT usage.application_column_name,
						 tl.form_left_prompt,
						 usage.flex_value_set_id
					FROM FND_DESCR_FLEX_COLUMN_USAGES usage, 
						 FND_DESCR_FLEX_COL_USAGE_TL tl
				   where tl.application_id = 809 
					 AND tl.DESCRIPTIVE_FLEXFIELD_NAME = 'OTC PREFERENCES'
					 AND tl.descriptive_flex_context_code = p_code
					 AND usage.application_id = tl.application_id
					 AND usage.descriptive_flexfield_name = tl.descriptive_flexfield_name
					 AND usage.DESCRIPTIVE_FLEX_CONTEXT_CODE = tl.DESCRIPTIVE_FLEX_CONTEXT_CODE
					 AND usage.APPLICATION_COLUMN_NAME = tl.APPLICATION_COLUMN_NAME
					 AND tl.language = 'US'
				   ORDER BY TO_NUMBER(REPLACE(usage.application_column_name,'ATTRIBUTE'));

		

		BEGIN
			OPEN get_segments(p_pref_row.preference_code);
			LOOP
			   FETCH get_segments INTO l_column,
									   l_display,
									   l_vset;
			   EXIT WHEN get_segments%NOTFOUND;
			   IF l_vset IS NOT NULL AND
				 NOT g_vset_query.EXISTS(l_vset)
			   THEN
				  g_vset_query(l_vset) := get_vset_query(l_vset);
			   END IF;
			   IF l_vset IS NULL
			   THEN
				  l_vset := -1;
				  g_vset_query(l_vset) := NULL;
			   END IF; 
			   
			   CASE l_column 
					WHEN 'ATTRIBUTE1' THEN
							if p_pref_row.attribute1 is not null then
								  l_o(l_display||': ');
								  CASE p_pref_row.preference_code
									WHEN  'TS_PER_APPLICATION_SET' then										
											select NAME into v_entity_group_name from hxc_entity_groups 
													where entity_type = 'TIME_RECIPIENTS'
													and entity_group_id = p_pref_row.attribute1;
											l_o(v_entity_group_name);
																
									WHEN 'TC_W_TCRD_ALIASES' then										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute1;
											l_o(v_alias_def_name);							
																
									WHEN 'TS_PER_APPROVAL_PERIODS' THEN										
											select name into v_approval_period_name 
												from hxc_approval_period_sets 
												where approval_period_set_id = p_pref_row.attribute1;
											l_o(v_approval_period_name);								
																	
									WHEN 'TC_W_TCRD_PERIOD' THEN										
											select name into v_rec_period_name 
												from hxc_recurring_periods 
												where recurring_period_id = p_pref_row.attribute1;
											l_o(v_rec_period_name);									
																	
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute1;
											l_o(v_layout_name);									
																						
									WHEN 'TS_PER_TIME_ENTRY_RULES' THEN										
											select name into v_entity_group_name
												from hxc_entity_groups
												where entity_type = 'TIME_ENTRY_RULES'
												and entity_group_id = p_pref_row.attribute1;
											l_o(v_entity_group_name);									
																			
									WHEN 'TS_PER_APPROVAL_STYLE' THEN										
											Select name into v_style_name 
												from hxc_approval_Styles 
												where approval_Style_id = p_pref_row.attribute1;
											l_o(v_style_name);									
																	
									WHEN 'TS_PER_RETRIEVAL_RULES' THEN										
											select name into v_entity_group_name
												from hxc_entity_groups
												where entity_type = 'RETRIEVAL_RULES'
												and entity_group_id = p_pref_row.attribute1;
											l_o(v_entity_group_name);									
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute1;								
											l_o(v_alias_def_name);									
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute1;														
											l_o(v_entity_group_name);			
										
									ELSE
										l_o(p_pref_row.attribute1||' ');				  
								  END CASE;
								  l_o('<br>');
							end if;  
					WHEN 'ATTRIBUTE2'   THEN
						if p_pref_row.attribute2 is not null then
								l_o(l_display||': ');
								CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' then										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute2;
											l_o(v_alias_def_name);							
																
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute2;
											l_o(v_layout_name);									
										
									WHEN 'TS_PER_APPROVAL_STYLE' THEN										
											Select name into v_style_name 
												from hxc_approval_Styles 
												where approval_Style_id = p_pref_row.attribute2;
											l_o(v_style_name);									
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute2;								
											l_o(v_alias_def_name);									
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute2;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute2||' ');				  
								  END CASE;
								  l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE3'   THEN
						if p_pref_row.attribute3 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute3;
											l_o(v_alias_def_name);	
										
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute3;
											l_o(v_layout_name);
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute3;								
											l_o(v_alias_def_name);									
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute3;														
											l_o(v_entity_group_name);									
										
									ELSE	
										l_o(p_pref_row.attribute3||' ');				  
									END CASE;
									l_o('<br>');
						end if;			
					WHEN 'ATTRIBUTE4'   THEN
						if p_pref_row.attribute4 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute4;
											l_o(v_alias_def_name);	
										
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute4;
											l_o(v_layout_name);
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute4;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute4;														
											l_o(v_entity_group_name);							
										
									ELSE
										l_o(p_pref_row.attribute4||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE5'   THEN
						if p_pref_row.attribute5 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute5;
											l_o(v_alias_def_name);	
										
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute5;
											l_o(v_layout_name);
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute5;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute5;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute5||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE6'   THEN
						if p_pref_row.attribute6 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
										WHEN 'TC_W_TCRD_ALIASES' THEN											
												select alias_definition_name into v_alias_def_name 
													from hxc_alias_definitions 
													where alias_definition_id = p_pref_row.attribute6;
												l_o(v_alias_def_name);		
											
										WHEN 'TC_W_TCRD_LAYOUT' THEN											
												select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute6;
												l_o(v_layout_name);
											
										WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN											
												select alias_definition_name into v_alias_def_name 
													from hxc_alias_definitions 
													where alias_definition_id =  p_pref_row.attribute6;								
												l_o(v_alias_def_name);
											
										WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute6;														
											l_o(v_entity_group_name);									
										
										ELSE
											l_o(p_pref_row.attribute6||' ');				  
										END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE7'   THEN
						if p_pref_row.attribute7 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES'  THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute7;
											l_o(v_alias_def_name);		
										
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute7;
											l_o(v_layout_name);
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute7;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute7;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute7||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE8'   THEN
						if p_pref_row.attribute8 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute8;
											l_o(v_alias_def_name);	
										
									WHEN 'TC_W_TCRD_LAYOUT' THEN										
											select display_layout_name into v_layout_name
											from hxc_layouts b, hxc_layouts_tl t
											where b.layout_id=t.layout_id
											and language='US'
											and b.layout_id = p_pref_row.attribute8;
											l_o(v_layout_name); 
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute8;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute8;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute8||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE9'   THEN
						if p_pref_row.attribute9 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute9;
											l_o(v_alias_def_name);		
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute9;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute9;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute9||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE10'  THEN
						if p_pref_row.attribute10 is not null then
									l_o(l_display||': ');
									CASE p_pref_row.preference_code
									WHEN 'TC_W_TCRD_ALIASES' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id = p_pref_row.attribute10;
											l_o(v_alias_def_name);		
										
									WHEN 'TK_TCARD_ATTRIBUTES_DEFINITION' THEN										
											select alias_definition_name into v_alias_def_name 
												from hxc_alias_definitions 
												where alias_definition_id =  p_pref_row.attribute10;								
											l_o(v_alias_def_name);
										
									WHEN 'TC_W_PUBLIC_TEMPLATE' THEN										
											select name into v_entity_group_name 
												from hxc_entity_groups 
												where entity_group_id = p_pref_row.attribute10;														
											l_o(v_entity_group_name);									
										
									ELSE
										l_o(p_pref_row.attribute10||' ');				  
									END CASE;
									l_o('<br>');
						end if;
					WHEN 'ATTRIBUTE11'  THEN
							  if p_pref_row.attribute11 is not null then
							  l_o(l_display||' '||p_pref_row.attribute11||'<br>');
							  end if;
					WHEN 'ATTRIBUTE12'  THEN
							  if p_pref_row.attribute12 is not null then
							  l_o(l_display||' '||p_pref_row.attribute12||'<br>');
							  end if;
					WHEN 'ATTRIBUTE13'  THEN
							  if p_pref_row.attribute13 is not null then
							  l_o(l_display||' '||p_pref_row.attribute13||'<br>');
							  end if;
					WHEN 'ATTRIBUTE14'  THEN
							  if p_pref_row.attribute14 is not null then
							  l_o(l_display||' '||p_pref_row.attribute14||'<br>');
							  end if;
					WHEN 'ATTRIBUTE15'  THEN
							  if p_pref_row.attribute15 is not null then
							  l_o(l_display||' '||p_pref_row.attribute15||'<br>');
							  end if;
					WHEN 'ATTRIBUTE16'  THEN
							  if p_pref_row.attribute16 is not null then
							  l_o(l_display||' '||p_pref_row.attribute16||'<br>');
							  end if;
					WHEN 'ATTRIBUTE17'  THEN
							  if p_pref_row.attribute17 is not null then
							  l_o(l_display||' '||p_pref_row.attribute17||'<br>');
							  end if;
					WHEN 'ATTRIBUTE18'  THEN
							  if p_pref_row.attribute18 is not null then
							  l_o(l_display||' '||p_pref_row.attribute18||'<br>');
							  end if;
					WHEN 'ATTRIBUTE19'  THEN
							  if p_pref_row.attribute19 is not null then
							  l_o(l_display||' '||p_pref_row.attribute19||'<br>');
							  end if;
					WHEN 'ATTRIBUTE20'  THEN
							  if p_pref_row.attribute20 is not null then
							  l_o(l_display||' '||p_pref_row.attribute20||'<br>');
							  end if;
					WHEN 'ATTRIBUTE21'  THEN
							  l_o(l_display||' '||p_pref_row.attribute21||'<br>');
					WHEN 'ATTRIBUTE22'  THEN
							  l_o(l_display||' '||p_pref_row.attribute22||'<br>');
					WHEN 'ATTRIBUTE23'  THEN
							  l_o(l_display||' '||p_pref_row.attribute23||'<br>');
					WHEN 'ATTRIBUTE24'  THEN
							  l_o(l_display||' '||p_pref_row.attribute24||'<br>');
					WHEN 'ATTRIBUTE25'  THEN
							  l_o(l_display||' '||p_pref_row.attribute25||'<br>');
					WHEN 'ATTRIBUTE26'  THEN
							  l_o(l_display||' '||p_pref_row.attribute26||'<br>');
					WHEN 'ATTRIBUTE27'  THEN
							  l_o(l_display||' '||p_pref_row.attribute27||'<br>');
					WHEN 'ATTRIBUTE28'  THEN
							  l_o(l_display||' '||p_pref_row.attribute28||'<br>');
					WHEN 'ATTRIBUTE29'  THEN
							  l_o(l_display||' '||p_pref_row.attribute29||'<br>');
					WHEN 'ATTRIBUTE30'  THEN
							  l_o(l_display||' '||p_pref_row.attribute30||'<br>');
					ELSE
							   null;
					END CASE;
				
			END LOOP;
			CLOSE get_segments;
		EXCEPTION
		when NO_DATA_FOUND then
			l_o('<br>No data found<br>');
		when others then			  
			  l_o('<br>'||sqlerrm ||' occurred in test');
			  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1<br>');
		END get_segment_name;


		BEGIN
			l_o('<div id="page4" style="display: none;">');
			timp := dbms_utility.get_time;
			select count(1) into v_rows from per_all_people_f where person_id = '&&4';
			if v_rows=0 then
				:e4:=:e4+1;
				l_o('<div class="diverr">This person ID is incorrect<br></div>');
			else				
				
				select * into v_person_name from (select full_name from PER_ALL_PEOPLE_F where person_id = '&&4' order by 1 desc)
				where rownum<2;
				--select sysdate into v_pref_date from dual;
				
				l_o(' <a name="preference"></a>');
				l_o('<div class="divSection">');
				l_o('<div class="divSectionTitle">');
				l_o('<div class="left"  id="emp" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">Employee Preferences: '); 
				l_o('</div><div class="right" font style="font-weight: normal; font-size: small;" align="right" color="#FFFFFF">'); 
				l_o('<a class="detail" onclick="openall();" href="javascript:;">');
				l_o('<font color="#FFFFFF">&#9654; Expand All Checks</font></a>'); 
				l_o('<font color="#FFFFFF">&nbsp;/ &nbsp; </font><a class="detail" onclick="closeall();" href="javascript:;">');
				l_o('<font color="#FFFFFF">&#9660; Collapse All Checks</font></a> ');
				l_o('</div><div class="clear"></div></div><br>');
	
				l_o('<div class="divok">');
				l_o('# Preferences for person: <span class="sectionblue">'||l_param2||'</span>');	
				l_o(' - <span class="sectionblue">"'|| v_person_name||'"</span><br>');
				l_o('# Preferences effective at: <span class="sectionblue">'||v_date_pref||'</span></div><br>');
		
				l_o('<DIV class=divItem>');
				l_o('<DIV id="s1sql36b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql36'');" href="javascript:;">&#9654; Preferences linked to the Timecard Owner</A></DIV>');
		
				l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql36" style="display:none" ><tr><td>');
				:n := dbms_utility.get_time;
				
				l_o(' <table><TR><TH bordercolor="#DEE6EF">');
				l_o('     <B>Preference Nodes linked to the Timecard Owner</B></font></TD>');
				
				l_o(' </TR>');
				l_o(' <TR>');
				l_o(' <TH><B>Rule Name </B></TD>');
				l_o(' <TH><B>Node Name </B></TD>');
				l_o(' <TH><B>Precedence</B></TD>');
				l_o(' <TH><B>Link By</B></TD>');
				l_o(' <TH><B>Link To</B></TD><TH><B>Start Date</B></TD></tr>');
				
				open c_preference;
				loop
					  fetch c_preference into v_node_name,v_rule_name,v_precedence,v_link_by,v_linked_to,v_sd;
					  EXIT WHEN  c_preference%NOTFOUND;
					  l_o('<TR><TD>'||v_rule_name||'</TD>'||chr(10)||'<TD>'||v_node_name||'</TD>'||chr(10));
					  l_o('<TD>'||v_precedence||'</TD>'||chr(10)||'<TD>'||v_link_by||'</TD>'||chr(10)||'<TD>'||v_linked_to||chr(10)||'<TD>'||v_sd||'</TD> </TR>'||chr(10));	  
				end loop;
				close c_preference;
				
				:n := (dbms_utility.get_time - :n)/100;
				l_o(' <TR><TH COLSPAN=4 bordercolor="#DEE6EF">');
				l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
				l_o(' </TABLE> </div> ');
	
			
	
				l_o('</td></tr>');
				
				begin
				hxc_preference_evaluation.resource_preferences(p_resource_id => '&4',
															p_start_evaluation_date  => v_date_pref,
															p_end_evaluation_date    => v_date_pref,
															p_pref_table  => l_pref_table);
				EXCEPTION
				when others then
				  l_o('<br>'||sqlerrm ||' occurred in test');
				  l_o('<br>Procedure hxc_preference_evaluation.resource_preferences failed for this person');
				  l_o('<br>Please report the above error as comment in OTL Analyzer Note 1580490.1 <br>');
				end;
				
				l_o('<tr><td><b><span class="sectionblue">Note: Link by responsibility branches are not displayed here currently.<br>Until this is fixed, please request screenshots for Link By Responsibility branches from the preferences form as it will not appear here if customer is using link by responsibility.</b></span></td></tr>');				
				l_o('<tr><td>');	
				l_o(' <table><TR><TH bordercolor="#DEE6EF">');
				l_o('     <B>Preferences linked to the Timecard Owner</B></font></TD>');
				
				l_o(' </TR>');
				l_o(' <TR>');
				l_o(' <TH><B>Rule Name</B></TD>');
				l_o(' <TH><B>Node Name</B></TD>');
				l_o(' <TH><B>Preference Code</B></TD>');
				l_o(' <TH><B>Preference Name </B></TD>');
				l_o(' <TH><B>Segment</B></TD></TR>');
				
				:n := dbms_utility.get_time;	
				
				 IF l_pref_table.COUNT > 0
						 THEN
							FOR i IN l_pref_table.FIRST..l_pref_table.LAST
							LOOP
							   SELECT count(distinct rule_name) into v_rows
								  from hxc_resource_all_elig_pref_v v1
										 WHERE v1.rule_evaluation_order =
											   (select max(v2.rule_evaluation_order)
												  from hxc_resource_all_elig_pref_v v2
												 where v1.resource_id = v2.resource_id
												   and v1.preference_code = v2.preference_code
												   and v2.rule_name in
													   (select name
														  from hxc_resource_rules
														 where sysdate between start_date and end_date))
										   and v1.resource_id = '&&4'
										   and v1.preference_code = l_pref_table(i).preference_code;
							   if v_rows=1 then	   								
									SELECT distinct rule_name into v_rule_name
										  from hxc_resource_all_elig_pref_v v1
										 WHERE v1.rule_evaluation_order =
											   (select max(v2.rule_evaluation_order)
												  from hxc_resource_all_elig_pref_v v2
												 where v1.resource_id = v2.resource_id
												   and v1.preference_code = v2.preference_code
												   and v2.rule_name in
													   (select name
														  from hxc_resource_rules
														 where sysdate between start_date and end_date))
										   and v1.resource_id = '&&4'
										   and v1.preference_code = l_pref_table(i).preference_code;

								    l_o('<TR><TD>'||v_rule_name||'</TD>');
								    select count(distinct pref_hierarchy_name) into v_rows
										from hxc_resource_rules_v where name = v_rule_name
										and pref_hierarchy_name is not null;
									if v_rows=1 then
										select distinct pref_hierarchy_name into v_pref_hierarchy_name
											from hxc_resource_rules_v where name = v_rule_name
											and pref_hierarchy_name is not null;
										l_o('<TD>'||v_pref_hierarchy_name||'</TD><TD>');
									else
										l_o('<TD>-</TD><TD>');
									end if;
								   
							   else
									l_o('<TR><TD>-</TD><TD>-</TD><TD>');
							   end if;
							   l_o(l_pref_table(i).preference_code||'</TD><TD>');
							   l_o(get_context_name(l_pref_table(i).preference_code));
							   l_o('</TD><TD>');
							   get_segment_name(l_pref_table(i));
							   l_o('</TD></TR>');
							   CASE l_pref_table(i).preference_code 
									WHEN 'TS_PER_APPLICATION_SET' then
										v_per_as:=l_pref_table(i).attribute1;
									WHEN 'TS_PER_APPROVAL_PERIODS' then
										v_per_ap:=l_pref_table(i).attribute1;
									WHEN 'TS_PER_APPROVAL_STYLE' then
										v_per_astyle:=l_pref_table(i).attribute1;									
									WHEN 'TS_PER_TIME_ENTRY_RULES' then
										v_per_ter:=l_pref_table(i).attribute1;
									WHEN 'TC_W_RULES_EVALUATION' then 
										v_type_timecard:=l_pref_table(i).attribute1;									
									WHEN 'TS_ABS_PREFERENCES' then 
										v_type_absences:=l_pref_table(i).attribute1;
										v_retrieval_rule:= l_pref_table(i).attribute4;									
									WHEN 'TS_PER_RETRIEVAL_RULES' then
										v_retrival_rules:=l_pref_table(i).attribute1;
									WHEN 'TC_W_TCRD_ALIASES' then										
											pref(1):= l_pref_table(i).attribute1;
											pref(2):= l_pref_table(i).attribute2;
											pref(3):= l_pref_table(i).attribute3;
											pref(4):= l_pref_table(i).attribute4;
											pref(5):= l_pref_table(i).attribute5;
											pref(6):= l_pref_table(i).attribute6;
											pref(7):= l_pref_table(i).attribute7;
											pref(8):= l_pref_table(i).attribute8;
											pref(9):= l_pref_table(i).attribute9;
											pref(10):= l_pref_table(i).attribute10;												
									ELSE
										null;
									END CASE;							  
							  
							END LOOP;
				END IF;
				
				
				
				:n := (dbms_utility.get_time - :n)/100;
				l_o(' <TR> <TD bordercolor="#DEE6EF">');
				l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
				l_o(' </TABLE> </td></tr> </table></div> ');
				
				issue:=FALSE;
				
				if upper(v_type_timecard) like '%Y%' and upper(v_type_absences) like '%Y%' and (:rup_level_n not in ('19193000','20000288','21980909','21507777'))then
					:e4:=:e4+1;
					l_o('<div class="diverr">');
					issue:=TRUE;
					l_o('<div class="diverr" id="sigte1"><img class="error_ico"><font color="red">Error:</font> For this employee, Rules Evaluation preference is enabled with Absence Integration. ');
					l_o('Absence Integration cannot work when Rules Evaluation (OTLR) is enabled. Disable Absence Integration or Rules Evaluation preference for any of them to work.</div><br>'	);
				end if;	
				
				select count(1) into v_rows from   fnd_profile_options po,
						   fnd_profile_option_values pov,
						   fnd_profile_options_vl n         
					where  po.profile_option_name ='HR_SCH_BASED_ABS_CALC'
					and    pov.application_id = po.application_id
					and    po.profile_option_name = n.profile_option_name
					and    pov.profile_option_id = po.profile_option_id
					and    pov.profile_option_value='Y';
				if v_rows>0  and upper(v_type_absences) like '%Y%' then
					if not issue then
						:e4:=:e4+1;
						l_o('<div class="diverr">');
						issue:=TRUE;
					end if;
					:w4:=:w4+1;
					l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>You have Absence Integration with OTL enabled and profile "HR: Schedule Based Absence Calculation" set to Yes at one/several levels. ');
					l_o('This can cause imported absence entries from HR not to appear in the OTL Timecard. Ensure HR: Schedule Based Absence Calculation is set to No for the profile level used.</div><br>');
				end if;
				
				if upper(v_type_absences) like '%Y%' then
							select count(distinct STATUS) into v_rows
								FROM hxc_retrieval_rule_comps_v 
								WHERE RETRIEVAL_RULE_ID in 
								(select retrieval_rule_id from hxc_retrieval_rule_grp_comps_v WHERE retrieval_rule_group_id=v_retrival_rules);
							if v_rows=1 then
								SELECT distinct STATUS into v_status
									FROM hxc_retrieval_rule_comps_v 
									WHERE RETRIEVAL_RULE_ID in 
									(select retrieval_rule_id from hxc_retrieval_rule_grp_comps_v WHERE retrieval_rule_group_id=v_retrival_rules);
								if upper(v_retrieval_rule) like '%RRG%' and upper(v_status) <> 'APPROVED' then
									if not issue then
										l_o('<div class="divok">');
										issue:=TRUE;
									end if;
									l_o('Reminder: Non-Approved Absences can be retrieved from/to your Timecard. ');
									l_o('To fix that, change "Retrieval Rule for Absences" segment of Absence Integration Preference to "Approved".<br>');
									issue_retrieval:=TRUE;
								end if;
							end if;
							

							if upper(v_retrieval_rule) not like '%APPROVED%' and not issue_retrieval then
								if not issue then
									l_o('<div class="divok">');
									issue:=TRUE;
								end if;
								l_o(' Reminder: Non-Approved Absences can be retrieved from/to your Timecard. ');
								l_o('To fix that, change "Retrieval Rule for Absences" segment of Absence Integration Preference to "Approved".<br>');
							end if;
				end if;
				if issue then
					l_o('</div><br>');
				end if;
				
				
				l_o('<br><DIV class=divItem>');
				l_o('<DIV id="s1sql90b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql90'');" href="javascript:;">&#9654; Preference Setups</A></DIV>');
				l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql90" style="display:none" >');
				:n := dbms_utility.get_time;
				l_o(' <TR><TD bordercolor="#DEE6EF">');
				 if v_per_as is not null then
				 select count(1) into v_rows from HXC_APPLICATION_SET_COMPS_V  where application_set_id = v_per_as;
				 if v_rows>0 then
				 sqlTxt := 'select * from HXC_APPLICATION_SET_COMPS_V  where application_set_id =' || v_per_as;
				 run_sql('Application Set', sqltxt);
				 else
				 l_o('<br><span class="BigPrint">Application Set</span><br>0 Row Selected<br>');
				 end if;
				 end if;
				 
				 if v_per_ap is not null then
				 select count(1) into v_rows from hxc_approval_period_comps_V  where approval_period_set_id = v_per_ap;
				 if v_rows>0 then
					 sqlTxt := 'select * from hxc_approval_period_comps_V where approval_period_set_id =' || v_per_ap;
					 run_sql('Approval Period', sqltxt);
					 
					 select count(1) into v_rows from hxc_recurring_periods where recurring_period_id in (select recurring_period_id from hxc_approval_period_comps_V  where approval_period_set_id = v_per_ap);
					 if v_rows>0 then
					 sqlTxt := 'select * from hxc_recurring_periods where recurring_period_id in (select recurring_period_id from hxc_approval_period_comps_V  where approval_period_set_id = ' || v_per_ap || ')';
					 run_sql('Timecard Period of the Approval Period', sqltxt);
					 else
					 l_o('<br><span class="BigPrint">Timecard Period of the Approval Period</span><br>0 Row Selected<br>');
					 end if;					 
				 else
				 l_o('<br><span class="BigPrint">Approval Period</span><br>0 Row Selected<br>');
				 end if;				 
				 end if;
				 

				 if v_per_astyle is not null then
				 select count(1) into v_rows from HXC_APPROVAL_STYLES  where approval_style_id = v_per_astyle;
				 if v_rows>0 then
				 sqlTxt := 'select * from HXC_APPROVAL_STYLES where approval_style_id =' || v_per_astyle;
				 run_sql('Approval Style Header', sqltxt);
				 else
				 l_o('<br><span class="BigPrint">Approval Style Header</span><br>0 Row Selected<br>');
				 end if;
				 select count(1) into v_rows from HXC_APPROVAL_COMPS  where approval_style_id = v_per_astyle;
				 if v_rows=0 then
					l_o('<br><span class="BigPrint">Approval Style Components</span><br>0 Row Selected<br>');
				 elsif v_rows<=50 then
					 sqlTxt := 'select * from HXC_APPROVAL_COMPS where approval_style_id =' || v_per_astyle;
					 run_sql('Approval Style Components', sqltxt);
				 else
					 sqlTxt := 'select APPROVAL_MECHANISM, count(1) Count_of_records from HXC_APPROVAL_COMPS where approval_style_id =' || v_per_astyle|| ' group by APPROVAL_MECHANISM';
					 run_sql('Approval Style Components', sqltxt);				 
				 end if;
				 end if;
				 
				 select count(1) into v_rows from hxc_alias_definitions_v where alias_definition_id in (nvl(pref(1),-1),nvl(pref(2),-1),nvl(pref(3),-1),nvl(pref(4),-1),nvl(pref(5),-1),nvl(pref(6),-1),nvl(pref(7),-1),nvl(pref(8),-1),nvl(pref(9),-1),nvl(pref(10),-1));
				 if v_rows>0 then
				 sqlTxt := 'select * from hxc_alias_definitions_v where alias_definition_id in(' || nvl(pref(1),-1) || ','|| nvl(pref(2),-1)|| ','|| nvl(pref(3),-1)|| ','||nvl(pref(4),-1) || ','|| nvl(pref(5),-1)|| ','|| nvl(pref(6),-1)|| ','||nvl(pref(7),-1) || ','|| nvl(pref(8),-1)|| ','|| nvl(pref(9),-1)|| ','|| nvl(pref(10),-1)||')';
				 run_sql('Alternate Name Header', sqltxt);
				 else
				 l_o('<br><span class="BigPrint">Alternate Name Header</span><br>0 Row Selected<br>');
				 end if;
				 
				 select count(1) into v_rows from hxc_alias_values_v where alias_definition_id in (nvl(pref(1),-1),nvl(pref(2),-1),nvl(pref(3),-1),nvl(pref(4),-1),nvl(pref(5),-1),nvl(pref(6),-1),nvl(pref(7),-1),nvl(pref(8),-1),nvl(pref(9),-1),nvl(pref(10),-1));
				 if v_rows>0 then
				 sqlTxt := 'select * from hxc_alias_values_v  where alias_definition_id in(' || nvl(pref(1),-1) || ','|| nvl(pref(2),-1)|| ','|| nvl(pref(3),-1)|| ','||nvl(pref(4),-1) || ','|| nvl(pref(5),-1)|| ','|| nvl(pref(6),-1)|| ','||nvl(pref(7),-1) || ','|| nvl(pref(8),-1)|| ','|| nvl(pref(9),-1)|| ','|| nvl(pref(10),-1)||')';
				 run_sql('Alternate Name Values', sqltxt);
				 else
				 l_o('<br><span class="BigPrint">Alternate Name Values</span><br>0 Row Selected<br>');
				 end if;
				 
				if v_per_ter is not null then
				select count(1) into v_rows from Hxc_Entity_Group_Comps where entity_group_id =  v_per_ter;
				if v_rows>0 then
				sqlTxt := 'select entity_group_id TER_Group_ID, (select name from hxc_entity_groups where entity_group_id = grc.entity_group_id) TER_Group_Name, 
							entity_id TER_ID, (select name from hxc_time_entry_rules where time_entry_rule_id = grc.entity_id) TER_Name
							from Hxc_Entity_Group_Comps grc	where grc.entity_group_id = ' || v_per_ter;
				run_sql('Time Entry Rule Group', sqltxt);
				else
				 l_o('<br><span class="BigPrint">Time Entry Rule Group</span><br>0 Row Selected<br>');
				 end if;
				
				select count(1) into v_rows from hxc_time_entry_rules_v TER, Hxc_Entity_Group_Comps grc
						where ter.time_entry_rule_id = grc.entity_id and grc.entity_group_id = v_per_ter;				
				if v_rows>0 then
				sqlTxt := 'select * from hxc_time_entry_rules_v TER, Hxc_Entity_Group_Comps grc
						where ter.time_entry_rule_id = grc.entity_id and grc.entity_group_id =' || v_per_ter;
				run_sql('Time Entry Rules', sqltxt);
				else
				 l_o('<br><span class="BigPrint">Time Entry Rules</span><br>0 Row Selected<br>');
				 end if;
				end if; 
				:n := (dbms_utility.get_time - :n)/100;
				l_o(' </td></tr><TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
				l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
				l_o(' </TABLE> </div> ');
				
				l_o('<br><DIV class=divItem>');
				l_o('<DIV id="s1sql74b" class=divItemTitle><A class=detail onclick="displayItem(this,''s1sql74'');" href="javascript:;">&#9654; Elements in Alternate Names not linked to Employee</A></DIV>');
				
				l_o(' <TABLE width="95%" border="1" cellspacing="0" cellpadding="2" id="s1sql74" style="display:none" >');
				:n := dbms_utility.get_time;
				
				l_o(' <TR><TD bordercolor="#DEE6EF">');
				l_o('     <B>Elements in Alternate Names not linked to Employee</B></font></TD>');
				
				l_o(' </TR>');
				l_o(' <TR>');
				l_o(' <TH><B>Issues </B></TD></TR>');
	
				issue:=FALSE;
				
				select count(1) into v_rows from per_all_assignments_f 
				where person_id = '&&4' and sysdate between effective_start_date and effective_end_date
				and primary_flag = 'Y' and assignment_type IN ('E', 'C');
				if v_rows=1 then
						select assignment_id into v_assignment_id from per_all_assignments_f 
						where person_id = '&&4' and sysdate between effective_start_date and effective_end_date
						and primary_flag = 'Y' and assignment_type IN ('E', 'C');
						
						
						for i in 1..10 
						loop
							if pref(i) is not null then			
								select count(1) into v_rows from hxc_alias_definitions where alias_definition_id = pref(i);
								if v_rows=1 then
											select ALIAS_DEFINITION_NAME into v_alias_definition from hxc_alias_definitions where alias_definition_id = pref(i);						
											open element(pref(i));
											loop
												fetch element into v_element_type_id;
												EXIT WHEN element%NOTFOUND;
												select count(1) into v_rows from pay_element_types_f 
													where element_type_id=v_element_type_id
													and sysdate between effective_start_date and effective_end_date;
											
												if v_rows>0 then
													v_is_ok:=FALSE;
													open element_link (v_element_type_id);
													loop
														fetch element_link into v_element_link_id;
														EXIT WHEN element_link%NOTFOUND;
														hr_utility.trace_off();
														Elig:= hr_entry.Assignment_eligible_for_link(p_assignment_id => v_assignment_id,
																									p_element_link_id => v_element_link_id,
																									p_effective_date => sysdate);
														if Elig='Y' then
															v_is_ok:=TRUE;
															EXIT;
														end if;
													end loop;
													close element_link;						
													if not v_is_ok then
														issue:=TRUE;
														select count(distinct element_name) into v_rows from pay_element_types_f where element_type_id = v_element_type_id 
															and sysdate between effective_start_date and effective_end_date;
														if v_rows=1 then															
																select distinct element_name into v_element_name 
																	from pay_element_types_f where element_type_id = v_element_type_id 
																	and sysdate between effective_start_date and effective_end_date;
															
																l_o('<TR><TD>Person "'||v_person_name||'" is not linked to Element "'||v_element_name||'" and ');
																l_o('so they cannot use the Alternate Name Definition "'||v_alias_definition||'".</TD></TR>');						
														end if;
													end if;										
												end if;
											end loop;
											close element;
								end if;
							end if;	
						end loop;
				end if;
				
				
				:n := (dbms_utility.get_time - :n)/100;
				l_o(' <TR><TH COLSPAN=1 bordercolor="#DEE6EF">');
				l_o('<i> Elapsed time '||:n|| ' seconds</i> </font></TD> </TR> ');
				l_o(' </TABLE> </div> ');
				
								
				if issue then
					:e4:=:e4+1;
					l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font>  You have some Alternate Name Definition linked to people while some Elements in that Group not linked to those people. ');
					l_o('For more information please refer to <a href="https://support.oracle.com/epmos/faces/DocumentDisplay?parent=ANALYZER\&sourceId=1580490.1\&id=179780.1" target="_blank">Doc ID 179780.1</a> ');
					l_o('Select SUBMIT for the SS Timecard and Receive Error Message about Element Link.</div><br>');
					
				else
					l_o('<div class="divok1"><img class="check_ico">OK! No issue found.</div><br>');
				end if;	
				l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		
				timp := round((dbms_utility.get_time - timp)/100/60,4);
				l_o('<br><br><i> Elapsed time '||:n|| ' minutes</i> <br> ');
				
				l_o('</div><br/>');	

			end if;
			
		end;
		l_o('</div>');
end;
		
end if;		-- end preference section

-- Display HXT output
if upper('&&7') = 'Y' then
-- ************************
-- *** HXT_TC.. 
-- ************************
		l_o('<div id="page5" style="display: none;">');
		:n := dbms_utility.get_time;
		l_o(' <a name="hxt"></a>');
		l_o('<div class="divSection">');
		l_o('<div class="divSectionTitle">');
		l_o('<div class="left"  id="hxt" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">HXT Timecard (OTLR/PUI): '); 
		l_o('</div></div><br>');
	
		l_o('<div class="divok">Tim_id of this timecard: <span class="sectionblue">'||l_param4||'</span>');
		if LENGTH(TRIM(TRANSLATE('&&8', ' +-.0123456789', ' '))) is not null then
				:e5:=:e5+1;
				l_o('<div class="diverr"> No timecard for this tim_id.<br></div></div><br>');
		else
		
		select count(1) into v_rows from per_all_people_f where sysdate between effective_start_date and effective_end_date
				and person_id in (select for_person_id from HXT_TIMECARDS_F where id = ('&&8'));
		if v_rows=1 then
			select full_name into v_person_name from per_all_people_f where sysdate between effective_start_date and effective_end_date
				and person_id in (select for_person_id from HXT_TIMECARDS_F where id = ('&&8'));
			l_o(' for Employee: <span class="sectionblue">'||v_person_name||'</span>');
		end if;
		l_o('</div><br>');
		
		
		
		select count(1) into v_rows from HXT_TIMECARDS_F where id = '&&8' ;
		if v_rows=0 then
				:e5:=:e5+1;
				l_o('<div class="diverr"> No timecard for this tim_id.<br></div>');
		else
				Display_Table('HXT_TIMECARDS_F',             null, 'where id = (''&&8'')', null, 'Y');
				
				if v_rows=1 then
						l_o('<div class="divok">');
						select Auto_Gen_Flag into v_Auto_Gen_Flag from HXT_TIMECARDS_F where id = '&&8' ;
						case upper(v_Auto_Gen_Flag) 
							when 'A' then
								l_o('<span class="sectionblue"> This timecard was Auto Generated.</span><br>');
							when 'C' then
								l_o('<span class="sectionblue"> This Timecard was Auto Generated then Modified (Changed). </span><br>');	
							when 'U' then
								l_o('<span class="sectionblue"> This Timecard was Maually Created then Modified (Changed). </span><br>');
							when 'M' then
								l_o('<span class="sectionblue"> This Timecard was Manually created. </span><br>');
							when 'S' then
								l_o('<span class="sectionblue"> This Timecard was transferred from HXC (SS or TK). </span><br>');
							when 'T' then
								l_o('<span class="sectionblue"> This Timecard was created using TimeClock API. </span><br>');
							else
								null;
						end case;
						l_o('</div>');
				end if;
				

				Display_Table('HXT_SUM_HOURS_WORKED_F',      null, 'where tim_id = (''&&8'')', 'order by tim_id, date_worked, effective_end_date', 'Y');
				Display_Table('HXT_DET_HOURS_WORKED_F',      null, 'where tim_id = (''&&8'')', 'order by tim_id, date_worked, effective_end_date', 'Y');
				
				-- HXT_ERRORS_F
				l_o('<a name="HXT_ERRORS_F"></a>');
				Display_Table('HXT_ERRORS_F',                null, 'where tim_id = (''&&8'')', 'order by tim_id', 'Y');
				select count(1) into v_rows from HXT_ERRORS_F where id = '&&8' ;
				if v_rows>0 then
					:e5:=:e5+1;
					l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> This timecard has errors! Please check the concurrent process log file for details and the table above.</div><br>');
				end if;
				
				-- HXT_BATCH_STATES
				Display_Table('HXT_BATCH_STATES',            null, 'where batch_id in (select batch_id from HXT_TIMECARDS_F where id in (''&&8'') union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8''))', 'order by batch_id', 'Y');
				select count(1) into v_rows from HXT_BATCH_STATES where 
						batch_id in 
						(select batch_id from HXT_TIMECARDS_F where id = '&&8' 
						union 
						select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8');
				if v_rows>0 then
						l_o('<div class="divok"> HXT Batch Status is: <br>');
						
						open c_HXT_BATCH_STATES;
						loop
								fetch c_HXT_BATCH_STATES into v_batch_id, v_batch_status;
								EXIT WHEN  c_HXT_BATCH_STATES%NOTFOUND;
								case upper(v_batch_status) 
									when 'H' then
											l_o(' For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o(' </span>: <span class="sectionblue">On Hold (not validated or transferred yet). ');
											l_o('</span>If Batch remains on H status even after "Validate for BEE" was run, please refer to ');
											Show_link('1273067.1'); 
											l_o(' After "Validate For BEE", Batch Remains In Hold Status Even Though No Error Or Warning.<br>');
									when 'VV' then
											l_o(' For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Successfully Validated. </span><br>');
									when 'T' then
											l_o(' For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Successfully Transferred but Not Validated. </span><br>');
									when 'VT' then
											l_o(' For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Successfully Validated and Transferred. </span><br>');
									when 'VE' then
											l_o(' For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Validated with Errors. </span>');
											l_o('Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F">HXT_ERRORS_F</a> table.<br>');
									when 'VW' then
											:w5:=:w5+1;
											l_o('<div class="divwarn" id="sigr10"><img class="warn_ico"><span class="sectionorange">Warning: </span>For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Validated with Warnings. </span>');
											l_o('<img class="warn_ico"><span class="sectionorange">Warning: </span>Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F">HXT_ERRORS_F</a> table.</div><br>');
									when 'W' then
											:w5:=:w5+1;
											l_o('<div class="divwarn" id="sigr11"><img class="warn_ico"><span class="sectionorange">Warning: </span>For Batch_id: <span class="sectionblue">'|| v_batch_id );
											l_o('</span>: <span class="sectionblue">Faced warnings. </span>');
											l_o(' <img class="warn_ico"><span class="sectionorange">Warning: </span>Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F">HXT_ERRORS_F</a> table.</div><br>');
									else
											null;
								end case;
								l_o('Refer to '); 
								Show_link('269988.1'); 
								l_o(' (OTL What Are The Meanings of The Status Values In HXT_BATCH_STATES Table) for all statuses meaning.<br>');						
								
						end loop;
						close c_HXT_BATCH_STATES;
						l_o('</div>');
				end if;



				
				-- PAY_BATCH_HEADERS
				Display_Table('PAY_BATCH_HEADERS',           null, 'where batch_id in (select batch_id from HXT_TIMECARDS_F where id in (''&&8'') union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8''))', 'order by batch_id', 'Y');
				select count(1) into v_rows from HXT_TIMECARDS_F where id = '&&8' ;
				select count(1) into v_rows2 from PAY_BATCH_HEADERS
					where batch_id in 
					(select batch_id from HXT_TIMECARDS_F where id ='&&8' 
					union 
					select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8');
				
				select count(1) into v_rows3 from PAY_BATCH_HEADERS
					where batch_id in 
					(select batch_id from HXT_TIMECARDS_F where id ='&&8' 
					union 
					select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8')
					and batch_status like 'P%';
				if v_rows>0 and (v_rows2=0 or v_rows3>0) then
						:e5:=:e5+1;
						l_o('<div class="diverr" id="sigr4"><img class="error_ico"><font color="red">Error:</font> The Batch was purged while the PUI (HXT) Timecard is still there, please raise a Service Request and refer Oracle Support Engineer to ');
						l_o('internal Doc ID 271895.1 PUI Timecards cannot be Queried - BEE Batch Header has been Purged.</div><br>');
				end if;
						
				if v_rows2>0 then			
						
						-- Explain batch source and batch status
						l_o('<div class="divok">');
						open c_PAY_BATCH_HEADERS;
						loop
								fetch c_PAY_BATCH_HEADERS into v_batch_id, v_batch_status, v_batch_source;
								EXIT WHEN  c_PAY_BATCH_HEADERS%NOTFOUND;
								l_o(' For Batch_id: </span><span class="sectionblue">'|| v_batch_id||':<br> ');
								if v_batch_source like 'OTM%' then
										l_o(' This is an OTLR Batch. ');
								elsif v_batch_source like 'Time Store%' then
										l_o(' This is a Non-OTLR Batch.');
								end if;
								l_o('</span><br> ');
								case upper(v_batch_status) 
									when 'U' then
											l_o('<span class="sectionblue"> This Batch is Unprocessed yet. </span>');									
									when 'V' then
											l_o('<span class="sectionblue"> This Batch is Validated. </span>');
											select status into v_status_hxt_states  
											from HXT_BATCH_STATES where 
											batch_id = v_batch_id and rownum < 2;
											if v_status_hxt_states in ('VV','VW', 'VE', 'H') then
													 :e5:=:e5+1;
													 l_o('<br><div class="diverr" id="sigr5"> Error: This Batch Header was Validated before the HXT Timecard is Transferred to generate the Batch Lines, please first run "Validate for BEE" ');
													 l_o('and "Transfer to BEE" before validating or transferring this batch header. Please also refer to the OTLR to BEE Viewlet ');
													 Show_link('567259.1');
													 l_o(' for the right sequence of steps.</div>');
											end if;

									when 'T' then
											l_o('<span class="sectionblue"> This Batch is Transferred to Element Entries. </span>');
											select status into v_status_hxt_states  
											from HXT_BATCH_STATES where 
											batch_id = v_batch_id and rownum < 2;
											if v_status_hxt_states in ('VV','VW', 'VE', 'H') and v_batch_source like 'OTM%'  then
													 :e5:=:e5+1;
													 l_o('<br><div class="diverr" id="sigr6"> This Batch Header was Transferred before the HXT Timecard is Transferred to generate the Batch Lines, please first run "Validate for BEE" ');
													 l_o('and "Transfer to BEE" before validating or transferring this batch header. Please also refer to the OTLR to BEE Viewlet ');
													 Show_link('567259.1');
													 l_o(' for the right sequence of steps.</div>');										 

											end if; 
									when 'P' then
											:w5:=:w5+1;
											l_o('<div class="divwarn" id="sigr12"> This Batch is Purged. </div>');
											if v_batch_source like 'Time Store%' then
													:e5:=:e5+1;
													l_o('<br><div class="diverr" id="sigr7"> The Batch was purged while the HXC(Self Service/Timekeeper) Timecard is still there, please raise a Service Request ');
													l_o('and refer Oracle Support Engineer to internal Doc ID 290858.1.</div>');
											end if;
									else
											null;
								end case;
								l_o('<br>');					
								
						end loop;
				  close c_PAY_BATCH_HEADERS;
				  
				   -- if Batch_Source has a value other than OTM or TimeStore
				   select count(1) into v_rows from PAY_BATCH_HEADERS
								where batch_id in 
								(select batch_id from HXT_TIMECARDS_F where id ='&&8' 
								union 
								select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = '&&8')
								and  upper(Batch_Source) not in ('OTM','TIME STORE');
						if v_rows>0 then
							l_o(' <div id="sigr13">Reminder: This Batch was not created using OTL Retrieval Processes.<br></div> ');
						end if;
				l_o('</div><br>');
				end if;
				



				Display_Table('PAY_BATCH_LINES',             null, 'where batch_id in (select batch_id from HXT_TIMECARDS_F where id in (''&&8'') union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8'')) and (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8''))', 'order by batch_id', 'Y');
				select count(1) into v_rows  from PAY_BATCH_LINES   where batch_id in 
					(select batch_id from HXT_TIMECARDS_F where id in ('&&8') 
					union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8')) 
					and (assignment_id, element_type_id, date_earned) in 
					(select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8'));
				if v_rows=0 and v_rows2>0 then
						:w5:=:w5+1;
						l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>You need to run Validate for BEE and Transfer to BEE processes to generate the Batch Lines.</div><br>');
				end if;
				if v_rows>0 then
						l_o('<div class="divok">');
						select count(1) into v_rows2  from PAY_BATCH_LINES   where batch_id in 
							(select batch_id from HXT_TIMECARDS_F where id in ('&&8') 
							union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8')) 
							and (assignment_id, element_type_id, date_earned) in 
							(select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8'))
							and batch_line_status in ('U','V');
						select count(1) into v_rows3  from PAY_BATCH_LINES   where batch_id in 
							(select batch_id from HXT_TIMECARDS_F where id in ('&&8') 
							union select retro_batch_id from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8')) 
							and (assignment_id, element_type_id, date_earned) in 
							(select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id = ('&&8'))
							and batch_line_status='T';
						if v_rows=v_rows2 then
							l_o('<span class="sectionblue"> All lines were not transferred to Element Entries.</span><br>');
						elsif v_rows=v_rows3 then
								select count(1) into v_rows4 from HXT_DET_HOURS_WORKED_F 
									where tim_id = ('&&8');
								
								if v_rows=v_rows4 then
									l_o('<span class="sectionblue"> All lines were transferred to Element Entries.</span><br>');
								else 
									:w5:=:w5+1;
									l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Some lines were transferred to Element Entries and some were not.</div><br>');
								end if;							
						end if;
						if v_rows2>0 and v_rows3>0 then
							:w5:=:w5+1;
							l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Some lines were transferred to Element Entries and some were not.</div><br>');
						end if;
						l_o('</div>');
				end if;
				
				Display_Table('PAY_ELEMENT_ENTRIES_F',       null, 'where (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8''))', 'order by assignment_id, date_earned, object_version_number', 'Y');


				Display_Table('PER_ALL_PEOPLE_F',            null, 'where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))', null, 'Y');
				Display_Table('PER_ALL_ASSIGNMENTS_F',       null, 'where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))', null, 'Y');
				Display_Table('HXT_ADD_ASSIGN_INFO_F',       null, 'where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8'')))', 'order by assignment_id, effective_start_date', 'Y');
				-- HXT_ADD_ASSIGN_INFO_F
				select count(1) into v_rows 
						from HXT_ADD_ASSIGN_INFO_F
						where assignment_id in 
						(select assignment_id from PER_ALL_ASSIGNMENTS_F 
						where person_id in (select for_person_id from HXT_TIMECARDS_F where id = ('&&8')))
						and Effective_End_Date = '31-DEC-4712';
				if v_rows>1 then
						:e5:=:e5+1;
						l_o('<div class="diverr"> This person has multiple active Assignment Time Information records. Please delete one from Assignment Time Information form, and refer to ');
						Show_link('1050201.1');
						l_o('Getting "APP-HXT-3948 Additional Information already exists" in an Assignment Time Information Record.</div><br>');
				end if;
				

				
				Display_Table('HXT_EARNING_POLICIES', NULL, 'where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8''))', 'order by id', 'Y');
				
				sqlTxt := 'select Id, h.Element_Type_Id Element_Type_Id, element_name Element_Name, Egp_Id, Seq_No, Name, Egr_Type, Hours, 
							h.Effective_Start_Date Effective_Start_Date, Days, h.Effective_End_Date Effective_End_Date, h.Created_By Created_By, h.Creation_Date Creation_Date, 
							h.Last_Updated_By Last_Updated_By, h.Last_Update_Date Last_Update_Date, h.Last_Update_Login Last_Update_Login
							from HXT_EARNING_RULES h left outer join pay_element_types_f p on (h.element_type_id=p.element_type_id)
							where egp_id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')) order by id';
				run_sql('HXT_EARNING_RULES', sqltxt);
			
									
					
				sqlTxt := 'select h.Id Id, h.Element_Type_Id Element_Type_Id, element_name Element_Name, 
								Name, Organization_Id, h.Created_By Created_By, h.Creation_Date Creation_Date, h.Description Description,
								h.Effective_Start_Date Effective_Start_Date, h.Effective_End_Date Effective_End_Date,
								h.Last_Updated_By Last_Updated_By , h.Last_Update_Date Last_Update_Date,  h.Last_Update_Login Last_Update_Login 
								from HXT_HOLIDAY_CALENDARS  h 
								left outer join pay_element_types_f p on (h.element_type_id=p.element_type_id)
								where id in (select hcl_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8''))) order by id';
				run_sql('HXT_HOLIDAY_CALENDARS', sqltxt);
					
				Display_Table('HXT_HOLIDAY_DAYS', NULL, 'where hcl_id in (select hcl_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))', 'order by id', 'Y');
				
				
				Display_Table('HXT_EARN_GROUP_TYPES', NULL, 'where id in (select egt_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))', 'order by id', 'Y');
					
				sqlTxt := 'select h.Element_Type_Id Element_Type_Id, element_name Element_Name, 
								h.Egt_Id Egt_Id, h.Created_By Created_By, h.Creation_Date Creation_Date, 
								h.Last_Updated_By Last_Updated_By , h.Last_Update_Date Last_Update_Date,  h.Last_Update_Login Last_Update_Login 
								from HXT_EARN_GROUPS h 
								left outer join pay_element_types_f p on (h.element_type_id=p.element_type_id)
								where egt_id in (select egt_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))';
				run_sql('HXT_EARN_GROUPS', sqltxt);
				
				
				
					
				sqlTxt := 'select Pep_Id, h.Elt_Base_Id,  element_name Element_Name,
								h.Effective_Start_Date Effective_Start_Date, 
								h.Created_By Created_By, h.Creation_Date Creation_Date,
								h.Effective_End_Date Effective_End_Date, 
								h.Last_Updated_By Last_Updated_By, h.Last_Update_Date Last_Update_Date, h.Last_Update_Login Last_Update_Login  
								from HXT_PREM_ELIGBLTY_POL_RULES h 
								left outer join pay_element_types_f p on (h.Elt_Base_Id=p.element_type_id)
								where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))';
				run_sql('HXT_PREM_ELIGBLTY_POL_RULES', sqltxt);
									
					
				sqlTxt := 'select Pep_Id, h.Elt_Base_Id,  p1.element_name Element_Name,
								Elt_Premium_Id, p2.element_name Element_Name,
								h.Effective_Start_Date Effective_Start_Date, 
								h.Created_By Created_By, h.Creation_Date Creation_Date,
								h.Effective_End_Date Effective_End_Date, 
								h.Last_Updated_By Last_Updated_By, h.Last_Update_Date Last_Update_Date, h.Last_Update_Login Last_Update_Login  
								from HXT_PREM_ELIGBLTY_RULES h 
								left outer join pay_element_types_f p1 on (h.Elt_Base_Id=p1.element_type_id)
								left outer join pay_element_types_f p2 on (h.Elt_Premium_Id=p2.element_type_id)
								where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))';
				run_sql('HXT_PREM_ELIGBLTY_RULES', sqltxt);			
				
				
				Display_Table('HXT_HOUR_DEDUCT_POLICIES', null, 'where id in (select Hour_Deduction_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)', null, 'Y');
				Display_Table('HXT_HOUR_DEDUCTION_RULES', null, 'where hdp_id in (select Hour_Deduction_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)', null, 'Y');
				
				Display_Table('HXT_SHIFT_DIFF_POLICIES', null, 'where id in (select Shift_Differential_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)', null, 'Y');
				Display_Table('HXT_SHIFT_DIFF_RULES', null, 'where sdp_id in (select Shift_Differential_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id in (select assignment_id from PER_ALL_ASSIGNMENTS_F where person_id in (select for_person_id from HXT_TIMECARDS_F where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)', null, 'Y');
				
				Display_Table('PER_TIME_PERIODS',            null, 'where time_period_id in (select time_period_id from HXT_TIMECARDS_F where id = (''&&8''))', null, 'Y');
				Display_Table('PAY_ALL_PAYROLLS_F',          null, 'where payroll_id in (select payroll_id from HXT_TIMECARDS_F where id = (''&&8''))', null, 'Y');
				Display_Table('PAY_COST_ALLOCATION_KEYFLEX', null, 'where cost_allocation_keyflex_id in (select ffv_cost_center_id from HXT_DET_HOURS_WORKED_F where tim_id = (''&&8''))', null, 'Y');

				
				sqlTxt := 'select *
							from  HXT_ADD_ELEM_INFO_F
							where element_type_id in 
							(select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') 
							and element_type_id is not null union select element_type_id 
							from hxt_det_hours_worked_f where tim_id = ''&&8''
							union
							select Element_Type_Id from HXT_EARNING_RULES where egp_id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')) 
							union
							select Element_Type_Id from HXT_HOLIDAY_CALENDARS where id in (select hcl_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Element_Type_Id from HXT_EARN_GROUPS where egt_id in (select egt_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Base_Id from HXT_PREM_ELIGBLTY_POL_RULES  where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Base_Id from HXT_PREM_ELIGBLTY_RULES where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Premium_Id from HXT_PREM_ELIGBLTY_RULES where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select ELEMENT_TYPE_ID from HXT_SHIFT_DIFF_RULES
									where sdp_id in 
									(select Shift_Differential_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id 
									in (select assignment_id from PER_ALL_ASSIGNMENTS_F where primary_flag = ''Y'' and assignment_type IN (''E'', ''C'') and person_id in (select for_person_id from HXT_TIMECARDS_F 
									where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)';
				
				sqlTxt := sqlTxt || ' ) order by element_type_id, effective_start_date';
				run_sql('HXT_ADD_ELEM_INFO_F', sqltxt);	
				
				
				sqlTxt := 'select *
							from  PAY_ELEMENT_TYPES_F
							where element_type_id in 
							(select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') 
							and element_type_id is not null union select element_type_id 
							from hxt_det_hours_worked_f where tim_id = ''&&8''
							union
							select Element_Type_Id from HXT_EARNING_RULES where egp_id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')) 
							union
							select Element_Type_Id from HXT_HOLIDAY_CALENDARS where id in (select hcl_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Element_Type_Id from HXT_EARN_GROUPS where egt_id in (select egt_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Base_Id from HXT_PREM_ELIGBLTY_POL_RULES  where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Base_Id from HXT_PREM_ELIGBLTY_RULES where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select Elt_Premium_Id from HXT_PREM_ELIGBLTY_RULES where pep_id in (select pep_id from hxt_earning_policies where id in (select distinct Earn_Pol_Id from HXT_SUM_HOURS_WORKED_F where tim_id = (''&&8'')))
							union
							select ELEMENT_TYPE_ID from HXT_SHIFT_DIFF_RULES
									where sdp_id in 
									(select Shift_Differential_Policy from HXT_ADD_ASSIGN_INFO_F where assignment_id 
									in (select assignment_id from PER_ALL_ASSIGNMENTS_F where primary_flag = ''Y'' and assignment_type IN (''E'', ''C'') and person_id in (select for_person_id from HXT_TIMECARDS_F 
									where id = (''&&8''))) and sysdate between effective_start_date and effective_end_date)';
									
				sqlTxt := sqlTxt || ' ) order by element_type_id, effective_start_date';
				run_sql('PAY_ELEMENT_TYPES_F', sqltxt);	
				
				Display_Table('PAY_ELEMENT_TYPES_F_TL',              null, 'where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by element_type_id, language', 'Y');
				Display_Table('PAY_ELEMENT_CLASSIFICATIONS',         null, 'where classification_id in (select classification_id from PAY_ELEMENT_TYPES_F where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', 'order by classification_id', 'Y');
				Display_Table('PAY_ELEMENT_CLASSIFICATIONS_TL',      null, 'where classification_id in (select classification_id from PAY_ELEMENT_TYPES_F where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', 'order by classification_id, language', 'Y');
				Display_Table('PAY_INPUT_VALUES_F',                  null, 'where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by element_type_id, display_sequence, input_value_id, effective_start_date', 'Y');
				Display_Table('PAY_INPUT_VALUES_F_TL',               null, 'where input_value_id in (select input_value_id from PAY_INPUT_VALUES_F where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', 'order by input_value_id, language', 'Y');
				Display_Table('PAY_ELEMENT_LINKS_F',                 null, 'where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by element_type_id, element_link_id, effective_start_date', 'Y');
				Display_Table('PAY_LINK_INPUT_VALUES_F',             null, 'where element_link_id in (select element_link_id from PAY_ELEMENT_LINKS_F where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', 'order by element_link_id, effective_start_date', 'Y');
				Display_Table('PER_ABSENCE_ATTENDANCE_TYPES',        null, 'where name in (select element_name from PAY_ELEMENT_TYPES_F where element_type_id in (select element_type_id from hxt_sum_hours_worked_f where tim_id = (''&&8'') and element_type_id is not null union select element_type_id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', 'order by name', 'Y');

				Display_Table('PA_TRANSACTION_INTERFACE_ALL',null, 'where transaction_source = ''Time Management'' and substr(orig_transaction_reference,23,length(orig_transaction_reference)) in (select id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by substr(orig_transaction_reference,23,length(orig_transaction_reference))', 'Y');
				Display_Table('PA_TXN_INTERFACE_AUDIT_ALL',  null, 'where transaction_source = ''Time Management'' and substr(orig_transaction_reference,23,length(orig_transaction_reference)) in (select id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by substr(orig_transaction_reference,23,length(orig_transaction_reference))', 'Y');
				Display_Table('PA_EXPENDITURES_ALL',         null, 'where expenditure_id in (select expenditure_id from PA_EXPENDITURE_ITEMS_ALL where transaction_source = ''Time Management'' and substr(orig_transaction_reference,23,length(orig_transaction_reference)) in (select id from hxt_det_hours_worked_f where tim_id = (''&&8'')))', null, 'Y');
				Display_Table('PA_EXPENDITURE_ITEMS_ALL',    null, 'where transaction_source = ''Time Management'' and substr(orig_transaction_reference,23,length(orig_transaction_reference)) in (select id from hxt_det_hours_worked_f where tim_id = (''&&8''))', 'order by substr(orig_transaction_reference,23,length(orig_transaction_reference))', 'Y');
		
		end if;
		
		end if;
		
		l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		:n := round((dbms_utility.get_time - :n)/100/60,4);
	    l_o('<br><br><i> Elapsed time '||:n|| ' minutes</i> <br> ');
		l_o('</div><br/>');
		
		l_o('</div>');
end if;  --- end HXT

-- Display Batch output
if upper('&&9') = 'Y' then
-- ************************
-- *** HXT_BATCH.. 
-- ************************
		l_o('<div id="page6" style="display: none;">');
		:n := dbms_utility.get_time;
		l_o(' <a name="batch"></a>');
		l_o('<div class="divSection">');
		l_o('<div class="divSectionTitle">');
		l_o('<div class="left"  id="batch" font style="font-weight: bold; font-size: x-large;" align="left" color="#FFFFFF">HXT Batch Information: '); 
		l_o('</div></div><br>');
		l_o('<div class="divok">For Batch: <span class="sectionblue">'||l_param5||'</span>');
		
		if LENGTH(TRIM(TRANSLATE('&&10', ' +-.0123456789', ' '))) is not null then
				:e6:=:e6+1;
				l_o('<br><br><div class="diverr"> No batch for this id.<br></div></div>');
		else
			select count(1) into v_rows from PAY_BATCH_HEADERS
				where batch_id ='&&10' ;
			if v_rows=0 then
					:e6:=:e6+1;
					l_o('<br><br><div class="diverr"> No batch for this id.<br></div></div>');
					
			else
						if v_rows=1 then
							select Batch_Name into v_Batch_Name from PAY_BATCH_HEADERS
								where batch_id ='&&10' ;
							l_o(' - <span class="sectionblue">'||v_Batch_Name||'</span>');
						end if;
						l_o('</div><br>');
						
						sqlTxt := 'select count(1) from HXT_TIMECARDS_F where batch_id in (''&&10'')';
						run_sql('HXT_TIMECARDS_F', sqltxt);
						select count(1) into v_rows
							from HXT_TIMECARDS_F where batch_id ='&&10';
						if v_rows=0 then
								select count(1) into v_rows from HXT_DET_HOURS_WORKED_F where Retro_Batch_Id ='&&10';
									if v_rows=0 then
										l_o('<div class="divok">No HXT(OTLR) Timecards included in this Batch.</div><br>');
									else
										l_o('<div class="divok">This is a Retro Batch linked with ');
										select count (distinct tim_id) into v_rows from hxt_det_hours_worked_f where Retro_Batch_Id ='&&10';
										l_o(v_rows ||' HXT Timecard(s) detail.</div>');
									end if;
						end if;										

						sqlTxt := 'select count(1) from HXT_SUM_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10''))';
						run_sql('HXT_SUM_HOURS_WORKED_F', sqltxt);

						sqlTxt := 'select count(1) from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10'')) or retro_batch_id in (''&&10'')';
						run_sql('HXT_DET_HOURS_WORKED_F', sqltxt);

						Display_Table('HXT_ERRORS_F',                null, 'where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10''))', 'order by error_msg', 'Y');
						select count(1) into v_rows from HXT_ERRORS_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in ('&&10'));
						if v_rows>0 then
							:e6:=:e6+1;
							l_o('<div class="diverr"><img class="error_ico"><font color="red">Error:</font> This timecard has errors! Please check the concurrent process log file for details and the table above.</div><br>');
						end if;
						
						Display_Table('HXT_BATCH_STATES',            null, 'where batch_id in (''&&10'')', null, 'Y');
						select count(1) into v_rows from HXT_BATCH_STATES where 
								batch_id  = '&&10' ;
						if v_rows=1 then
								l_o('<div class="divok"> HXT Batch Status is: ');				
										select batch_id, status into v_batch_id, v_batch_status
											from HXT_BATCH_STATES where 
											batch_id  = '&&10' ;
										case upper(v_batch_status) 
											when 'H' then
													l_o('<span class="sectionblue">On Hold (not validated or transferred yet). ');
													l_o('</span>If batch remains on H status even after "Validate for BEE" was run, please refer to ');
													Show_link('1273067.1'); 
													l_o(' After "Validate For BEE", Batch Remains In Hold Status Even Though No Error Or Warning.<br>');
											when 'VV' then
													l_o('<span class="sectionblue">Successfully Validated. </span><br>');
											when 'T' then
													l_o('<span class="sectionblue">Successfully Transferred but Not Validated. </span><br>');
											when 'VT' then
													l_o('<span class="sectionblue">Successfully Validated and Transferred. </span><br>');
											when 'VE' then
													:e6:=:e6+1;
													l_o('<span class="sectionblue">Validated with Errors. ');
													l_o('</span><div class="diverr">Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F2">HXT_ERRORS_F</a> table.</div><br>');
											when 'VW' then
													:w6:=:w6+1;
													l_o('<span class="sectionblue">Validated with Warnings. ');
													l_o('</span><div class="divwarn" id="sigr10">Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F2">HXT_ERRORS_F</a> table.</div><br>');
											when 'W' then
													:w6:=:w6+1;
													l_o('<span class="sectionblue">Faced Warnings. ');
													l_o('</span><div class="divwarn" id="sigr11">Check the concurrent process log file for details, also check <a href="#HXT_ERRORS_F2">HXT_ERRORS_F</a> table.</div><br>');
											else
													null;
										end case;
										l_o('Refer to '); 
										Show_link('269988.1'); 
										l_o(' (OTL What Are The Meanings of The Status Values In HXT_BATCH_STATES Table) for all statuses meaning.</div><br>');						
										

						end if;
						
						
						Display_Table('PAY_BATCH_HEADERS',           null, 'where batch_id in (''&&10'')', null, 'Y');
						select count(1) into v_rows from HXT_TIMECARDS_F where batch_id ='&&10';
						select count(1) into v_rows2 from PAY_BATCH_HEADERS
							where batch_id ='&&10' ;		
						select count(1) into v_rows3 from PAY_BATCH_HEADERS
							where batch_id ='&&10'
							and batch_status like 'P%';
						if v_rows>0 and (v_rows2=0 or v_rows3>0) then
								:e6:=:e6+1;
								l_o('<div class="diverr" id="sigr4"><img class="error_ico"><font color="red">Error:</font> The Batch was purged while the PUI (HXT) Timecard is still there, please raise a Service Request and refer Oracle Support Engineer to ');
								l_o('internal Doc ID 271895.1 PUI Timecards cannot be Queried - BEE Batch Header has been Purged.</div><br>');
						end if;
								
						if v_rows2=1 then			
										-- Explain batch source and batch status
										select batch_id, batch_status, batch_source into v_batch_id, v_batch_status, v_batch_source
											from PAY_BATCH_HEADERS where batch_id ='&&10';
										l_o('<div class="divok"><span class="sectionblue">');
										if v_batch_source like 'OTM%' then
												l_o(' This is an OTLR Batch. ');
										elsif v_batch_source like 'Time Store%' then
												l_o(' This is a Non-OTLR Batch.');
										end if;
										l_o('</span><br> ');
										case upper(v_batch_status) 
											when 'U' then
													l_o('<span class="sectionblue"> This Batch is Unprocessed yet. </span>');									
											when 'V' then
													l_o('<span class="sectionblue"> This Batch is Validated. </span>');
													select status into v_status_hxt_states  
													from HXT_BATCH_STATES where 
													batch_id = v_batch_id and rownum < 2;
													if v_status_hxt_states in ('VV','VW', 'VE', 'H') then
															 :e6:=:e6+1;
															 l_o('<br><div class="diverr" id="sigr5"> This Batch Header was Validated before the HXT Timecard is Transferred to generate the Batch Lines, please first run "Validate for BEE" ');
															 l_o('and "Transfer to BEE" before validating or transferring this batch header. Please also refer to the OTLR to BEE Viewlet ');
															 Show_link('567259.1');
															 l_o(' for the right sequence of steps.</div>');
													end if;

											when 'T' then
													l_o('<span class="sectionblue"> This Batch is Transferred to Element Entries. </span>');
													select status into v_status_hxt_states  
													from HXT_BATCH_STATES where 
													batch_id = v_batch_id and rownum < 2;
													if v_status_hxt_states in ('VV','VW', 'VE', 'H') and v_batch_source like 'OTM%'  then
															 :e6:=:e6+1;
															 l_o('<br><div class="diverr" id="sigr6"> This Batch Header was Transferred before the HXT Timecard is Transferred to generate the Batch Lines, please first run "Validate for BEE" ');
															 l_o('and "Transfer to BEE" before validating or transferring this batch header. Please also refer to the OTLR to BEE Viewlet ');
															 Show_link('567259.1');
															 l_o(' for the right sequence of steps.</div>');										 

													end if; 
											when 'P' then
													:w6:=:w6+1;
													l_o('<div class="divwarn" id="sigr12"> This Batch is Purged. </div>');
													if v_batch_source like 'Time Store%' then
															:e6:=:e6+1;
															l_o('<br><div class="diverr" id="sigr7"> The Batch was purged while the HXC(Self Service/Timekeeper) Timecard is still there, please raise a Service Request ');
															l_o('and refer Oracle Support Engineer to internal Doc ID 290858.1.</div>');
													end if;
											else
													null;
										end case;
										l_o('<br>');					
										
										-- if Batch_Source has a value other than OTM or TimeStore
										select count(1) into v_rows from PAY_BATCH_HEADERS where batch_id ='&&10'
												and  upper(Batch_Source) not in ('OTM','TIME STORE');
										if v_rows>0 then
											:w6:=:w6+1;
											l_o('<div class="divwarn" id="sigr13"> Reminder: This Batch was not created using OTL Retrieval Processes. The source of this Batch is ');
											l_o('<span class="sectionblue"> v_batch_source<br> </span></div>');										
										end if;
										l_o('</div><br>');
							
						end if;
						

						--Display_Table('PAY_BATCH_LINES',             null, 'where batch_id in (''&&10'')', null, 'Y');
						-- for big numbers of rows, will display count
						select count(1) into v_rows  from PAY_BATCH_LINES   where batch_id  = ('&&10') ;
						if v_rows<51 then
							Display_Table('PAY_BATCH_LINES',             null, 'where batch_id in (''&&10'')', null, 'Y');
						else
							sqlTxt := 'select batch_id, batch_line_status, count(1) from pay_batch_lines where batch_id in (''&&10'') group by batch_id, batch_line_status order by batch_id, batch_line_status';
							run_sql('PAY_BATCH_LINES', sqltxt);
						end if;
						if v_rows=0 and v_rows2>0 then
								:w6:=:w6+1;
								l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>You need to run Validate for BEE and Transfer to BEE processes to generate the Batch Lines.</div><br>');
						end if;
						if v_rows>0 then
								select count(1) into v_rows2  from PAY_BATCH_LINES   where  batch_id  = ('&&10')
									and batch_line_status in ('U','V');
								select count(1) into v_rows3  from PAY_BATCH_LINES   where batch_id  = ('&&10')
									and batch_line_status='T';
								if v_rows=v_rows2 then
									l_o('<div class="divok"><span class="sectionblue">All lines were not transferred to Element Entries.</span></div><br>');
								elsif v_rows=v_rows3 then
									select count(1) into v_rows4 from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in ('&&10')) or retro_batch_id in ('&&10');
									if v_rows=v_rows4 then
										l_o('<div class="divok"><span class="sectionblue">All lines were transferred to Element Entries.</span></div><br>');
									else 
										:w6:=:w6+1;
										l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Some lines were transferred to Element Entries and some were not.</div><br>');
									end if;
								end if;
								if v_rows2>0 and v_rows3>0 then
									:w6:=:w6+1;
									l_o('<div class="divwarn"><img class="warn_ico"><span class="sectionorange">Warning: </span>Some lines were transferred to Element Entries and some were not.</div><br>');
								end if;
						end if;

						--Display_Table('PAY_ELEMENT_ENTRIES_F',       null, 'where (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10'')))', 'order by assignment_id, date_earned, element_type_id, object_version_number', 'Y');
						-- for big numbers of rows, will display count
						select count(1) into v_rows  from PAY_ELEMENT_ENTRIES_F   where (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in ('&&10')));
						if v_rows<51 then
							Display_Table('PAY_ELEMENT_ENTRIES_F',       null, 'where (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10'')))', 'order by assignment_id, date_earned, element_type_id, object_version_number', 'Y');
						else
							sqlTxt := 'select count(1) from PAY_ELEMENT_ENTRIES_F where (assignment_id, element_type_id, date_earned) in (select assignment_id, element_type_id, date_worked from HXT_DET_HOURS_WORKED_F where tim_id in (select id from HXT_TIMECARDS_F where batch_id in (''&&10'')))';
							run_sql('PAY_ELEMENT_ENTRIES_F', sqltxt);
						end if;
						
						Display_Table('PER_TIME_PERIODS',            null, 'where time_period_id in (select time_period_id from HXT_TIMECARDS_F where batch_id in (''&&10''))', null, 'Y');
			end if;
		end if;
		
		l_o('<br><A href="#top"><font size="-1">Back to Top</font></A><BR> ');
		:n := round((dbms_utility.get_time - :n)/100/60,4);
	    l_o('<br><br><i> Elapsed time '||:n|| ' minutes</i> <br> ');
		l_o('</div>');
		
		l_o('</div>');
end if; --- end Batch
		l_o('</div><br>');

execute immediate 'alter session set nls_date_format = ''' ||
     l_old_date_format || '''';
	 
-- Show_Footer('&v_scriptlongname', '&v_headerinfo');

EXCEPTION

when others then

  BRPrint;
  ErrorPrint(sqlerrm ||' occurred in test');
  ActionErrorPrint('Please report the above error as comment in OTL Analyzer Note 1580490.1.');
  BRPrint;
  -- Show_Footer('&v_scriptlongname', '&v_headerinfo');
  BRPrint;

end;
end;
/

print :g_hold_output3

-- Display overview of issues
declare
v_errors number;
v_warnings number;	
begin
	v_errors:=:e1+:e2+:e3+:e4+:e5+:e6;
	v_warnings:=:w1+:w2+:w3+:w4+:w5+:w6;
	dbms_output.put_line('<script type="text/javascript">');
	dbms_output.put_line('var auxs;');
	dbms_output.put_line('auxs = document.getElementById("ExecutionSummary1").innerHTML;');
	dbms_output.put_line('document.getElementById("ExecutionSummary1").innerHTML = auxs + ');
	if v_errors>0 and v_warnings>0 then
		dbms_output.put_line('"('||v_errors||'<img class=''error_ico''> '||v_warnings||'<img class=''warn_ico''>)</A>";');
	elsif v_errors>0 and v_warnings=0 then
		dbms_output.put_line('"(<img class=''error_ico''>'||v_errors||')</A>";');
	elsif v_errors=0 and v_warnings>0 then
		dbms_output.put_line('"(<img class=''warn_ico''>'||v_warnings||')</A>";');
	elsif v_errors=0 and v_warnings=0 then
		dbms_output.put_line('"(<img class=''check_ico''> No issues reported)</A>";');
	end if;
	
	dbms_output.put_line('auxs = document.getElementById("ExecutionSummary2").innerHTML;');
	dbms_output.put_line('document.getElementById("ExecutionSummary2").innerHTML = auxs + ');			

	dbms_output.put_line(' "<TABLE width=''95%''><TR>"+');
	dbms_output.put_line(' "<TH><B>Section</B></TD>"+');
	dbms_output.put_line(' "<TH><B>Errors</B></TD>"+');
	dbms_output.put_line(' "<TH><B>Warnings</B></TD>"+');
	
	if upper('&&1') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page1''); href=''javascript:;''>OTL Product Technical Information</A>"+');
			if :e1>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w1>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');	
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e1||'</TD><TD>'||:w1||'</TD> </TR>"+');
	  end if;
	  if upper('&&2') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page2''); href=''javascript:;''>OTL Setup Analyzer</A>"+');
			if :e2>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w2>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');	
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e2||'</TD><TD>'||:w2||'</TD> </TR>"+');	           
	  end if;
	  if upper('&&3') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page3''); href=''javascript:;''>HXC Timecard(Self Service/TK/API)</A>"+');
			if :e3>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w3>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');		
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e3||'</TD><TD>'||:w3||'</TD> </TR>"+');
	  end if;
	  if upper('&&6') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page4''); href=''javascript:;''>Employee Preferences</A>"+');
			if :e4>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w4>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');		
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e4||'</TD><TD>'||:w4||'</TD> </TR>"+'); 
	  end if;
	  if upper('&&7') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page5''); href=''javascript:;''>HXT Timecard(OTLR/PUI)</A>"+');
			if :e5>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w5>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');		
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e5||'</TD><TD>'||:w5||'</TD> </TR>"+');		 
	  end if;
	  if upper('&&9') = 'Y' then
			dbms_output.put_line('"<TR><TD><A class=detail onclick=activateTab2(''page6''); href=''javascript:;''>HXT Batch Information</A>"+');
			if :e6>0 then
				dbms_output.put_line(' "<img class=''error_ico''>"+');
			elsif :w6>0 then
				dbms_output.put_line(' "<img class=''warn_ico''>"+');		
			else
				dbms_output.put_line(' "<img class=''check_ico''>"+');
			end if;	
			dbms_output.put_line('"</TD><TD>'||:e6||'</TD><TD>'||:w6||'</TD> </TR>"+');			
      end if;	   
    	
			
	dbms_output.put_line(' "</TABLE></div>";');  

	dbms_output.put_line('auxs = document.getElementById("toccontent").innerHTML;');
	dbms_output.put_line('document.getElementById("toccontent").innerHTML = auxs + ');
	dbms_output.put_line('"<div align=''center''>"+');
	-- Tabs 
	
	if upper('&&1') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page1'') >"+');
			dbms_output.put_line('"<b>OTL Product<br>Technical Information</b> "+');
			if :e1>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w1>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	 
	  end if;
	  if upper('&&2') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page2'') >"+');
			dbms_output.put_line('"<b>OTL Setup Analyzer</b>"+');
			if :e2>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w2>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	
	  end if;
	  if upper('&&3') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page3'') >"+');
			dbms_output.put_line('"<b>HXC Timecard<br>(Self Service/TK/API)</b> "+');
			if :e3>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w3>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	
	  end if;
	  if upper('&&6') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page4'') >"+');
			dbms_output.put_line('"<b>Employee Preferences</b> "+');
			if :e4>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w4>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	 
	  end if;
	  if upper('&&7') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page5'') >"+');
			dbms_output.put_line('"<b>HXT Timecard<br>(OTLR/PUI)</b> "+');
			if :e5>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w5>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	
	  end if;
	  if upper('&&9') = 'Y' then
			dbms_output.put_line('"<button class=''btn'' OnClick=activateTab(''page6'') >"+');
			dbms_output.put_line('"<b>HXT Batch Information</b> "+');
			if :e6>0 then
				dbms_output.put_line(' "<img class=''error_ico''></button>"+');
			elsif :w6>0 then
				dbms_output.put_line(' "<img class=''warn_ico''></button>"+');
			else
				dbms_output.put_line(' "<img class=''check_ico''></button>"+');
			end if;	
      end if;
	  dbms_output.put_line('"</div>";');
	  
	    if upper('&&1') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("technical").innerHTML;');
			dbms_output.put_line('document.getElementById("technical").innerHTML = auxs + ');
			if :e1>0 and :w1>0 then
				dbms_output.put_line(' "'||:e1||' <img class=''error_ico''>  '||:w1||' <img class=''warn_ico''> ";');
			elsif :e1>0 then
				dbms_output.put_line(' "'||:e1||' <img class=''error_ico''> ";');
			elsif :w1>0 then
				dbms_output.put_line(' "'||:w1||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;						
	  end if;
	  if upper('&&2') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("setup").innerHTML;');
			dbms_output.put_line('document.getElementById("setup").innerHTML = auxs + ');
			if :e2>0 and :w2>0 then
				dbms_output.put_line(' "'||:e2||' <img class=''error_ico''>  '||:w2||' <img class=''warn_ico''> ";');
			elsif :e2>0 then
				dbms_output.put_line(' "'||:e2||' <img class=''error_ico''> ";');
			elsif :w2>0 then
				dbms_output.put_line(' "'||:w2||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;				
	  end if;
	  if upper('&&3') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("hxc").innerHTML;');
			dbms_output.put_line('document.getElementById("hxc").innerHTML = auxs + ');
			if :e3>0 and :w3>0 then
				dbms_output.put_line(' "'||:e3||' <img class=''error_ico''>  '||:w3||' <img class=''warn_ico''> ";');
			elsif :e3>0 then
				dbms_output.put_line(' "'||:e3||' <img class=''error_ico''> ";');
			elsif :w3>0 then
				dbms_output.put_line(' "'||:w3||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;			
	  end if;
	  if upper('&&6') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("emp").innerHTML;');
			dbms_output.put_line('document.getElementById("emp").innerHTML = auxs + ');
			if :e4>0 and :w4>0 then
				dbms_output.put_line(' "'||:e4||' <img class=''error_ico''>  '||:w4||' <img class=''warn_ico''> ";');
			elsif :e4>0 then
				dbms_output.put_line(' "'||:e4||' <img class=''error_ico''> ";');
			elsif :w4>0 then
				dbms_output.put_line(' "'||:w4||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;			
	  end if;
	  if upper('&&7') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("hxt").innerHTML;');
			dbms_output.put_line('document.getElementById("hxt").innerHTML = auxs + ');
			if :e5>0 and :w5>0 then
				dbms_output.put_line(' "'||:e5||' <img class=''error_ico''>  '||:w5||' <img class=''warn_ico''> ";');
			elsif :e5>0 then
				dbms_output.put_line(' "'||:e5||' <img class=''error_ico''> ";');
			elsif :w5>0 then
				dbms_output.put_line(' "'||:w5||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;			
	  end if;
	  if upper('&&9') = 'Y' then
			dbms_output.put_line('auxs = document.getElementById("batch").innerHTML;');
			dbms_output.put_line('document.getElementById("batch").innerHTML = auxs + ');
			if :e6>0 and :w6>0 then
				dbms_output.put_line(' "'||:e6||' <img class=''error_ico''>  '||:w6||' <img class=''warn_ico''> ";');
			elsif :e6>0 then
				dbms_output.put_line(' "'||:e6||' <img class=''error_ico''> ";');
			elsif :w6>0 then
				dbms_output.put_line(' "'||:w6||' <img class=''warn_ico''> ";');
			else
				dbms_output.put_line(' " <img class=''check_ico''> ";');
			end if;				
      end if;
	  dbms_output.put_line('</script>');
	
end;
/

begin
select to_char(sysdate,'hh24:mi:ss') into :et_time from dual;
end;
/

declare
	st_hr1 varchar2(10);
	st_mi1 varchar2(10);
	st_ss1 varchar2(10);
	et_hr1 varchar2(10);
	et_mi1 varchar2(10);
	et_ss1 varchar2(10);
	hr_fact varchar2(10);
	mi_fact varchar2(10);
	ss_fact varchar2(10);
	vss number;
	vse number;
	vt number;
begin
	dbms_output.put_line('<hr><br><TABLE width="50%"><THEAD><STRONG>OTL Analyzer Performance Data</STRONG></THEAD>');
    dbms_output.put_line('<TBODY><TR><TH>Started at:</TH><TD>'||:st_time||'</TD></TR>');
    dbms_output.put_line('<TR><TH>Complete at:</TH><TD>'||:et_time||'</TD></TR>');
    	
	st_hr1 := substr(:st_time,1,2);
	st_mi1 := substr(:st_time,4,2);
	st_ss1 := substr(:st_time,7,2);
	et_hr1 := substr(:et_time,1,2);
	et_mi1 := substr(:et_time,4,2);
	et_ss1 := substr(:et_time,7,2);
	
	vss:=st_hr1*60*60 + st_mi1*60+st_ss1;
	vse:=et_hr1*60*60 + et_mi1*60+et_ss1;
	
	
	dbms_output.put_line('<TR><TH>Total time taken to complete the script:</TH>');
	if vse>vss then	
			vt:=vse-vss;			
	else
			vt:=24*60*60-vss +vse;
	end if;
	
	if (vt > 3600) then
								dbms_output.put_line('<TD>'||trunc(vt/3600)||' hours, '||trunc((vt-((trunc(vt/3600))*3600))/60)||' minutes, '||trunc(vt-((trunc(vt/60))*60))||' seconds</TD></TR>');
	elsif (vt > 60) then
								dbms_output.put_line('<TD>'||trunc(vt/60)||' minutes, '||trunc(vt-((trunc(vt/60))*60))||' seconds</TD></TR>');
	elsif (vt < 60) then
								dbms_output.put_line('<TD>'||trunc(vt)||' seconds</TD></TR>');
	end if;
			
	dbms_output.put_line('</TBODY></TABLE>');
	
end;
/

-- Display Feedback and DX summary
declare
		db_ver    	  VARCHAR2(100);
		db_charset V$NLS_PARAMETERS.value%type;
		db_lang V$NLS_PARAMETERS.value%type;
		rup_level varchar2(20);
		v_exists number;
		platform varchar2(100);			
		v_wfVer WF_RESOURCES.TEXT%type:='';
		v_crtddt V$DATABASE.CREATED%type;
		multiOrg FND_PRODUCT_GROUPS.MULTI_ORG_FLAG%type;
		multiCurr FND_PRODUCT_GROUPS.MULTI_CURRENCY_FLAG%type;
begin

	dbms_output.put_line('<br><hr><a name="feedback"></a><table border="2" name="NoteBox" cellpadding="1" bordercolor="#C1A90D" bgcolor="#CCCCCC" cellspacing="1"><br>');
	dbms_output.put_line('<b>Still have questions or suggestions?</b><br>  <A HREF="https://community.oracle.com/thread/3495166"  target="_blank">');
	dbms_output.put_line('<img src="https://blogs.oracle.com/ebs/resource/Proactive/Feedback.png" title="Click here to provide feedback"/></a><br>');
	dbms_output.put_line('Click the button above to ask questions about and/or provide feedback on the OTL Analyzer. Share your recommendations for enhancements and help us make this Analyzer even more useful!<br>');
		

SELECT SUBSTR(REPLACE(REPLACE(pcv1.product, 'TNS for '), ':' )||pcv2.status, 1, 80)
    INTO platform
        FROM product_component_version pcv1,
           product_component_version pcv2
     WHERE UPPER(pcv1.product) LIKE '%TNS%'
       AND UPPER(pcv2.product) LIKE '%ORACLE%'
       AND ROWNUM = 1;
	select VALUE into db_lang FROM V$NLS_PARAMETERS WHERE parameter = 'NLS_LANGUAGE';
	select VALUE into db_charset FROM V$NLS_PARAMETERS WHERE parameter = 'NLS_CHARACTERSET';
	select banner into db_ver from V$VERSION WHERE ROWNUM = 1;
	select count(1) into v_exists FROM V$DATABASE;
	if v_exists=1 then	
	SELECT CREATED into v_crtddt FROM V$DATABASE;
	end if;
	select count(1) into v_exists FROM WF_RESOURCES  WHERE TYPE = 'WFTKN'  AND NAME = 'WF_VERSION'  AND LANGUAGE = 'US';
	if v_exists=1 then
	SELECT TEXT into v_wfVer  FROM WF_RESOURCES  WHERE TYPE = 'WFTKN'  AND NAME = 'WF_VERSION'  AND LANGUAGE = 'US';	
	end if;	
    SELECT MULTI_ORG_FLAG,MULTI_CURRENCY_FLAG into multiOrg, multiCurr FROM FND_PRODUCT_GROUPS;	 
	
	
	dbms_output.put_line('<!-- ######BEGIN DX SUMMARY######');
	dbms_output.put_line('<diagnostic><run_details>');
    dbms_output.put_line('<detail name="Instance">'||:sid||'</detail>');
    dbms_output.put_line('<detail name="Instance Date">'||v_crtddt||'</detail>');
    dbms_output.put_line('<detail name="Platform">'||platform||'</detail>');
    dbms_output.put_line('<detail name="File Version">200.30</detail>');
    dbms_output.put_line('<detail name="Language">'||db_lang||' / '||db_charset||'</detail>');
    dbms_output.put_line('<detail name="Database">'||db_ver||'</detail>');
	dbms_output.put_line('<detail name="Application">'||:apps_rel||'</detail>');
    dbms_output.put_line('<detail name="Workflow">'||v_wfVer||'</detail>');
	dbms_output.put_line('<detail name="Multiorg">'||multiOrg||'</detail>');
	dbms_output.put_line('<detail name="Multicur">'||multiCurr||'</detail>');
    dbms_output.put_line('<detail name="HXT">'||:hxt_status||' '||:hxt_patch||'</detail>');
    dbms_output.put_line('<detail name="HXC">'||:hxc_status||' '||:hxc_patch||'</detail>');	
	dbms_output.put_line('<detail name="RUP">'||:rup_level_n|| ' applied on ' || :rup_date||'</detail>');
  dbms_output.put_line('</run_details>');
  dbms_output.put_line('<parameters>');
  dbms_output.put_line('<parameter name="person_id">'||'&&4'||'</parameter>');
  dbms_output.put_line('<parameter name="start_date">'||'&&5'||'</parameter>');
  dbms_output.put_line('<parameter name="hxt_id">'||'&&8'||'</parameter>');
  dbms_output.put_line('<parameter name="batch_id">'||'&&10'||'</parameter>');  
  dbms_output.put_line('</parameters> <issues><signature id="INSTSUM"><failure row="1">dummy</failure></signature></issues></diagnostic>');
  dbms_output.put_line('######END DX SUMMARY######-->');
end;
/
REM  ==============SQL PLUS Environment setup===================

Spool off

set termout on

PROMPT
prompt Output spooled to filename otl_&&instancename._&&4._&&5._&&8._&&10._&&when..html
prompt
exit
;