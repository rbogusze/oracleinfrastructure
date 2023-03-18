#!/bin/bash

# procedures
run_tcpdump()
{
  echo "Running tcpdump"
  DATETIME=`date '+%Y%m%d-%H%M%S'`
  echo "DATETIME: $DATETIME"
  tcpdump -G 15 -W 1 -w myfile_${DATETIME}
}


# main endless loop
while [ 1 ]
do

  date '+%Y%m%d %H:%M:%S'
  echo "Executing '/etc/kafka/check-cluster-stability.sh check' to check for URPs"
  if /etc/kafka/check-cluster-stability.sh check; then
    echo "/etc/kafka/check-cluster-stability.sh check returned 0, everything is fine. Doing nothing."
  else
    echo "/etc/kafka/check-cluster-stability.sh check returned 1, there are URPs. Running tcpdump."

    # checking if there is enough free space
    reqSpace=1000000  # free 1G
    availSpace=$(df "." | awk 'NR==2 { print $4 }')
    echo "availSpace: $availSpace"
    if (( availSpace < reqSpace )); then
      echo "not enough Space"
    else
      run_tcpdump
    fi 

  fi


  echo "Sleeping 60 seconds"
  sleep 60
done
