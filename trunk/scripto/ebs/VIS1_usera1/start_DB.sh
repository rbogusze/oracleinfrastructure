#!/bin/bash
#set -x
. $HOME/scripto/ebs/VIS2_usera2/db_env

cd $ORACLE_HOME/appsutil/scripts/$CONTEXT_NAME
./addbctl.sh start
./addlnctl.sh start VIS
