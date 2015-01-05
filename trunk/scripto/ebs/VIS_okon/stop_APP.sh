#!/bin/bash
# 11.5 cd $COMMON_TOP/admin/scripts/$CONTEXT_NAME
# 12.1
#cd $INST_TOP/admin/scripts
#./adstpall.sh apps/apps
# 12.2
cd $ADMIN_SCRIPTS_HOME

export APPSUSER=apps
export APPSPASS=apps
export WLSADMIN=welcome1

{ echo $APPSUSER ; echo $APPSPASS ; echo $WLSADMIN ; }| adstpall.sh @ -nopromptmsg

