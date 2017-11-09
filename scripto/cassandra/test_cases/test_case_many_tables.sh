#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./generate_test_data_bind.sh 1000

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

V_TABLES_PER_KEYSPACE=100


# That creates keyspace with index $1 and up to $2, each keyspace with 100 tables
b_create_keyspaces()
{
  # Info section
  msgb "${FUNCNAME[0]} Beginning."
  CURRENT=$1
  END=$2
  check_parameter $CURRENT
  msgd "CURRENT: $CURRENT"
  check_parameter $END
  msgd "END: $END"

  echo "select count(*) from system_schema.tables;" | tee /dev/tty | cqlsh 

  STEP=1
  while [ ${CURRENT} -ne ${END} ]
  do
    echo "CREATE KEYSPACE remik${CURRENT} WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};" | tee /dev/tty | cqlsh 

    for ((i=1;i<=${V_TABLES_PER_KEYSPACE};i++)); 
    do 
      echo $i
      echo "use remik${CURRENT}; CREATE TABLE table$i ( id int PRIMARY KEY, name text, temperature double);" | tee /dev/tty | cqlsh 
    done


    CURRENT=`expr ${CURRENT} + ${STEP}`
    echo ${CURRENT}
  done

  echo "select count(*) from system_schema.tables;" | tee /dev/tty | cqlsh 
  

  # Block actions start here
  msgb "${FUNCNAME[0]} Finished."
} #b_create_keyspaces

# Count the number of GC runs after the provided mark as $1
b_check_gc_activity()
{
  # Info section
  msgb "${FUNCNAME[0]} Beginning."

  V_INFO=$1
  check_parameter $V_INFO
  msgd "V_INFO: $V_INFO"

  V_COUNT_OLD=$V_COUNT
  msgd "V_COUNT_OLD: $V_COUNT_OLD"

  V_COUNT=`cat /var/log/cassandra/gc.log.0.current | grep 'Heap before GC invocations' | wc -l`
  msgd "V_COUNT: $V_COUNT"

  #compute delta if previous record exists
  if [ $V_COUNT_OLD ]; then
    V_DELTA=`expr ${V_COUNT} - ${V_COUNT_OLD}`
    msgd "V_DELTA: $V_DELTA"
  fi

  V_TABLES=`echo "select count(*) from system_schema.tables;" | cqlsh | grep -v -e "count" -e "Warnings" -e "Aggregation" -e "rows" -e "---" | grep -v '^ *$' | awk '{print $1}' `
 # echo "| $V_MARK | ${V_COUNT} | " >> /tmp/test_case.log
  printf "%-56s %-16s %-9s %-9s %s\n" "| $V_INFO" "| $V_TABLES" "| ${V_COUNT}" "| $V_DELTA" "|" >> /tmp/test_case.log

  # Block actions start here
  msgb "${FUNCNAME[0]} Finished."
} #b_template

# Actual execution
#echo "| Event | GC runs | " >> /tmp/test_case.log
printf "%-56s %-16s %-9s %-9s %s\n" "| Info" "| Tables count " "| GC runs" "| GC Delta" "|" > /tmp/test_case.log

msgd "Create mark in gc.log.0.current, run the test and then print how many GC runs were seen aftet the mark"


V_IDLE_TIME=600
b_check_gc_activity "Opening stats"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

b_create_keyspaces 1 2
b_check_gc_activity "Created 1 keyspace * $V_TABLES_PER_KEYSPACE tables"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

b_create_keyspaces 2 10
b_check_gc_activity "Created another 10 keyspaces * $V_TABLES_PER_KEYSPACE tables"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

b_create_keyspaces 10 20
b_check_gc_activity "Created another 10 keyspaces * $V_TABLES_PER_KEYSPACE tables"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

b_create_keyspaces 20 30
b_check_gc_activity "Created another 10 keyspaces * $V_TABLES_PER_KEYSPACE tables"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

b_create_keyspaces 30 40
b_check_gc_activity "Created another 10 keyspaces * $V_TABLES_PER_KEYSPACE tables"
run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

run_command "sleep $V_IDLE_TIME"
b_check_gc_activity "Idle time for $V_IDLE_TIME sec"

cat /tmp/test_case.log
