#!/bin/bash
# 

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock_sql
CONFIG_FILE=$TMP_LOG_DIR/ldap_out_sql.txt
D_CVS_REPO=$HOME/conf_repo

INFO_MODE=DEBUG


# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


mkdir -p $TMP_LOG_DIR
check_directory "$TMP_LOG_DIR"
check_directory $D_CVS_REPO

# Sanity check
check_lock $LOCKFILE

# check for TMP_LOG_DIR
msgd "Ask the ldap for all the hosts to chec. We check there where init files are monitored"

$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitFile=*)" "['orainfOsLogwatchUser', 'orclSystemName', 'cn', 'orainfOsLogwatchUserAuth', 'orainfDbInitFile']" | awk '{print $1" "$2" ["$3"_"$2"] "$4" "$5}' > $CONFIG_FILE

check_file $CONFIG_FILE

run_command_d "cat $CONFIG_FILE"


# Set lock file
#touch $LOCKFILE


# On exit remove lock file
rm -f $LOCKFILE
