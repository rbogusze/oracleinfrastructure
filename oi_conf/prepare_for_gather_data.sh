#!/bin/bash
# 
# If orainfDbInitFile= is set, then the instance is taken under consideration. If you want to disable it
# just remove that attribute from the entity

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock_prepare_hosts_list
CONFIG_FILE=$TMP_LOG_DIR/ldap_out.txt

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
# Set lock file
touch $LOCKFILE

# check for TMP_LOG_DIR
msgd "Ask the ldap for all the hosts to chec. We check there where alert logs are monitored"

$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitFile=*)" "['orainfOsLogwatchUser', 'orclSystemName', 'cn', 'orainfOsLogwatchUserAuth', 'orainfDbInitFile', 'orclSid']" | awk '{print $1" "$2" ["$3"_"$2"] "$4" "$5" "$6}' > $CONFIG_FILE

check_file $CONFIG_FILE

run_command_d "cat $CONFIG_FILE"

# On exit remove lock file
rm -f $LOCKFILE
