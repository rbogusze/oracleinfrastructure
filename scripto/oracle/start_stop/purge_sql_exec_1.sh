#!/bin/bash

LOG_DIR=/tmp/purge_sql_exec_1
mkdir -p $LOG_DIR

#checking if ORACLE_HOME and ORACLE_SID are set
if [ -z "$ORACLE_HOME" ] || [ -z "$ORACLE_SID" ] ; then
  echo "ORACLE_HOME or ORACLE_SID not set. Please set the DB environment. Exiting"
  exit 1
fi

F_LIST=candidates_`date '+%Y%m%d%H%M%S'`


echo "Get the list of SQLs executed only once"
sqlplus -S / as sysdba << EOF > $LOG_DIR/$F_LIST
set heading off
set feedback off
set pagesize 0
select address, hash_value from v\$sqlarea where executions = 1 and sql_text not like '%dbms_shared_pool.purge%';
exit;
EOF

F_EXEC=purge_commands_`date '+%Y%m%d%H%M%S'`.sql
echo "Looping through the list to prepare purge commands"
while read LINE
do
  V_PURGE=`echo $LINE | awk '{print "exec dbms_shared_pool.purge (\047"$1","$2"\047,\047C\047);"}' `
  echo $V_PURGE

  echo "Executing the purge"
  sqlplus -S / as sysdba << EOF 
$V_PURGE
exit;
EOF

done < $LOG_DIR/$F_LIST

