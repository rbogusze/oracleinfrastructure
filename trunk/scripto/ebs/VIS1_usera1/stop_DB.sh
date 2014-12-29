#!/bin/bash
#set -x
. $HOME/scripto/ebs/VIS1_usera1/db_env

cd $ORACLE_HOME/appsutil/scripts/$CONTEXT_NAME
./addbctl.sh stop
./addlnctl.sh stop VIS
