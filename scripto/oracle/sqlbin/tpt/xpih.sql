PROMPT eXplain with Profile: Running DBMS_SQLTUNE.REPORT_SQL_MONITOR for SQL_ID &1.... (11.2+)

SET TERMOUT OFF

SPOOL &SQLPATH/tmp/xprof_&_i_inst..html

@@xprof ALL HTML SQL_ID "'&1'"

SPOOL OFF

host &_start &SQLPATH/tmp/xprof_&_i_inst..html

SET TERMOUT ON

