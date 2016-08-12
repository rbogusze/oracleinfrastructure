#!/bin/bash
# Info: Check if system is paging
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO


msgi "Check if patch 19877440 is installed in new database."
check_directory $ORACLE_HOME
export ORACLE_HOME="`dirname $ORACLE_HOME`/11204"
msgd "ORACLE_HOME: $ORACLE_HOME"
echo "$ORACLE_HOME/OPatch/opatch lsinventory | grep 19877440"
TMP_CHK=`$ORACLE_HOME/OPatch/opatch lsinventory | grep 19877440 | wc -l`
msgd "TMP_CHK: $TMP_CHK"
if [ $TMP_CHK -gt 0 ]; then
  msge "Patch 19877440 exists!!! Deinstall first"
else
  msgi "Patch 19877440 does not exists"
fi
