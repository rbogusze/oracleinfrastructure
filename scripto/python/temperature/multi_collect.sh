#!/bin/bash

PID=$$
START_TIME=`date +%s`

LOG_DIR=/tmp/multi_log_${PID}
mkdir -p $LOG_DIR

echo "Determining number of collect scripts to run"

V_EXECUTE=`cat /proc/cpuinfo | grep ^processor | wc -l`
V_EXECUTE=16

# multiply by 2, so that each CPU thread has 2 collect scripts running
V_EXECUTE=`expr $V_EXECUTE + $V_EXECUTE`

V_EXECUTE_COUNT=0
while [ ${V_EXECUTE_COUNT} -lt ${V_EXECUTE} ]
do
  echo "running $V_EXECUTE_COUNT" 
  python collect.py $1 $2 $3 $4 $5 $6 $7 $8 $9 2>&1 | tee $LOG_DIR/run_$V_EXECUTE_COUNT & 
  V_EXECUTE_COUNT=`expr $V_EXECUTE_COUNT + 1`
done

wait $(jobs -p)

echo "[info] Executed: $V_EXECUTE threads. To get a number of TPS this client generated multiply average TPS by this number."

TOTAL_TRANS=0
for i in $LOG_DIR/*
do
  #echo $i 
  TRANS=`cat $i | grep "INFO - TPS" | tail -1 | awk '{print $NF}'`
  #echo "TRANS: $TRANS"
  TOTAL_TRANS=`expr $TOTAL_TRANS + $TRANS`
  #echo "TOTAL_TRANS: $TOTAL_TRANS"
done

echo "TOTAL_TRANS: $TOTAL_TRANS"
END_TIME=`date +%s`
ELAPSED=`expr $END_TIME - $START_TIME`
echo "This took: $ELAPSED seconds"
