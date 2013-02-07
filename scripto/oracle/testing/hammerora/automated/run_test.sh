#!/bin/bash
#$Id: run_test.sh,v 1.20 2009/11/25 10:01:02 remikcvs Exp $
#
# Sample usage: 
# *** Start of Configuration section ***
LOCKFILE=/tmp/hammer.lock
VIRTUAL_USER=50
LOG_DIR=/tmp
TAG_ID=`date +%Y%m%d_%H%M`
STATIC_LOG=$LOG_DIR/$TAG_ID/static_info.txt
IOSTAT_LOG=$LOG_DIR/$TAG_ID/iostat.txt
CPUSTAT_LOG=$LOG_DIR/$TAG_ID/cpustat.txt
COUNTER_LOG=$LOG_DIR/$TAG_ID/counter.txt

# Assumptions:
# 1. You can connect to remote host withou beeing asked for password
# 2. Default passwords: system/manager, perfstat/perfhal
# 3. Service name: ORACLE

# Sample usage:
# $ ./run_test.sh oracle siwa5

# *** End of Configuration section ***
# Load usefull functions
if [ ! -f ~/scripto/bash/bash_library.sh ]; then
  echo "[error] ~/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ~/scripto/bash/bash_library.sh
fi

RECIPIENTS='Remigiusz_Boguszewicz'

# Sanity checks
OS_USER_NAME=$1
HOST_NAME=$2

check_parameter $OS_USER_NAME
check_parameter $HOST_NAME

#check_lock $LOCKFILE
touch $LOCKFILE

# Functions

# Remote run from the command line
rrun_from_cl()
{ 
  COMMAND_FILE_CONTENT=$1
  echo $COMMAND_FILE_CONTENT | ssh -T -o BatchMode=yes -o ChallengeResponseAuthentication=no -o PasswordAuthentication=no -o PubkeyAuthentication=yes -o RSAAuthentication=no -2 -l $OS_USER_NAME $HOST_NAME
} #/rrun_from_cl

# Actual work
mkdir $LOG_DIR/$TAG_ID

msg "Launch one time before the test"
rrun_from_cl "uname -a" > $STATIC_LOG
rrun_from_cl "psrinfo -v" >> $STATIC_LOG
rrun_from_cl "mount" >> $STATIC_LOG
rrun_from_cl "df -h" >> $STATIC_LOG

msg "Get the location of alert log"
echo "select VALUE from v\$parameter where name = 'background_dump_dest';" | sqlplus system/manager@oracle > tmp_output.txt
BKGR_DUMP=`cat tmp_output.txt | grep --after-context=2 VALUE | grep -v VALUE | grep -v "\-\-"`
echo $BKGR_DUMP
rm tmp_output.txt

#msg "Rereshing the alert log, to have only the contents of the test"
#rrun_from_cl "mv $BKGR_DUMP/alert_\${ORACLE_SID}.log $BKGR_DUMP/alert_\${ORACLE_SID}.log_`date +%Y%m%d_%H%M`"

#msg "Restarting the database"
#rrun_from_cl "echo 'startup force;' | sqlplus '/ as sysdba'"

msg "Taking statspack snapshot"
echo "execute statspack.snap;" | sqlplus perfstat/perfhal@oracle 

#msg "Launch the counter"
#./counter.tcl > $COUNTER_LOG 2>&1 &
#COUNTER_PID=$!

# Launch the virtual users.
CURRENT_USER=0
while [ "${CURRENT_USER}" -ne "${VIRTUAL_USER}" ]
do
  echo "Uruchamiam w tle uzytkownika: ${CURRENT_USER}" 
  ./driver.tcl > /dev/null 2>&1 &
  BACKGROUND_PID=$!
  #echo "$BACKGROUND_PID"
  BACKGROUND_PID_ARRAY[$CURRENT_USER]=$BACKGROUND_PID
  CURRENT_USER=`expr ${CURRENT_USER} + 1`
done

# Check if the virtual users are still running
#echo "I have launched the following pids: ${BACKGROUND_PID_ARRAY[0]} ${BACKGROUND_PID_ARRAY[1]}"

RUN_PROC_COUNT=1
until [ "$RUN_PROC_COUNT" -eq 0 ]
do 
  RUN_PROC_COUNT=0
  for i in "${BACKGROUND_PID_ARRAY[@]}"
  do
    #echo "$i"
    #echo "Checking if PID $i is still running"
    RUN_PROC=`ps -p $i | egrep -v '(PID|grep)' | wc -l`
    #echo $RUN_PROC
    if [ $RUN_PROC -eq 1 ]; then
      #echo "The current RUN_PROC_COUNT is $RUN_PROC_COUNT , I will add + 1"
      RUN_PROC_COUNT=`expr $RUN_PROC_COUNT + 1`
    fi
  done

  # Running task that should be run through the test
  echo "Running task that should be run through the test"
  date >> $IOSTAT_LOG
  rrun_from_cl "iostat -xnz 3 4" >> $IOSTAT_LOG &
  date >> $CPUSTAT_LOG
  rrun_from_cl "mpstat 3 4" >> $CPUSTAT_LOG &

  echo "Sleeping 10 sek. There are still $RUN_PROC_COUNT processes running."
  sleep 10
done

# One time actions after the test
msg "Taking statspack snapshot"
echo "execute statspack.snap;" | sqlplus perfstat/perfhal@oracle 

msg "Killing the counter"
kill -9 $COUNTER_PID

msg "Koniec testu."
# /Actual work
# Remove lock file
rm -f $LOCKFILE
