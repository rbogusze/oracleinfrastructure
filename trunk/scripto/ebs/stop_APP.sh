#!/bin/bash
set -x
. /home/oracle/scripto/ebs/app_env

# 11.5 cd $COMMON_TOP/admin/scripts/$CONTEXT_NAME
# 12.1
#cd $INST_TOP/admin/scripts
#./adstpall.sh apps/apps
# 12.2
cd $ADMIN_SCRIPTS_HOME
./adstpall.sh apps/apps
