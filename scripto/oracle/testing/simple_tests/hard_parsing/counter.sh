#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./counter scott tiger DB

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
INFO_MODE=INFO

USER=$1
PASS=$2
DB=$3

msgd "USER: $USER"
check_parameter $USER
msgd "PASS: $PASS"
check_parameter $PASS
msgd "DB: $DB"
check_parameter $DB

msgi "ala"
V_PREVIOUS=0
while [ 1 ]
do
  f_user_execute_sql "select name, value from v\$sysstat where name = 'parse count (hard)';" "$USER/$PASS@$DB"
  msgd "$V_EXECUTE_SQL"
  V_CURRENT=`echo $V_EXECUTE_SQL | awk '{print $NF}'`
  msgd "V_PREVIOUS: $V_PREVIOUS"
  V_DELTA=`expr ${V_CURRENT} - ${V_PREVIOUS} `
  echo $V_DELTA

  sleep 5
  V_PREVIOUS=$V_CURRENT
done


