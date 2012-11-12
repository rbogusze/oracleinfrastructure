#!/bin/bash

ORACLE_SID=$1

if [ -z "$1" ]; then
  echo "Provided variable ${1} is empty. Exiting. "
  exit 1
fi

export ORACLE_SID

ORAENV_ASK=NO
. oraenv
ORAENV_ASK=YES

# Start Listener
lsnrctl start

# Start Database
sqlplus / as sysdba << EOF
STARTUP;
show parameter instance_name
EXIT;
EOF
