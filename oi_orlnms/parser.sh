#!/bin/bash

while read line
do

#  echo "$line"
  LOG_NAME=`echo "$line" | awk '{print $1}'`
#  echo "LOG_NAME: $LOG_NAME"
  HOST1=`echo "$line" | awk -F"HOST=" '{print $2}' | awk -F')' '{print $1}' | tr -d "_"`
#  echo "HOST1: $HOST1"
  HOST2=`echo "$line" | awk -F"HOST=" '{print $3}' | awk -F')' '{print $1}'`
#  echo "HOST2: $HOST2"
  PROGRAM=`echo "$line" | awk -F"PROGRAM=" '{print $2}' | awk -F')' '{print $1}' | tr -d " " `
#  echo "PROGRAM: $PROGRAM"
  USER=`echo "$line" | awk -F"USER=" '{print $2}' | awk -F')' '{print $1}'`
#  echo "USER: $USER"
  SERVICE=`echo "$line" | awk '{print $(NF-2)}'`
#  echo "SERVICE: $SERVICE"
  STATUS=`echo "$line" | awk '{print $NF}' | tr -cd '[[:alnum:]]._-'`
#  echo "STATUS: $STATUS"

  # nice, something visible
  #echo "$HOST1 - - [22/Apr/2009:18:52:51 +1200] \"GET $SERVICE HTTP/1.0\" $STATUS 100 \"-\" \"xxx\" " \"-\"

  # ok
  echo "${HOST1}_${HOST2}_${USER}_${PROGRAM} - - [22/Apr/2009:18:52:51 +1200] \"GET $SERVICE HTTP/1.0\" $STATUS 100 \"-\" \"xxx\" " \"-\"

done < "${1:-/dev/stdin}"
