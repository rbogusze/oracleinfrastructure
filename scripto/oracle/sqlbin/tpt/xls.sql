.
set termout off
set markup html on spool on
def _xls_spoolfile=&_tpt_tempdir/xls_&_tpt_tempfile..xls
spool &_xls_spoolfile
--list
/
spool off
set markup html off spool off
set termout on
host &_start &_xls_spoolfile

