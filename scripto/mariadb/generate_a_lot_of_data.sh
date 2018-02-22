#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO
STEP=1   # How much to increase the version retreived
CURRENT=1
while [ 1 ]
do
  CURRENT=`expr ${CURRENT} + ${STEP}`
  msgd "CURRENT: ${CURRENT}"
  msgi "Exit the script if you think it has done enough, it will go on forever."
  #mysql -u remik -premik -h ubu5 -P 4306 remik -e "insert into remik.test values ('ala','ola',${CURRENT});"
  mysql -e "show databases;"
  mysql -e "create database remik${CURRENT};"
  mysql remik${CURRENT} < create_db_table.sql
  mysql remik${CURRENT} < insert_100t.sql
  run_command "du -sh /var/lib/mysql"
#  run_command_e "sleep 1"
done
