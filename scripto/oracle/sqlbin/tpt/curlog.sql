select member from v$logfile where group# = (select group# from v$log where status = 'CURRENT');
