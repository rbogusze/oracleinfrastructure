#!/bin/bash

# Make every select * from dual; select /*+ FULL(a)3 parallel(a,8) */ * from dual a;

# Load usefull functions
if [ ! -f ${HOME}/scripto/bash/bash_library.sh ]; then
  echo "[error] ${HOME}/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${HOME}/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
STEP=1
CURRENT=0
EVERY=4

F_INPUT=$1
check_file $F_INPUT

while read LINE
do
  echo $LINE
  CURRENT=`expr ${CURRENT} + ${STEP}`
  #echo ${CURRENT} 
  if [ ${CURRENT} -ge $EVERY ]; then
    echo "commit;"
    CURRENT=0
  fi

done < $F_INPUT
