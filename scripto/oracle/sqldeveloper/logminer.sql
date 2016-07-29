show parameter log;
select * from v$instance;
-- itest
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/arch/redolog_1_41013_882659541.arc');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/arch/redolog_1_41076_882659541.arc');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/arch/redolog_2_50929_882659541.arc');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/arch/redolog_1_6879_893556513.arc');


-- glrac
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/arch/redo01a.log');
-- itestc1
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/itestc1/redo08a.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/itestc1/redo01a.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/itestc1/redo02a.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/itestc1/redo07a.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/export/home/applmgr/212469221/itestc1/redo07a.log');


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

