@@saveset
set termout off feedback off colsep &1 lines 32767 trimspool on trimout on tab off 
-- set underline off -- if dont want dashes to appear between column headers and data

spool %SQLPATH%/tmp/output_&_connect_identifier..&2
/
spool off

@@loadset

host &_start %SQLPATH%/tmp/output_&_connect_identifier..&2
