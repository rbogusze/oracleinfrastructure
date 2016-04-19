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

F_INPUT=$1

TMP_OUT=/tmp/change_script_to_px.tmp

check_parameter $F_INPUT
check_file $F_INPUT

V_SECTION=0

while read LINE
do

  msgd "V_SECTION: $V_SECTION"
  TMP_CHK=`echo $LINE | grep -i select | wc -l`
  if [ "$TMP_CHK" -eq 1 ]; then
    msgd "In select statement"
    V_SECTION=1
    msgd "V_SECTION: $V_SECTION"
  fi


  # look for end of statement
  if [ "$V_SECTION" -eq 1 ]; then
    TMP_CHK=`echo $LINE | grep ';' | wc -l`
    if [ "$TMP_CHK" -eq 1 ]; then
      msgd "End of select statement"
      V_SECTION=0
      msgd "V_SECTION: $V_SECTION"
      echo $LINE >> $TMP_OUT
      continue
    fi
  fi


  # output only out of section lines
  if [ "$V_SECTION" -eq 0 ]; then
    echo $LINE
  else
    echo $LINE >> $TMP_OUT
  fi



done < $F_INPUT
