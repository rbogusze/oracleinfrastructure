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

cd $COMMON_TOP/admin/scripts/$CONTEXT_NAME
./adstrtal.sh apps/apps
