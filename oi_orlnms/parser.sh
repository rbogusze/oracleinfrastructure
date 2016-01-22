#!/bin/bash

while read line
do


  V_HOSTNAME=""
  V_IP=""

  # Ignore lines with only date status
  TMP_CHK=`echo $line | tr " " "\n" | wc -l`
  #echo "TMP_CHK: $TMP_CHK"
  if [ "$TMP_CHK" -lt 7 ]; then
    continue
  fi
  
  #echo "####################################"
  #echo "$line"

  # Let only lines with status = establish (not 100% sure if that is the right approach)
  TMP_CHK=`echo $line | grep establish | wc -l`
  #echo "TMP_CHK: $TMP_CHK"
  if [ "$TMP_CHK" -eq 0 ]; then
    continue
  fi

  LOG_NAME=`echo "$line" | awk '{print $1}'`
#  echo "LOG_NAME: $LOG_NAME"
  HOST1=`echo "$line" | awk -F"HOST=" '{print $2}' | awk -F')' '{print $1}' | tr -d "_" | awk -F"." '{print $1}'`
#  echo "HOST1: $HOST1"
  HOST2=`echo "$line" | awk -F"HOST=" '{print $3}' | awk -F')' '{print $1}'`
#  echo "HOST2: $HOST2"
  HOST3=`echo "$line" | awk -F"HOST=" '{print $4}' | awk -F')' '{print $1}'`
#  echo "HOST3: $HOST3"
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

  # Ignore the lines with just a status
  if [ "$SERVICE" = "status" ]; then
    continue
  fi

  # Ignore the lines with just a ping
  if [ "$SERVICE" = "ping" ]; then
    continue
  fi



  EPOCH=`date --date="$DATE" +%s`
#  echo "EPOCH: $EPOCH"

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

  # Deciding on the source host that will be displayed. We have three HOST variables that
  # can contain different values - hostname / ip / string
  #echo "HOST1: ${HOST1}"
  #echo "HOST2: ${HOST2}"
  #echo "HOST3: ${HOST3}"

  #if the value has '-' it is probably hostname
  TMP_CHK=`echo ${HOST1} | grep '-' | wc -l`
  #echo "TMP_CHK: $TMP_CHK"
  if [ "$TMP_CHK" -gt 0 ]; then
    #echo "HOST1 contains hostname" 
    V_HOSTNAME=$HOST1
  fi 

  if [[ $HOST2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    #echo "HOST2 contains IP address"
    V_IP=$HOST2
  fi

  if [[ $HOST3 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    #echo "HOST3 contains IP address"
    V_IP=$HOST3
  fi


  #echo "V_HOSTNAME: $V_HOSTNAME" 
  #echo "V_IP: $V_IP" 

  # If we have V_IP let's resolve the IP to name
  if [ ! -z "$V_IP" ]; then
    #echo "Check if I have resolved it already"
    TMP_CHK=`cat /tmp/resolve.txt | grep "$V_IP" | wc -l`
    #echo "TMP_CHK: $TMP_CHK"
    if [ "$TMP_CHK" -lt 1 ]; then
      #echo "Hostname was not resolved from DNS before, doing it" 
      getent hosts $V_IP >> /tmp/resolve.txt
    fi
    V_HOSTNAME_FROM_IP=`cat /tmp/resolve.txt | grep "$V_IP" | awk '{print $2}' | awk -F"." '{print $1}'`
    #echo "V_HOSTNAME_FROM_IP: $V_HOSTNAME_FROM_IP"
 
  fi 

  
  if [ ! -z "$V_HOSTNAME" ] && [ ! -z "$V_HOSTNAME_FROM_IP" ]; then
    #echo "SUPERHOST set by comparing V_HOSTNAME and V_HOSTNAME_FROM_IP"
    if [ "$V_HOSTNAME" = "$V_HOSTNAME_FROM_IP" ]; then
      #echo "Comparison if fine"
      SUPERHOST=$V_HOSTNAME
    else
      #echo "Comparison is BAD"
      #echo "$line"
      #echo "V_HOSTNAME_FROM_IP: $V_HOSTNAME_FROM_IP"
      #echo "V_HOSTNAME: $V_HOSTNAME" 
      SUPERHOST=${V_HOSTNAME}_HOST_IP_MISMATCH
      #echo "SUPERHOST: ${SUPERHOST}"
      #exit 0
    fi
  elif [ ! -z "$V_HOSTNAME" ]; then
    #echo "SUPERHOST set from V_HOSTNAME"
    SUPERHOST=$V_HOSTNAME
  elif [ ! -z "$V_HOSTNAME_FROM_IP" ]; then
    #echo "SUPERHOST set from IP"
    SUPERHOST=$V_HOSTNAME_FROM_IP
  else
    #echo "Failed to get hostname"
    SUPERHOST="NO_SOURCE_FOUND"
  fi

  #echo "SUPERHOST: ${SUPERHOST}"


  # custom log format
  #FANCY_HOSTNAME=`echo ${SUPERHOST}_${USER}_${PROGRAM} | tr '.' 'x'`
  FANCY_HOSTNAME=`echo ${SUPERHOST}_${USER}_${PROGRAM} | tr '.' 'x' | sed 's/__*/_/g' | sed 's/_$//'`
  echo "$EPOCH|$FANCY_HOSTNAME|$SERVICE|$STATUS|$BALL_SIZE"


done < "${1:-/dev/stdin}"
