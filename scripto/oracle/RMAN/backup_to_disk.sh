#!/bin/bash
#$Id: backup_to_disk.sh,v 1.1 2012-05-07 13:48:30 remik Exp $
#
# Example:
# With RMAN repository:
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID <MODE>
# or
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID <MODE> CATALOG
#
# Without RMAN repository:
# ./backup_to_disk.sh /BACKUP/$HOSTNAME/$ORACLE_SID <MODE> NOCATALOG
#
# Where <MODE> can be:
# FULL - for full backup
# ARCH - for archivelog backup
# ARCHCC - for archivelog backup with crosscheck before (usefull on weird situation on standby)
# INC0 - incremental backup level 0
# INC1 - incremental backup level 1
# CUM1 - cumulative backup level 1

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
exec > $LOG 2>&1

D_BACKUP_DIR=$1
V_BACKUP_TYPE=$2
V_CATALOG=$3

check_parameter $D_BACKUP_DIR
check_parameter $V_BACKUP_TYPE

msgi "Sanity check. If the database we want to backup is up"
TMP_CHK=`ps -ef | grep -v 'grep' | grep ora_pmon_${ORACLE_SID}`
msgd "TMP_CHK: $TMP_CHK"
TMP_CHK_NR=`ps -ef | grep -v 'grep' | grep ora_pmon_${ORACLE_SID} | wc -l`
msgd "TMP_CHK_NR: $TMP_CHK_NR"

if [ "$TMP_CHK_NR" -gt 0 ]; then
  msgi "OK, DB ${ORACLE_SID} looks to be up. Continuing."
else
  msgi "No pmon for DB ${ORACLE_SID} is running. Exiting."
  exit 0
fi

msgd "Analysing the whether we use the RMAN repository or not."
if [ -z "$V_CATALOG" ] ; then
  msgi "[info] Not specified whether I should use catalog repository. Assuming NOCATALOG."
  V_CATALOG=NOCATALOG
fi
case $V_CATALOG in 
  "CATALOG")
    msgi "Using repository catalog"
    RMAN="rman target / catalog rman/xxxx@RMAN"
  ;;
  "NOCATALOG")
    msgi "NOT using repository catalog"
    RMAN="rman target / nocatalog"
  ;;
  *)
    msge "Unknown value for V_CATALOG: $V_CATALOG Exiting."
    exit 1
    ;;
esac

msgd "RMAN: $RMAN"
msgd "D_BACKUP_DIR: $D_BACKUP_DIR"

run_command_e "mkdir -p $D_BACKUP_DIR"
run_command_e "touch $D_BACKUP_DIR/testing_if_writable"
run_command "sleep 1"
run_command "rm -f $D_BACKUP_DIR/testing_if_writable"

msgd "Determining action based on V_BACKUP_TYPE: $V_BACKUP_TYPE"
case $V_BACKUP_TYPE in
  "FULL")
    msgi "Running $V_BACKUP_TYPE backup"
    f_execute_sql "create pfile='$D_BACKUP_DIR/pfile_$V_DATE' from spfile;"
    check_file "$D_BACKUP_DIR/pfile_$V_DATE"

    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    BACKUP DATABASE FORMAT "$D_BACKUP_DIR/db_%U";
    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    BACKUP CURRENT CONTROLFILE FORMAT '$D_BACKUP_DIR/ctrl_$V_DATE';
    show all;
    REPORT OBSOLETE;
    DELETE NOPROMPT OBSOLETE;
    # delete achivelogs, not backups of them that are older than 2 days
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
}
EOF
    ;;
  "ARCH")
    msgi "Running $V_BACKUP_TYPE backup"
    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    BACKUP CURRENT CONTROLFILE FORMAT '$D_BACKUP_DIR/ctrl_${V_DATE}';
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
}
EOF
    ;;
  "ARCHCC")
    msgi "Running $V_BACKUP_TYPE backup"
    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    CROSSCHECK COPY OF ARCHIVELOG ALL;
    CROSSCHECK ARCHIVELOG ALL;
    DELETE NOPROMPT FORCE OBSOLETE; 
    DELETE NOPROMPT EXPIRED ARCHIVELOG ALL; 

    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
}
EOF
    ;;
  "INC0")
    msgi "Running $V_BACKUP_TYPE backup"
    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    BACKUP INCREMENTAL LEVEL 0 DATABASE FORMAT "$D_BACKUP_DIR/inc0_%U";
    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
    REPORT OBSOLETE;
    DELETE NOPROMPT OBSOLETE;
}
EOF
    ;;
  "INC1")
    msgi "Running $V_BACKUP_TYPE backup"
    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    BACKUP INCREMENTAL LEVEL 1 DATABASE FORMAT "$D_BACKUP_DIR/inc1_%U";
    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
}
EOF
    ;;
  "CUM1")
    msgi "Running $V_BACKUP_TYPE backup"
    msgd "Running RMAN commands, output in $LOG_DIR/${LOG_NAME}_rman.$V_DATE"
    $RMAN <<EOF | tee $LOG_DIR/${LOG_NAME}_rman.$V_DATE
SET ECHO ON
RUN
{
    ALLOCATE CHANNEL ch1 TYPE DISK;
    BACKUP INCREMENTAL LEVEL 1 CUMULATIVE DATABASE FORMAT "$D_BACKUP_DIR/cum1_%U";
    BACKUP ARCHIVELOG ALL format '$D_BACKUP_DIR/arch_%U';
    DELETE NOPROMPT ARCHIVELOG UNTIL TIME "sysdate-2" BACKED UP 1 TIMES TO DEVICE TYPE DISK;
}
EOF
    ;;
  *)
    echo "Unknown backup type !!! Exiting."
    exit 1
    ;;
esac


msgd "Greping RMAN log for 'RMAN-' which would indicate errors"

ERROR_MSG=`$GREP -i -e "RMAN-" -e "Error" $LOG_DIR/${LOG_NAME}_rman.$V_DATE` 
if [ ! -z "$ERROR_MSG" ]; then
  error_log "[error] An error occured during running $0 " ${RECIPIENTS}
fi

msgi "Done"
