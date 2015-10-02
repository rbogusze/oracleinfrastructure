#!/bin/bash
# This script loops through the initial_checks dir, executes the tasks and compares it to expected results
# The SID of the DB to connect to is stored in ~/.LT_SID

INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

# Assuming connections as apps to DB stored in ~/.LT_SID
f_LT_execute_sql()
{
  msgd "${FUNCNAME[0]} Begin."

  msgd "${FUNCNAME[0]} End."
} #f_LT_execute_sql


# Actual run
# Loop through the initial_checks dir, executes the tasks and compares it to expected results
D_BASE=~/scripto/ebs/LT_monitoring
D_INITIAL_CHECKS=$D_BASE/initial_checks

check_directory $D_INITIAL_CHECKS

for F_IC in `ls ${D_INITIAL_CHECKS}`
do
  echo $F_IC
  IC_ACTION=`head -1 ${D_INITIAL_CHECKS}/${F_IC}`
  msgd "IC_ACTION: $IC_ACTION"
  case $IC_ACTION in
  "execute_sql")
    msgd "execute_sql"
    f_LT_execute_sql ${D_INITIAL_CHECKS}/${F_IC}
    ;;
  *)
    echo "Unknown action!!! Exiting."
    exit 1
    ;;
  esac
  
done





