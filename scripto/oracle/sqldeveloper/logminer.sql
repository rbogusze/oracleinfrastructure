show parameter log;
select * from v$instance;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select * from v$archived_log order by completion_time desc;
-- itest
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('+RECO/OEBSTEST/ARCHIVELOG/2016_08_08/thread_2_seq_1500.799.919376753');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/DEMOR2/arch_1_337_918997229.log');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/SITR2/arch_1_2102_928476598.dbf');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/SITR2/arch_1_2167_928476598.dbf');
EXECUTE DBMS_LOGMNR.ADD_LOGFILE ('/opt/app/oraarch/SITR2/arch_1_2214_928476598.dbf');

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

select count(*), seg_name from (
select seg_name
from v$logmnr_contents
) group by seg_name order by count(*) desc
;

select count(*), operation from (
select operation
from v$logmnr_contents
) group by operation order by count(*) desc
;

select count(*), DATA_OBJ# from (
select DATA_OBJ#
from v$logmnr_contents
) group by DATA_OBJ# order by count(*) desc
;

select * from dba_objects where object_name = 'QP_PREQ_QUAL_TMP_N6';


-- From https://orainternals.wordpress.com/2013/06/12/dude-where-is-my-redo/

drop table redo_analysis_212_2;
CREATE TABLE redo_analysis_212_2 nologging AS
SELECT data_obj#, oper,
  rbablk * le.bsz + rbabyte curpos,
  lead(rbablk*le.bsz+rbabyte,1,0) over (order by rbasqn, rbablk, rbabyte) nextpos
FROM
  ( SELECT DISTINCT data_obj#, operation oper, rbasqn, rbablk, rbabyte
  FROM v$logmnr_contents
  ORDER BY rbasqn, rbablk, rbabyte
  ) ,
  (SELECT MAX(lebsz) bsz FROM x$kccle ) le 
/


select data_obj#, oper, obj_name, sum(redosize) total_redo
from
(
select data_obj#, oper, obj.name obj_name , nextpos-curpos-1 redosize
from redo_analysis_212_2 redo1, sys.obj$ obj
where (redo1.data_obj# = obj.obj# (+) )
and  nextpos !=0 -- For the boundary condition
and redo1.data_obj#!=0
union all
select data_obj#, oper, 'internal ' , nextpos-curpos  redosize
from redo_analysis_212_2 redo1
where  redo1.data_obj#=0 and  redo1.data_obj# = 0
and nextpos!=0
)
group by data_obj#, oper, obj_name
order by 4 desc
;



Select DBMS_ROWID.rowid_object('AAicoAAAAAAAAAAAAA') from dual;
Select object_name, object_type, owner from dba_objects where object_id = 9030144;
