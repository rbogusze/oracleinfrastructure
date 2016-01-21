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
  #echo "${HOST1}_${HOST2}_${USER}_${PROGRAM} - - [22/Apr/2009:18:52:51 +1200] \"GET $SERVICE HTTP/1.0\" $STATUS 100 \"-\" \"xxx\" " \"-\"

  # custom log format
  #echo "1371769989|${HOST1}_${HOST2}_${USER}_${PROGRAM}|$SERVICE|$STATUS|100"
  #echo "1371769989|1234567890123456789012345678901234567890|$SERVICE|$STATUS|100"
  FANCY_HOSTNAME=`echo ${HOST1}${HOST2}${USER}${PROGRAM} | tr -cd '[[:alnum:]]'`
  FANCY_HOSTNAME=`echo ${HOST1}${HOST2}${USER}${PROGRAM} | tr '.' 'x'`
  FANCY_HOSTNAME=`echo ${HOST1}_${HOST2}_${USER}_${PROGRAM} | tr '.' 'x'`
  #echo "1371769989|$FANCY_HOSTNAME|$SERVICE|$STATUS|100"
  # this is nice
  #echo "1371769989|$FANCY_HOSTNAME|$SERVICE|$STATUS|10000"

  # Changing the ball size based on the code - to make the errors visible
  if [ "$STATUS" -ne 0 ]; then
    BALL_SIZE=500000
  else
    BALL_SIZE=1000
  fi
    echo "1371769989|$FANCY_HOSTNAME|$SERVICE|$STATUS|$BALL_SIZE"


done < "${1:-/dev/stdin}"
