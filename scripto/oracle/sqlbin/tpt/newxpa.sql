set heading off linesize 10000 pagesize 0 trimspool on trimout on

ACCEPT sqlid FORMAT A13 PROMPT "Enter sql_id: "

set termout off
spool sqlmon_&sqlid..html

SELECT
  DBMS_SQLTUNE.REPORT_SQL_MONITOR(
     sql_id=>'&sqlid',
     report_level=>'ALL',
     type => 'ACTIVE') as report
FROM dual
/

spool off
set termout on heading on linesize 999

PROMPT File spooled into sqlmon_&sqlid..html

