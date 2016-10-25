#!/bin/bash
#
# Execute a query through history, like time machine, to spot changes to the base table
#
# $ ./execute_every_second.sh VIS system manager
#
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi
RECIPIENTS='remigiusz.boguszewicz@gmail.com'

#INFO_MODE=DEBUG

CN=$1
V_USER=$2
V_PASS=$3

DATE_START=`date --date="2016-10-25 04:27:00"`
NR_DAYS_BACK=1800
#NR_DAYS_BACK=2

SQL_FILE=./query.sql
TMP_FILE_BASE=/tmp/execute_every_second.tmp

MASTER_FILE=/tmp/execute_every_second.tmp.master
V_RANDOM=$RANDOM
F_EQUAL=/tmp/execute_every_second.tmp.${V_RANDOM}_equal
F_DIFF=/tmp/execute_every_second.tmp.${V_RANDOM}_diff
touch $F_EQUAL
touch $F_DIFF

check_variable $CN
check_variable $V_USER
check_variable $V_PASS
check_file $SQL_FILE

msgd "CN: $CN"
msgd "V_USER: $V_USER"
#msgd "V_PASS: $V_PASS"

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



myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  #CHECK_FOR_DATE=`date '+%Y-%m-%d--%H:%M:%S' -d "$DATE_START $myvar day ago"`
  CHECK_FOR_DATE=`date '+%Y-%m-%d--%H:%M:%S' -d "$DATE_START $myvar seconds ago"`
  msgd "CHECK_FOR_DATE: $CHECK_FOR_DATE"
  TMP_FILE=${TMP_FILE_BASE}_$CHECK_FOR_DATE

  msgd "Executing SQL. Please wait"
  sqlplus -S /nolog << EOF > $TMP_FILE
set head off pagesize 0 echo off verify off heading off
connect $V_USER/$V_PASS@$CN
@$SQL_FILE $CHECK_FOR_DATE
EOF

  #cat $TMP_FILE
  myvar=$(( $myvar + 1 ))

  # if master file does not exists I am creating one based on the last results
  if [ ! -f $MASTER_FILE ]; then
    msgi "Creating master file based on last results"
    cp $TMP_FILE $MASTER_FILE
  fi

  # comparing the results with the master
  diff $MASTER_FILE $TMP_FILE
  if [ $? -eq 0 ]; then
    msgi "No change on $CHECK_FOR_DATE"
    echo "$CHECK_FOR_DATE" >> $F_EQUAL
  else
    msgi "CHANGE!!! on $CHECK_FOR_DATE"
    echo "$CHECK_FOR_DATE" >> $F_DIFF
  fi

#exit 0
done

msgi "Results summary:"
echo "Equal: $F_EQUAL"
cat $F_EQUAL | wc -l

echo "Different: $F_DIFF"
cat $F_DIFF | wc -l

echo "Done."


