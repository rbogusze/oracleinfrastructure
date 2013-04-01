column CURRENT_SCN format 999999999999999;
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select inc.INCARNATION#, inc.RESETLOGS_TIME, db.name, db.current_scn, sysdate from V$DATABASE_INCARNATION inc, v$database db where inc.STATUS='CURRENT';

