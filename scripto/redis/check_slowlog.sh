#!/bin/bash

LOG=/tmp/redis_slowlog_`date -I`.txt
REDISCLI="/usr/local/bin/redis-cli -a hard_pass -p 6379"

REDIS_PID=`ps -ef | grep redis | grep -v sentinel | grep -v grep | awk '{print $2}'`
echo "REDIS_PID: $REDIS_PID"

# set sensible slow log tresholds
$REDISCLI CONFIG SET slowlog-log-slower-than 10000


# continuosly write slow commands to log file
while [ 1 ]
do
    date >> $LOG
    top -b -n 2 -d 0.2 -p $REDIS_PID | tail -2 >> $LOG
    free -m >> $LOG
    $REDISCLI info replication >> $LOG
    $REDISCLI slowlog get 50 >> $LOG
    sleep 10
done
