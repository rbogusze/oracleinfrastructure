#!/bin/bash
# Info: Check if system is paging
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


f_execute_sql "show parameter cluster_database"
cat $F_EXECUTE_SQL

f_execute_sql "@/ood_repository/patches/$ORACLE_SID/DATABASE11G_AUTOMATION_11R204_WRK/sql/check_database"
cat $F_EXECUTE_SQL
