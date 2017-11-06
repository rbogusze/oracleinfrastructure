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

  STEP=1
  while [ ${CURRENT} -ne ${END} ]
  do
    echo "CREATE KEYSPACE remik${CURRENT} WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};" | tee /dev/tty | cqlsh 
    echo "use remik${CURRENT}; CREATE TABLE table1 ( id int PRIMARY KEY, name text, temperature double);" | tee /dev/tty | cqlsh 
    CURRENT=`expr ${CURRENT} + ${STEP}`
    echo ${CURRENT}
  done

  

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

b_create_keyspaces 1 10


exit 0

echo "drop keyspace remik5;" | tee /dev/tty | cqlsh  
echo "CREATE KEYSPACE remik5 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};" | tee /dev/tty | cqlsh 
echo "use remik5; CREATE TABLE table1 ( id int PRIMARY KEY, name text, temperature double);" | tee /dev/tty | cqlsh 
echo "desc keyspace remik5;" | tee /dev/tty | cqlsh  
run_command_e "cd ~/scripto/cassandra/test_data"
echo "use remik5; source 'populate_1t.sql';" | tee /dev/tty | cqlsh  
echo "use remik5; alter table table1 drop name;" | tee /dev/tty | cqlsh  
echo "use remik5; INSERT INTO table1 (id, temperature) values (234234236, 322);" | tee /dev/tty | cqlsh  
echo "use remik5; select count(*) from remik5.table1;" | tee /dev/tty | cqlsh  
run_command_e "nodetool snapshot remik5 > /tmp/remik5.snap"
cat /tmp/remik5.snap
V_SNAP=`cat /tmp/remik5.snap | grep "Snapshot directory" | awk '{print $3}'`
msgd "V_SNAP: $V_SNAP"

echo "drop keyspace remik5;" | tee /dev/tty | cqlsh  
echo "CREATE KEYSPACE remik5 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'};" | tee /dev/tty | cqlsh 
echo "use remik5; CREATE TABLE table1 ( id int PRIMARY KEY, name text, temperature double);" | tee /dev/tty | cqlsh 
echo "use remik5; ALTER TABLE remik5.table1 DROP name USING TIMESTAMP 1507300907611000;" | tee /dev/tty | cqlsh 


