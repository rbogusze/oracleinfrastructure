#!/bin/bash
# $Id$
#
# This script will try to login to DB account as a user and password 
# provided in db_users_list.txt
#
# Sample usage: 
#
# *** Start of Configuration section ***
RECIPIENTS="remigiusz.boguszewicz@gmail.com"

# *** End of Configuration section ***
# Load usefull functions
if [ ! -f ~/scripto/bash/bash_library.sh ]; then
  echo "[error] ~/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ~/scripto/bash/bash_library.sh
fi

#INFO_MODE=DEBUG
INFO_MODE=INFO

# Sanity checks
F_DB_USERS_LIST="./db_users_list.txt"
check_file $F_DB_USERS_LIST

F_TMP="db_users_check.tmp"

V_SQLPLUS=`which sqlplus`
msgd "V_SQLPLUS: $V_SQLPLUS"
check_file $V_SQLPLUS

run_command_e "touch $F_TMP" > /dev/null

msgi "Looping through users and trying to log in:"
while read LINE
do
  msgd "Checking $LINE"
  V_USERNAME=`echo $LINE | awk '{print $1}'`
  msgd "V_USERNAME: $V_USERNAME"
  check_parameter $V_USERNAME

  V_PASSWORD=`echo $LINE | awk '{print $2}'`
  msgd "V_PASSWORD: $V_PASSWORD"
  check_parameter $V_PASSWORD
  
  echo "select * from dual;" | $V_SQLPLUS -s ${V_USERNAME}/${V_PASSWORD} > $F_TMP
  run_command_d "cat $F_TMP"

  TPM_CHK=`cat $F_TMP | wc -l`
  msgd "TPM_CHK: $TPM_CHK"

  if [ $TPM_CHK -gt 5 ]; then
    msgd "Unable to login to $V_USERNAME using password $V_PASSWORD"
  else
    echo "Account $V_USERNAME can be accessed using password: $V_PASSWORD"
  fi


done < $F_DB_USERS_LIST

rm -f $F_TMP

msgi "Done."
