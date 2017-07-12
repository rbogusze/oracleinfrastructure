#!/bin/bash

STEP=1   # How much to increase the version retreived
CURRENT=1000000
END=100000000



while [ ${CURRENT} -ne ${END} ]
do
  CURRENT=`expr ${CURRENT} + ${STEP}`
  V_DATE=`date '+%Y-%m-%d--%H:%M:%S'`
  echo ${CURRENT}
  echo "Executing on ubu1"
  echo "INSERT INTO remik1.table1 (id, name, temperature) values (${CURRENT}, 'manual_ubu1_${V_DATE}', 10);" | cqlsh ubu1
  echo "select * from remik1.table1 where id = ${CURRENT};" | cqlsh ubu1

  echo "Executing on ubu2"
  echo "INSERT INTO remik1.table1 (id, name, temperature) values (${CURRENT}, 'manual_ubu2_${V_DATE}', 10);" | cqlsh ubu2
  echo "select * from remik1.table1 where id = ${CURRENT};" | cqlsh ubu2

  echo "Executing on ubu3"
  echo "INSERT INTO remik1.table1 (id, name, temperature) values (${CURRENT}, 'manual_ubu3_${V_DATE}', 10);" | cqlsh ubu3
  echo "select * from remik1.table1 where id = ${CURRENT};" | cqlsh ubu3

  echo "sleep 5"
  sleep 5
done



