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

run_command_e "cd ~/scripto/cassandra"
run_command "./restore_from_snap.sh remik5 table1 $V_SNAP"




