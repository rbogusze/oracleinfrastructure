#!/bin/bash
#$Id: get_statspack.sh,v 1.12 2011/08/01 10:01:30 remikcvs Exp $
#
#
# Example
# ./get_statspack.sh red_obsdb1 perfstat 2006-07-02--07:07 2006-07-02--22:07
#
#
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

RECIPIENTS='remigiusz_boguszewicz'
INFO_MODE=DEBUG

# Variables
SQLPLUS=sqlplus
TNSPING=tnsping

# Sanity checks
check_parameter $1
check_parameter $2
check_parameter $3
check_parameter $4
check_directory $HISTORY_DIR
check_directory $TEMP_DIR

msgd "Provided parameter 1: $1"
msgd "Provided parameter 2: $2"
msgd "Provided parameter 3: $3"
msgd "Provided parameter 4: $4"

SERVICE_NAME=$1
USER_NAME="perfstat"
USER_PASSWORD=$2
SNAP_START=$3
SNAP_END=$4

TEMP_DIR=/tmp
RUNNING_DIR=`pwd`
HISTORY_DIR=/var/www/html/statspack_reports
TEMP_HASH=${TEMP_DIR}/hash_list_$SERVICE_NAME.txt
RETREIVE_HASHES=$RUNNING_DIR/retreive_hashes.php
GET_DIAGNOSTIC=$RUNNING_DIR/get_diagnostic.sh

run_command_e "mkdir -p ${HISTORY_DIR}/${SERVICE_NAME}"

# Extract date from SNAP_START for hash history
HASH_DATE=`echo $SNAP_START | awk -F"--" '{print $1}'`
msgd "HASH_DATE: $HASH_DATE"

${TNSPING} $SERVICE_NAME >> /tmp/tnsping.out
# Check the sucsess status if TNSPING
if [ ! $? -ne 0 ]; then
  msgd "TNSPING to ${SERVICE_NAME} was sucessfull, now ask the questions."

  msgd "Determine the Oracle version"
  ${SQLPLUS} -s ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF > /dev/null
set heading off
set echo off
spool ${TEMP_DIR}/db_version.tmp
select VERSION from v\$instance;
EOF

  V_RDBMS_VERSION=`cat ${TEMP_DIR}/db_version.tmp | grep -v "^$" | awk -F"." '{ print $1 "." $2 }'`
  msgd "V_RDBMS_VERSION: $V_RDBMS_VERSION"

  case $V_RDBMS_VERSION in
  "9.2")
    msge "Old db release, go back to old defcon :) Exiting." 
    exit 1
    ;;
  "10.2")
    D_SP_SQL=$RUNNING_DIR/sp10g
    ;;
  "11.1"|"11.2")
    D_SP_SQL=$RUNNING_DIR/sp11g
    ;;
  *)
    msge "Unknown rdbms version: $V_RDBMS_VERSION. Exiting"
    exit 0
    ;;
  esac
    msgd "Directory from which are statspack scripts run, varies by db version"
    msgd "D_SP_SQL: $D_SP_SQL"

  msgd "Get SNAP_START_ID"
  ${SQLPLUS} ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF > /tmp/get_statspack_sqlplus.out
set heading off
set echo off
spool ${TEMP_DIR}/statspack.tmp
select min(snap_id) from stats\$snapshot where ROUND(snap_time, 'MI') between to_date('${SNAP_START}','YYYY-MM-DD--HH24:MI')-1/24/12 and  to_date('${SNAP_END}','YYYY-MM-DD--HH24:MI')+1/24/12 ;
EOF
  run_command_d "cat /tmp/get_statspack_sqlplus.out" 

  SNAP_START_ID=`cat ${TEMP_DIR}/statspack.tmp | grep -v "^$" | grep -v "^SQL>" |  grep -v "no rows selected" | sed -e 's/ //g'`
  msgd "SNAP_START_ID: $SNAP_START_ID"

  msgd "Get SNAP_END_ID"
  ${SQLPLUS} ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF > /tmp/get_statspack_sqlplus.out
set heading off
set echo off
spool ${TEMP_DIR}/statspack.tmp
select max(snap_id) from stats\$snapshot where ROUND(snap_time, 'MI') between to_date('${SNAP_START}','YYYY-MM-DD--HH24:MI')-1/24/12 and to_date('${SNAP_END}','YYYY-MM-DD--HH24:MI')+1/24/12 ;
EOF
  run_command_d "cat /tmp/get_statspack_sqlplus.out" 

  SNAP_END_ID=`cat ${TEMP_DIR}/statspack.tmp | grep -v "^$" | grep -v "^SQL>" |  grep -v "no rows selected" | sed -e 's/ //g'`
  msgd "SNAP_END_ID: $SNAP_END_ID"

  msgd "Run report"
  ${SQLPLUS} ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF > /tmp/get_statspack_sqlplus.out
set heading off
set echo off
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=".,";
spool ${TEMP_DIR}/statspack.tmp
define begin_snap=$SNAP_START_ID
define end_snap=$SNAP_END_ID
define report_name=${HISTORY_DIR}/${SERVICE_NAME}/snap_${SNAP_START}_${SNAP_END}.lst
@$D_SP_SQL/spreport
EOF

  #cat ${TEMP_DIR}/statspack.tmp
  run_command_d "cat /tmp/get_statspack_sqlplus.out" 

  if [ ! -f ${HISTORY_DIR}/${SERVICE_NAME}/snap_${SNAP_START}_${SNAP_END}.lst ]; then
    msge "Statspack report not generated. Makes no sense to generate the hash table. Exiting"
    exit 1
  fi

  # Retreive hashes from statspack report
  msgd "Retreive hashes from statspack report"
  rm -f ${TEMP_HASH}
  run_command "php ${RETREIVE_HASHES} ${HISTORY_DIR}/${SERVICE_NAME}/snap_${SNAP_START}_${SNAP_END}.lst ${TEMP_HASH}"

  # Prepare directory for hash reports
  mkdir -p $HISTORY_DIR/${SERVICE_NAME}/hash_history/

  # Loop through the hash list and extract the hash report from database
  while read line
  do
    msgd "Extract the report for hash: $line"
    # Retreive hash report
    #${SQLPLUS} ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF > /dev/null
    ${SQLPLUS} ${USER_NAME}/${USER_PASSWORD}@${SERVICE_NAME} << EOF 
set heading off
set echo off
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=".,";
spool ${TEMP_DIR}/statspack_hash.tmp
define begin_snap=$SNAP_START_ID
define end_snap=$SNAP_END_ID
define hash_value=$line
define report_name=${HISTORY_DIR}/${SERVICE_NAME}/hash_history/hash_${line}_${HASH_DATE}.lst
@$D_SP_SQL/sprepsql 
EOF

  done < ${TEMP_HASH}

  # Checkout the diagnostic scripts too
  #disabled now, 2 prio $GET_DIAGNOSTIC ${SERVICE_NAME}
else
  msge "Tnsping was not successfull. Exiting."
  run_command_d "cat /tmp/tnsping.out"
fi # Check the sucsess status if TNSPING

