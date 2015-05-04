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


f3_execute_sql "@/ood_repository/patches/$ORACLE_SID/DATABASE11G_AUTOMATION_11R204_WRK/sql/check_tbls_dict.sql"
cat $F_EXECUTE_SQL
echo
