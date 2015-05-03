#!/bin/bash
# Info: Check if system is paging
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

msgi "Check current DST settings"
f_execute_sql "@/autofs/upgrade/DB_AUTOMATION/DST_UPDATE/check_DST.sql"
cat $F_EXECUTE_SQL
