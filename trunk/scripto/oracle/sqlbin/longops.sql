prompt Show sessions considered as long operations that has not finished
select SID, SOFAR, TOTALWORK from v$session_longops
where SOFAR < TOTALWORK
/
