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

V_CAS_VERSION=$1
msgd "V_CAS_VERSION: $V_CAS_VERSION"
check_parameter $V_CAS_VERSION

V_TEST_TO_RUN=$2
msgd "V_TEST_TO_RUN: $V_TEST_TO_RUN"
check_parameter $V_TEST_TO_RUN


echo "I am running on $V_CAS_VERSION"
case $V_CAS_VERSION in
  "3.0.9")
    #List cassandra containers
    A_CASSANDRA=( cassandra41 cassandra42 cassandra43 )
    ;;
  "3.0.14")
    #List cassandra containers
    A_CASSANDRA=( cassandra11 cassandra12 cassandra13 )
    ;;
  *)
    echo "Unknown version!!! Exiting."
    exit 1
    ;;
esac


msgd "List currently running containers"
run_command "docker ps"

msgi "Stop all docker containsers"
run_command "docker stop $(docker ps -a -q)"
run_command "sleep 10"

msgd "List currently running containers"
run_command "docker ps"

msgi "Starting cassandra dockers"
#run_command "docker start cassandra11"
for i in "${A_CASSANDRA[@]}"
do
  msgi "Starting $i"
  run_command_e "docker start $i"
  run_command "sleep 10"
  run_command_e "docker exec -i -t $i sh -c 'nodetool status'"
done


msgi "Running the test"
run_command_e "docker exec -i -t ${A_CASSANDRA[0]} sh -c 'cd ~/scripto; svn update; cd ~/scripto/cassandra/test_cases; ./$V_TEST_TO_RUN'"




