#!/bin/bash
#$Id$
#
# This will perform an automated DB restore/recovery for testing purposes
# !!! DANGER !!!
# This script as a first step will DELETE the running database - with the idea to replace it with the new one.
#
# As a precaution measure no work (harm) will be done unless there is a plain file laying under
# /on_this_system_db_will_be_deleted_and_created_from_backup_dir
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
LOG_NAME=auto_restore_from_location.log
LOCKFILE=/tmp/auto_restore_from_location.lock

INFO_MODE=DEBUG

if [ ! -f /on_this_system_db_will_be_deleted_and_created_from_backup_dir ]; then
  exit 0
fi


# Sanity checks
mkdir -p $LOG_DIR
check_directory $LOG_DIR

V_DATE=`$DATE '+%Y-%m-%d--%H%M%S'`
msgd "V_DATE: $V_DATE"

LOG=${LOG_DIR}/${LOG_NAME}.$V_DATE
exec > $LOG 2>&1

check_lock $LOCKFILE
touch $LOCKFILE

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

msgi "Deleting the current $ORACLE_SID database"
f_execute_sql "shutdown abort"
cat $F_EXECUTE_SQL
f_execute_sql "startup mount restrict"
cat $F_EXECUTE_SQL

RMAN="rman target / nocatalog"

$RMAN <<EOF
SET ECHO ON
delete noprompt archivelog all;
drop database noprompt;
EOF

msgi "Restoring the pfile from the backup location"
if [ -f "$ORACLE_HOME/dbs/init$ORACLE_SID.ora" ]; then
  run_command "mv $ORACLE_HOME/dbs/init$ORACLE_SID.ora /var/tmp/init$ORACLE_SID.ora_`date -I`"
fi

if [ -f "$ORACLE_HOME/dbs/spfile$ORACLE_SID.ora" ]; then
  run_command "mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora /var/tmp/spfile$ORACLE_SID.ora_`date -I`"
fi

V_LAST_PFILE=`ls -1tr $D_BACKUP_DIR | grep pfile | tail -1`
msgd "V_LAST_PFILE: $V_LAST_PFILE"
check_file $D_BACKUP_DIR/$V_LAST_PFILE

V_CONTROL_FILE=`cat $D_BACKUP_DIR/$V_LAST_PFILE | grep -i control_files | awk -F"=" '{print $2}' | awk -F"/" '{print $1"/"$2"/controlfile_01.ctl\047"}'`
msgd "V_CONTROL_FILE: $V_CONTROL_FILE"


run_command "cat $D_BACKUP_DIR/$V_LAST_PFILE | grep -i -v db_cache_size | grep -i -v java_pool_size | grep -i -v large_pool_size | grep -i -v shared_pool_size | grep -i -v streams_pool_size | grep -i -v db_recovery_file_dest_size | grep -i -v pga_aggregate_target | grep -i -v remote_listener | grep -i -v sga_target | grep -i -v control_files > $ORACLE_HOME/dbs/init$ORACLE_SID.ora"
run_command "echo 'db_recovery_file_dest_size=20G' >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora"
run_command "echo 'pga_aggregate_target=500M' >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora"
run_command "echo 'sga_target=2G' >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora"
echo "control_files=$V_CONTROL_FILE" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora


msgi "Startup nomount"
f_execute_sql "startup nomount"
cat $F_EXECUTE_SQL

msgi "Restore last found controlfile backup"
V_LAST_CTRL=`ls -1tr $D_BACKUP_DIR | grep ctrl | tail -1`
msgd "V_LAST_CTRL: $V_LAST_CTRL"
check_file $D_BACKUP_DIR/$V_LAST_CTRL

$RMAN <<EOF
SET ECHO ON
RESTORE CONTROLFILE FROM '$D_BACKUP_DIR/$V_LAST_CTRL';
EOF

msgi "Mount database"
f_execute_sql "alter database mount;"
cat $F_EXECUTE_SQL

msgi "Restore/recover/open"
$RMAN <<EOF
SET ECHO ON
restore database;
recover database;
alter database open resetlogs;
EOF

msgi "Restart database to avoid:"
msgi "Instance XXX, status RESTRICTED, has 1 handler(s) for this service..."
msgi "Which results from the auto registered when the DB is in mounted state ?? (I suspect)"
f_execute_sql "shutdown immediate;"
cat $F_EXECUTE_SQL
f_execute_sql "startup;"
cat $F_EXECUTE_SQL

msgi "Remove lock file"
run_command "rm -f $LOCKFILE"

msgi "Done."

