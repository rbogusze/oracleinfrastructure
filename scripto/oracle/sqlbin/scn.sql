column CURRENT_SCN format 999999999999999;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select current_scn, sysdate from v$database;
