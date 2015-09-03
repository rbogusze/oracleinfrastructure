.
set termout off
set markup html on spool on 
def _html_spoolfile=&_tpt_tempdir/html_&_tpt_tempfile..html
spool &_html_spoolfile
list
/
spool off
set markup html off spool off 
set termout on
host &_start &_html_spoolfile

