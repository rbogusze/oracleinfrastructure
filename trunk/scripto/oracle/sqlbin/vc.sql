alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate, count(1) from dba_objects where status != 'VALID';
