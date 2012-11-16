set feedback off
set verify off
set serveroutput on
set termout on

exec dbms_output.put_line('Starting build select of columns to be altered');

drop table sys.semantics$
/

create table sys.semantics$(s_owner varchar2(40),
s_table_name varchar2(40),
s_column_name varchar2(40),
s_data_type varchar2(40),
s_char_length number,
s_updated varchar2(1 char))
/

insert into sys.semantics$
select C.owner, C.table_name, C.column_name, C.data_type, C.char_length, 'N'
from all_tab_columns C, all_tables T
where C.owner = T.owner
and C.table_name = T.table_name
-- only VARCHAR2 and CHAR columns are needed
and C.data_type in ('VARCHAR2', 'CHAR')
-- only need to look for tables who are not yet CHAR semantics.
and C.char_used = 'B'
-- exclude partitioned, temp and IOT tables, they have no tablespace
and T.TABLESPACE_NAME is not null
-- exclude invalid tables
and T.STATUS = 'VALID'
-- exclude recyclebin tables
and T.DROPPED = 'NO'
-- exclude External tables
and C.table_name not in (select table_name from all_external_tables)
-- Adapt here the list of users you want to change
-- and T.owner in ('OSW','ALKON','KAZETPE')
-- alternatively you can exclude Oracle provided users:
and T.owner not in
('DBSNMP','MGMT_VIEW','SYSMAN','TRACESVR','AURORA$ORB$UNAUTHENTICATED',
'AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','MDSYS','MDDATA','ORDSYS','OUTLN',
'ORDPLUGINS','SI_INFORMTN_SCHEMA','CTXSYS','WKSYS','WKUSER','WK_TEST',
'REPADMIN','LBACSYS','DVF','DVSYS','ODM','ODM_MTR','DMSYS','OLAPSYS',
'WMSYS','ANONYMOUS','XDB','EXFSYS','DIP','TSMSYS','SYSTEM','SYS','APPQOSSYS')
/
commit
/
declare
cursor c1 is select rowid,s.* from sys.semantics$ s where s_updated='N';
v_statement varchar2(255);
v_nc number(10);
v_nt number(10);
begin
execute immediate 
'select count(*) from sys.semantics$ where s_updated=''N''' into v_nc;
execute immediate 
'select count(distinct s_table_name) from sys.semantics$ where s_updated=''N''' into v_nt;
dbms_output.put_line
('ALTERing ' || v_nc || ' columns in ' || v_nt || ' tables');
for r1 in c1 loop
v_statement := 'ALTER TABLE "' || r1.s_owner || '"."' || r1.s_table_name;
v_statement := v_statement || '" modify ("' || r1.s_column_name || '" ';
v_statement := v_statement || r1.s_data_type || '(' || r1.s_char_length;
v_statement := v_statement || ' CHAR))';
-- To have the statements only uncomment the next line and comment the execute immediate
-- dbms_output.put_line(v_statement);
execute immediate v_statement;
update sys.semantics$ set s_updated = 'Y' where rowid=r1.rowid;
Commit;
end loop;
dbms_output.put_line('Done');
end;
/
