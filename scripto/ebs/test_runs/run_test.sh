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
  CN=`cat ~/.LT_SID`  
  msgd "CN: $CN"

  tnsping ${CN} > /tmp/run_initial_checks_tnsping.txt
  if [ $? -eq 0 ]; then
    msgd "OK, tnsping works"
  else
    msge "Error, tnsping $CN does not work. Exiting"
    run_command_d "cat /tmp/run_initial_checks_tnsping.txt"
    exit 1
  fi

  # file name with instructions
  F_LT=$1
  msgd "F_LT: $F_LT" 
  run_command_d "cat $F_LT"

  # Get the SQL to be executed
  V_SQL=`cat $F_LT`
  msgd "V_SQL: $V_SQL"

  V_USER=apps
  msgd "Getting password from hash"
 
  PWD_FILE=~/.passwords
  INDEX_HASH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbRrdoraIndexHash']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
  msgd "INDEX_HASH: $INDEX_HASH"
  HASH=`echo "$INDEX_HASH" | base64 --decode -i`
  msgd "HASH: $HASH"
  if [ -f "$PWD_FILE" ]; then
    V_PASS=`cat $PWD_FILE | grep $HASH | awk '{print $2}' | base64 --decode -i`
    #msgd "V_PASS: $V_PASS"
  else
    msge "Unable to find the password file. Exiting"
    exit 0
  fi

  # OK, I have username, password and the database, it is time to connect
  testavail=`sqlplus -S /nolog <<EOF
set head off pagesize 0 echo off verify off feedback off heading off
connect $V_USER/$V_PASS@$CN
select trim(1) result from dual;
exit;
EOF`

  if [ "$testavail" != "1" ]; then
    msge "DB $CN not available, exiting !!"
    exit 0
  fi


  F_TMP=/tmp/run_initial_checks_execute.txt
  msgd "Run with autotrace on"
  sqlplus -s /nolog << EOF > $F_TMP
  set head off pagesize 0 echo off verify off feedback off heading off
  connect $V_USER/$V_PASS@$CN
  set timing on
  set autotrace traceonly
  $V_SQL
EOF
 
  # Saving the received values 
  run_command_d "cat $F_TMP"
  V_LT_RESULT_ELAPSED=`cat $F_TMP | grep "^Elapsed:" | sed -e 's/Elapsed:\ //'`
  msgd "V_LT_RESULT_ELAPSED: $V_LT_RESULT_ELAPSED"
  V_LT_RESULT_GETS=`cat $F_TMP | grep "consistent gets" | awk '{print $1}' `
  msgd "V_LT_RESULT_GETS: $V_LT_RESULT_GETS"
  V_LT_RESULT=`cat $F_TMP | head -1 | awk '{print $1}' `
  msgd "V_LT_RESULT: $V_LT_RESULT"




  msgd "${FUNCNAME[0]} End."
} #f_LT_execute_sql


# Actual run
# Loop through the initial_checks dir, executes the tasks and compares it to expected results
D_BASE=~/scripto/ebs/TestRuns
D_INITIAL_CHECKS=$D_BASE/test_store

check_directory $D_INITIAL_CHECKS

for F_IC in `ls -1t ${D_INITIAL_CHECKS}`
#for F_IC in `ls ${D_INITIAL_CHECKS}`
do
  echo $F_IC

  f_LT_execute_sql ${D_INITIAL_CHECKS}/${F_IC}

exit 0
  
done





