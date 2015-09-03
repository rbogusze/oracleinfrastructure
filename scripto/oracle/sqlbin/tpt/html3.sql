set termout off markup html on spool on
spool output_&_connect_identifier..html

l
/
spool off

set termout on markup html off spool off
host start output_&_connect_identifier..html
