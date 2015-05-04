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

f3_execute_sql "select username from dba_users where username like '%DVO%' or username like '%DVAM%';"
cat $F_EXECUTE_SQL
echo
