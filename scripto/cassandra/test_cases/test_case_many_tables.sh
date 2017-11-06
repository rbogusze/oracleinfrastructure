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

    for ((i=1;i<=100;i++)); 
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

b_check_gc_activity()
{
  # Info section
  msgb "${FUNCNAME[0]} Beginning."

  # Block actions start here
  msgb "${FUNCNAME[0]} Finished."
} #b_template

#b_create_keyspaces 1 10
b_check_gc_activity "mark0"

