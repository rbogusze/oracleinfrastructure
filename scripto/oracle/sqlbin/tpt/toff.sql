alter session set events '&1 trace name context off';
alter session set tracefile_identifier=CLEANUP;

host ssh2 oracle@solaris01 "rm &trc"

--host ssh2 oracle@solaris01 "rm `echo &trc | sed 's/_CLEANUP//'`"
