#!/bin/bash
set -x
. /home/oracle/scripto/ebs/app_env

cd $COMMON_TOP/admin/scripts/$CONTEXT_NAME
./adstpall.sh apps/apps

