prompt Show tables with rowcound in user schemas except known admin schemas

set pagesize 0
spool tabstat.log

select owner||'.'||table_name cnt
from dba_tables
where owner not in 
('DBSNMP','MGMT_VIEW','SYSMAN','TRACESVR','AURORA$ORB$UNAUTHENTICATED',
'AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','MDSYS','MDDATA','ORDSYS','OUTLN',
'ORDPLUGINS','SI_INFORMTN_SCHEMA','CTXSYS','WKSYS','WKUSER','WK_TEST',
'REPADMIN','LBACSYS','DVF','DVSYS','ODM','ODM_MTR','DMSYS','OLAPSYS',
'WMSYS','ANONYMOUS','XDB','EXFSYS','DIP','TSMSYS','SYSTEM','SYS','APPQOSSYS','PERFSTAT')
order by owner, table_name
/

spool off
exit
