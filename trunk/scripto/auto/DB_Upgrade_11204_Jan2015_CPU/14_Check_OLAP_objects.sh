#!/bin/bash
# Info: Check if system is paging
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

run_command_e "cd /ood_repository/patches/$ORACLE_SID/DATABASE11G_AUTOMATION_11R204_WRK/OLAP"
f3_execute_sql "set pages 50
column OWNER format a10 
column AW_NAME format a28
@check_aws.sql"
cat $F_EXECUTE_SQL
echo
