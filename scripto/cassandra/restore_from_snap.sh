#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./generate_test_data_bind.sh 1000

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

V_KEYSPACE=$1
V_TABLE=$2
V_SNAP=$3

check_parameter $V_KEYSPACE
check_parameter $V_TABLE
check_parameter $V_SNAP

V_BDIR=$RANDOM

msgd "Find table UUID"
V_TABLEUUID=`find /var/lib/cassandra/data/ -type d | grep $V_KEYSPACE | grep $V_SNAP | awk -F"/" '{print $7}'`
check_parameter $V_TABLEUUID
msgd "V_TABLEUUID: $V_TABLEUUID"


msgd "Create temp dir"
run_command_e "mkdir -p ~/backup/$V_BDIR/$V_KEYSPACE/"
run_command_e "mkdir ~/backup/$V_BDIR/$V_KEYSPACE/$V_TABLEUUID"

msgd "Copy snapshot files to temp dir"
V_SNAPDIR=`find /var/lib/cassandra/data/ -type d | grep $V_KEYSPACE | grep $V_SNAP`
check_directory $V_SNAPDIR
run_command_e "cp $V_SNAPDIR/* ~/backup/$V_BDIR/$V_KEYSPACE/$V_TABLEUUID"

run_command_e "sstableloader -v -d $HOSTNAME ~/backup/$V_BDIR/$V_KEYSPACE/$V_TABLEUUID"

