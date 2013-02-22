#!/bin/bash

# This script will check for corruptions. Build following:
# Doc ID: 283053.1, How To Use RMAN To Check For Logical & Physical Database Corruption
# Should be run with environment file as parameter.

#set -x


# Load usefull functions
if [ ! -f ${HOME}/scripto/bash/bash_library.sh ]; then
  echo "[error] ${HOME}/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${HOME}/scripto/bash/bash_library.sh
fi

LOG_DIR=/var/tmp/rman_logs
LOG_NAME=check_for_corruptions.log
LOCKFILE=/tmp/check_for_corruptions.lock

#
# Running commands

check_file $FIND
check_variable $ORACLE_HOME
check_variable $ORACLE_SID

# Sanity checks
mkdir -p $LOG_DIR
check_directory $LOG_DIR

LOG=${LOG_DIR}/${LOG_NAME}.`date '+%Y-%m-%d--%H:%M:%S'`
exec > $LOG 2>&1

check_lock $LOCKFILE

# Set lock file
touch $LOCKFILE

echo "[info] Deleting this script log files older than 100 days"
$FIND $LOG_DIR -maxdepth 1 -type f -mtime +100 -name "${LOG_NAME}.*" -print -exec rm {} \;

# Actual work
# Function to Checking if corruptions are already known to database run twice before and after RMAN run
db_check_corruptions()
{
check_file $ORACLE_HOME/bin/sqlplus
$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOF > /tmp/contents_DATABASE_BLOCK_CORRUPTION
set feedback off
select * from V\$DATABASE_BLOCK_CORRUPTION;
EOF

run_command "cat /tmp/contents_DATABASE_BLOCK_CORRUPTION"

ERROR_MSG=`cat /tmp/contents_DATABASE_BLOCK_CORRUPTION | grep -v "Polaczono" | grep -v "Connected"` 
if [ ! -z "$ERROR_MSG" ]; then
  error_log "[error] Corruption has been found. Check $LOG" ${RECIPIENTS}
fi
} #/db_check_corruptions

msg "Checking if corruptions are already known to database"
db_check_corruptions

msg "Checking database for corruptions"
check_file $ORACLE_HOME/bin/rman
$ORACLE_HOME/bin/rman "target / nocatalog" <<EOF > /tmp/check_for_corruptions_rman.tmp
run {
allocate channel c1 device type disk ;
backup validate check logical database;
release channel c1;
} 
EOF

run_command "cat /tmp/check_for_corruptions_rman.tmp"

msg "Greping RMAN log for 'RMAN-' which would indicate errors"
msg " (this does not mean that corruptions were found, but RMAN was unable to complete the task)"

ERROR_MSG=`grep "RMAN-" /tmp/check_for_corruptions_rman.tmp` 
if [ ! -z "$ERROR_MSG" ]; then
  error_log "[error] An error occured during running $0 " ${RECIPIENTS}
fi

msg "Checking if corruptions were found"
db_check_corruptions

# /Actual work

# Remove lock file
rm -f $LOCKFILE
