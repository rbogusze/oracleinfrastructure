#!/bin/bash
#set -x
. $HOME/db_env

cd $ORACLE_HOME/appsutil/scripts/$CONTEXT_NAME
./addbctl.sh stop
./addlnctl.sh stop $ORACLE_SID
