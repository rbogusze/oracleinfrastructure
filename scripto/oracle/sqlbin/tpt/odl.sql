-- script by Tanel Poder (http://www.tanelpoder.com)

set termout off
spool odl.tmp

oradebug dumplist
spool off

host grep -i &1 odl.tmp
host &_delete odl.tmp

set termout on

prompt
prompt (spool is off)
