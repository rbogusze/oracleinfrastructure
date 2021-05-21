#!/bin/bash

if [ -f ~/.redis_pass ]; then
  REDIS_PASS=`cat ~/.redis_pass`
else
  echo "warning, no password found in ~/.redis_pass"
  REDIS_PASS="aaa"
fi

ARCH=`uname -a | awk '{print $(NF-1)}'`
if [ "$ARCH" = "armv7l" ]; then
  REDISCLI="/home/pi/tmp/redis/redis-3.2.0/src/redis-cli -a ${REDIS_PASS} -p 6379"
else
  REDISCLI="/usr/local/bin/redis-cli -a ${REDIS_PASS} -p 6379"
fi

REDIS_PID=`ps -ef | grep redis | grep -v sentinel | grep -v grep | awk '{print $2}'`
echo "REDIS_PID: $REDIS_PID"

# set sensible slow log tresholds
$REDISCLI CONFIG SET slowlog-log-slower-than 10000


# continuosly write slow commands to log file
while [ 1 ]
do
  LOG=/tmp/redis_slowlog_`date -I`.txt
  date >> $LOG
  top -b -n 2 -d 0.2 -p $REDIS_PID | tail -2 >> $LOG
  free -m >> $LOG
  $REDISCLI info replication >> $LOG
  $REDISCLI slowlog get 50 >> $LOG
  sleep 10
done
