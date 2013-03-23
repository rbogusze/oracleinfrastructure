#!/bin/bash
#$Id$
#
# This will perform an automated DB restore/recovery for testing purposes
# !!! DANGER !!!
# This script as a first step will DELETE the running database - with the idea to replace it with the new one.
#
# Example:
# ./auto_restore_from_location.sh /mnt/backup/TEST10
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

LOG_DIR=/var/tmp/auto_restore_from_location
LOG_NAME=auto_restore_from_location_${ORACLE_SID}.log

INFO_MODE=DEBUG

V_DATE=`$DATE '+%Y-%m-%d--%H%M%S'`
msgd "V_DATE: $V_DATE"

# Sanity checks
mkdir -p $LOG_DIR
check_directory $LOG_DIR

LOG=${LOG_DIR}/${LOG_NAME}.$V_DATE
#exec > $LOG 2>&1

D_BACKUP_DIR=$1
check_parameter $D_BACKUP_DIR

msgi "Get ORACLE_SID from dir name"
export ORACLE_SID=`echo $D_BACKUP_DIR | awk -F"/" '{print $NF}'`
msgd "ORACLE_SID: $ORACLE_SID"

msgi "Based on ORACLE_SID: $ORACLE_SID setup the environment"
export ORAENV_ASK=NO
  . oraenv
unset ORAENV_ASK

msgd "ORACLE_SID: $ORACLE_SID"
msgd "ORACLE_HOME: $ORACLE_HOME"





