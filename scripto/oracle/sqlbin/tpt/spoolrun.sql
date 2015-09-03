def _spool_extension=&1

spool %SQLPATH%/tmp/output_&_connect_identifier..&_spool_extension
@&2
spool off

host start %SQLPATH%/tmp/output_&_connect_identifier..&_spool_extension
undef _spool_extension
