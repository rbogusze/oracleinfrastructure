show parameter log;
select * from v$instance;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$archived_log order by completion_time desc;
-- itest
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('+RECO/OEBSTEST/ARCHIVELOG/2016_08_08/thread_2_seq_1500.799.919376753');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/DEMOR2/arch_1_337_918997229.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/DEMOR2/arch_1_3156_918997229.log');

EXECUTE DBMS_LOGMNR.START_LOGMNR(OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG);

select * from v$logmnr_contents;
select count(*) from v$logmnr_contents;

alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from sys.v_$logmnr_contents;



select count(*), ala from (
select substr(sql_redo, 1, 60) ala
from v$logmnr_contents
) group by ala order by count(*) desc
;

