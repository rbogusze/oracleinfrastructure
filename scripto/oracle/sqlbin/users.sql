prompt Number of backgroud processes
select count(*) from v$session where type='BACKGROUND';

prompt Number of user sessions
select count(*) from v$session where type='USER';

prompt User session details
set lines 200
column USERNAME format a20
column MACHINE format a20
column MODULE format a20
select SID, USERNAME, machine, module, status from v$session where type='USER';
