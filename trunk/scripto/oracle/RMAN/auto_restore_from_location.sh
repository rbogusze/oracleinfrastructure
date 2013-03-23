#!/bin/bash
#$Id::$
#
# Example:
# With RMAN repository:
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID
# or
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID <MODE> CATALOG
#
# Without RMAN repository:
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID <MODE> NOCATALOG
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

LOG_DIR=/var/tmp/backup_to_disk
LOG_NAME=backup_to_disk_${ORACLE_SID}.log
LOCKFILE=/tmp/backup_to_disk_${ORACLE_SID}.lock
#INFO_MODE=DEBUG

V_DATE=`$DATE '+%Y-%m-%d--%H%M%S'`
msgd "V_DATE: $V_DATE"

# Sanity checks
mkdir -p $LOG_DIR
check_directory $LOG_DIR

LOG=${LOG_DIR}/${LOG_NAME}.$V_DATE
#exec > $LOG 2>&1

D_BACKUP_DIR=$1

check_parameter $D_BACKUP_DIR

