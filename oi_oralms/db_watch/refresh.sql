--from https://vishaldesai.wordpress.com/2013/07/01/273/
--Usage: refresh.sql "sql script name" interval sample
set feed off
set head off
set echo off
set term off
set linesize 120
set verify off
spool refresh_1.sql
set feedback off
set feed off
set serveroutput on 
select cmd from (
select '@' || '&1'  as cmd from dual
union all
select '!sleep &2;' as cmd from dual
union all
select 'clear scr' as cmd from dual
) , (select rownum from dual connect by level <=&3) ;
spool off
set term on
set serveroutput on
set head on
clear scr
@refresh_1.sql
exit
