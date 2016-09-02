#!/bin/bash

#checking if ORACLE_HOME and ORACLE_SID are set
if [ -z "$ORACLE_HOME" ] || [ -z "$ORACLE_SID" ] ; then
  echo "ORACLE_HOME or ORACLE_SID not set. Please set the DB environment. Exiting"
  exit 1
fi



# Flush shared pool 
sqlplus / as sysdba << EOF
prompt Gather current shared pool stats
set linesize 300
select * from v\$sgainfo;
select pool, name, round(bytes/(1024 * 1024)) size_mb from v\$sgastat where pool='shared pool' and bytes > (1024 * 1024) order by size_mb desc;

show parameter instance_name
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;
prompt Executing alter system flush shared_pool
set timing on
alter system flush shared_pool;
exit;
EOF
