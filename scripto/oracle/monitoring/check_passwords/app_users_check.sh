#!/bin/bash
# $Id$
#
# This script will try to login to known application accounts 
# using their default passwords
# 
# I was inspired by $FND_TOP/patch/115/sql/fnddefpw.sql (thank you Sudhakar)
# but added some accounts and passwords
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


F_FNDDEFPW=$FND_TOP/patch/115/sql/fnddefpw.sql
check_file "$F_FNDDEFPW"

V_SQLPLUS=`which sqlplus`
msgd "V_SQLPLUS: $V_SQLPLUS"
check_file $V_SQLPLUS


read -p "[wait] Provide APPS password: " V_APPS_PASS
check_parameter $V_APPS_PASS

# this way
#$V_SQLPLUS apps/$V_APPS_PASS @$F_FNDDEFPW


# Sanity checks
F_APP_USERS_LIST="./app_users_list.txt"
check_file $F_APP_USERS_LIST

F_TMP="app_users_check.tmp"

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
  
  echo "select fnd_web_sec.validate_login('${V_USERNAME}','${V_PASSWORD}') R from dual;" | $V_SQLPLUS -s apps/$V_APPS_PASS > $F_TMP
  run_command_d "cat $F_TMP"

  TPM_CHK=`cat $F_TMP | grep "Y" | wc -l`
  msgd "TPM_CHK: $TPM_CHK"

  if [ $TPM_CHK -eq 1 ]; then
    echo "Account $V_USERNAME can be accessed using password: $V_PASSWORD"
  else
    msgd "Unable to login to $V_USERNAME using password $V_PASSWORD"
  fi


done < $F_APP_USERS_LIST

rm -f $F_TMP

msgi "Done."
