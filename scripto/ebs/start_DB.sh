#!/bin/bash
set -x
. /home/oracle/scripto/ebs/db_env

cd $ORACLE_HOME/appsutil/scripts/$CONTEXT_NAME
./addbctl.sh start
./addlnctl.sh start $ORACLE_SID
