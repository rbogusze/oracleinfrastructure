#!/bin/bash
# 
# Store the output of the execution in a CVS repository

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock_sql
CONFIG_FILE=$TMP_LOG_DIR/ldap_out_sql.txt
D_CVS_REPO=$HOME/conf_repo

#INFO_MODE=DEBUG

# Load useeull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


mkdir -p $TMP_LOG_DIR
check_directory "$TMP_LOG_DIR"
check_directory $D_CVS_REPO

cd $D_CVS_REPO
find /home/remik/_poufne > home_remik__poufne.txt
cvs add home_remik__poufne.txt
cvs commit -m "Auto commit on `date -I`"

find /KASZTELAN > KASZTELAN.txt
cvs add KASZTELAN.txt
cvs commit -m "Auto commit on `date -I`"





