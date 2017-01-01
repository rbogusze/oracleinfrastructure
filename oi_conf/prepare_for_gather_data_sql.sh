#!/bin/bash
# 

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock_prepare_for_gather_data_sql
CONFIG_FILE=$TMP_LOG_DIR/ldap_out_sql.txt

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

# Sanity check
check_lock $LOCKFILE

# Actual execution
msgd "Ask the ldap for all the hosts to chec. We check there where init files are monitored"

$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitFile=*)" "['cn', 'orainfDbReadOnlyUser', 'orainfDbReadOnlyIndexHash']" > $CONFIG_FILE

check_file $CONFIG_FILE
run_command_d "cat $CONFIG_FILE"

# On exit remove lock file
rm -f $LOCKFILE
