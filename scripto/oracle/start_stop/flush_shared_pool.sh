#!/bin/bash

#checking if ORACLE_HOME and ORACLE_SID are set
if [ -z "$ORACLE_HOME" ] || [ -z "$ORACLE_SID" ] ; then
  echo "ORACLE_HOME or ORACLE_SID not set. Please set the DB environment. Exiting"
  exit 1
fi



# Flush shared pool 
sqlplus / as sysdba << EOF
show parameter instance_name
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;
alter system flush shared_pool;
exit;
EOF
