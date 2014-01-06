#!/bin/bash
echo "[info] Start APPS tier only if DB is reachable"
echo "[info] Trying to connect to the database"
. /home/oracle/scripto/ebs/app_env

echo "select * from dual;" | sqlplus -s apps/apps > /tmp/start_APP.tmp
TPM_CHK=`cat /tmp/start_APP.tmp | wc -l`
echo "TPM_CHK: $TPM_CHK"

if [ $TPM_CHK -gt 5 ]; then
  echo " >>> Failed to reach DB"
else
  echo "Reached DB. OK. Continuing with APPS startup."
fi

# 11.5 cd $COMMON_TOP/admin/scripts/$CONTEXT_NAME
# 12.1
cd $INST_TOP/admin/scripts
./adstrtal.sh apps/apps
