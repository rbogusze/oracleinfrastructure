#!/bin/bash

while read line
do

  # Ignore lines with only date status
  TMP_CHK=`echo $line | tr " " "\n" | wc -l`
  #echo "TMP_CHK: $TMP_CHK"
  if [ "$TMP_CHK" -lt 7 ]; then
    continue
  fi


  

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
  DATE=`echo "$line" | awk '{print $2" "$3}'`
#  echo "DATE: $DATE"
  EPOCH=`date --date="$DATE" +%s`
#  echo "EPOCH: $EPOCH"

  # Ignore the lines with just a status
  if [ "$SERVICE" = "status" ]; then
    continue
  fi

  # Ignore the lines with just a ping
  if [ "$SERVICE" = "ping" ]; then
    continue
  fi

  # I want to see just errors
#  if [ "$STATUS" -eq 0 ]; then
#    continue 
#  fi


  # nice, something visible
  #echo "$HOST1 - - [22/Apr/2009:18:52:51 +1200] \"GET $SERVICE HTTP/1.0\" $STATUS 100 \"-\" \"xxx\" " \"-\"

  # ok
  #echo "${HOST1}_${HOST2}_${USER}_${PROGRAM} - - [22/Apr/2009:18:52:51 +1200] \"GET $SERVICE HTTP/1.0\" $STATUS 100 \"-\" \"xxx\" " \"-\"


  # Changing the ball size based on the code - to make the errors visible
  if [ "$STATUS" -ne 0 ]; then
    BALL_SIZE=500000
  else
    BALL_SIZE=1000
  fi

  # custom log format
  FANCY_HOSTNAME=`echo ${HOST1}_${HOST2}_${USER}_${PROGRAM} | tr '.' 'x'`
  echo "$EPOCH|$FANCY_HOSTNAME|$SERVICE|$STATUS|$BALL_SIZE"


done < "${1:-/dev/stdin}"
