prompt SQL text

prompt Generating spool file name
set heading off
spool /tmp/spool_date.sql
select 'spool /tmp/sqlplan_'||to_char(sysdate, 'yyyymmddHH24MISS')||'.txt' from dual;
spool off
@/tmp/spool_date.sql


prompt provide hash_value as parameter
set linesize 100
set pagesize 200
column OBJECT_NAME format a30

select sql_text from V$SQLTEXT
where hash_value = '&1'
order by piece
;

select operation, options, object_name  from V$SQL_PLAN
where hash_value = '&1'
;

spool off
