#!/bin/bash
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi
RECIPIENTS='remigiusz.boguszewicz@gmail.com'

INFO_MODE=DEBUG

CN=$1
V_USER=$2
V_PASS=$3

SQL_FILE=./query.sql
TMP_FILE=/tmp/execute_every_second.tmp

check_variable $CN
check_variable $V_USER
check_variable $V_PASS
check_file $SQL_FILE

msgd "CN: $CN"
msgd "V_USER: $V_USER"
msgd "V_PASS: $V_PASS"

testavail=`sqlplus -S /nolog <<EOF
set head off pagesize 0 echo off verify off feedback off heading off
connect $V_USER/$V_PASS@$CN
select trim(1) result from dual;
exit;
EOF`

msgd "testavail: $testavail"
if [ "$testavail" != "1" ]; then
  msge "Unable to connected to $CN as $V_USER . Wrong password? Skipping"
  continue
else
  msgi "Running on: $CN as $V_USER"
fi


DATE_START=`date --date="2016-10-21 03:07:00"`
NR_DAYS_BACK=10

myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  #CHECK_FOR_DATE=`date '+%Y-%m-%d--%H:%M:%S' -d "$DATE_START $myvar day ago"`
  CHECK_FOR_DATE=`date '+%Y-%m-%d--%H:%M:%S' -d "$DATE_START $myvar seconds ago"`
  msgd "CHECK_FOR_DATE: $CHECK_FOR_DATE"

  msgd "Executing SQL. Please wait"
  sqlplus -S /nolog << EOF > $TMP_FILE
set head off pagesize 0 echo off verify off heading off
connect $V_USER/$V_PASS@$CN
@$SQL_FILE $CHECK_FOR_DATE
EOF

  cat $TMP_FILE
  myvar=$(( $myvar + 1 ))

#exit 0
done

echo "Done."


