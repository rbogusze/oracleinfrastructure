prompt Show tables with rowcound in user schemas except known admin schemas
create or replace
function get_rows( p_tname in varchar2 ) return number
as
    l_columnValue    number default NULL;
begin
    execute immediate
       'select count(*)
          from ' || p_tname INTO l_columnValue;

    return l_columnValue;
end;
/

set pagesize 0
spool tabstat.log

select owner, table_name, get_rows( owner||'.'||table_name) cnt
from dba_tables
where owner not in 
('DBSNMP','MGMT_VIEW','SYSMAN','TRACESVR','AURORA$ORB$UNAUTHENTICATED',
'AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','MDSYS','MDDATA','ORDSYS','OUTLN',
'ORDPLUGINS','SI_INFORMTN_SCHEMA','CTXSYS','WKSYS','WKUSER','WK_TEST',
'REPADMIN','LBACSYS','DVF','DVSYS','ODM','ODM_MTR','DMSYS','OLAPSYS',
'WMSYS','ANONYMOUS','XDB','EXFSYS','DIP','TSMSYS','SYSTEM','SYS','APPQOSSYS')
order by owner, table_name
/

spool off
