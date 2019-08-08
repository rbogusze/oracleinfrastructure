#!/bin/bash

echo "Determining number of collect scripts to run"

V_EXECUTE=`cat /proc/cpuinfo | grep ^processor | wc -l`

# multiply by 2, so that each CPU thread has 2 collect scripts running
V_EXECUTE=`expr $V_EXECUTE + $V_EXECUTE`

V_EXECUTE_COUNT=0
while [ ${V_EXECUTE_COUNT} -lt ${V_EXECUTE} ]
do
  echo "running $V_EXECUTE_COUNT" 
  python collect.py &
  V_EXECUTE_COUNT=`expr $V_EXECUTE_COUNT + 1`
done

wait $(jobs -p)
