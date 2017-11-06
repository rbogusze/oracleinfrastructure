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

msgd "List currently running containers"
run_command "docker ps"

msgi "Stop all docker containsers"
run_command "docker stop $(docker ps -a -q)"
run_command "sleep 10"

msgd "List currently running containers"
run_command "docker ps"


msgi "Create cassandra $V_CAS_VERSION cluster"
#run_command_e "docker run --name cassandra1 -m 2g -d cassandra:$V_CAS_VERSION"
run_command_e "docker run --name cassandra1 -m 2g -d --rm cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker run --name cassandra2 -m 2g -d --rm -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra1)" cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker exec -i -t cassandra1 sh -c 'nodetool status'"

run_command_e "docker run --name cassandra3 -m 2g -d --rm -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra1)" cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker exec -i -t cassandra1 sh -c 'nodetool status'"

msgi "Installing some packages and scripto"
run_command_e "docker exec -i -t cassandra1 sh -c 'apt-get update'"
run_command_e "docker exec -i -t cassandra1 sh -c 'apt-get --assume-yes install vim subversion less'"
run_command_e "docker exec -i -t cassandra1 sh -c 'cd; svn checkout https://github.com/rbogusze/oracleinfrastructure/trunk/scripto'"

msgi "Running the test"
run_command_e "docker exec -i -t cassandra1 sh -c 'cd ~/scripto; svn update; cd ~/scripto/cassandra/test_cases; ./$V_TEST_TO_RUN'"


