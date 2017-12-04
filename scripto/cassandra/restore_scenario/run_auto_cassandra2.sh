#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# That script is to be used ONLY on test env
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
INFO_MODE=INFO

V_SLEEP=60

run_command_e "cd ~/scripto/docker/test_poc/dockerfile_A"
run_command_e "docker-compose -f docker_compose.yml down"
run_command_e "cd /var/lib/container_data/cassandra"
run_command_e "./clear_node_A.sh"
run_command_e "cd ~/scripto/docker/test_poc/dockerfile_A"
run_command_e "docker-compose -f docker_compose.yml up -d"
run_command_e "sleep $V_SLEEP"
run_command_e "docker-compose -f docker_compose.yml up -d"
run_command_e "sleep $V_SLEEP"
run_command_e "docker exec cassandra_node_A1 nodetool status"
run_command_e "cd /root/scripto/cassandra/restore_scenario"
run_command_e "./restore_scenario.sh --docker_list cassandra_node_A1,cassandra_node_A2,cassandra_node_A3 --cqlshrc /root/.cassandra/cqlshrcnode_A1 --create_phase_file 01_create_simple_mv.cql --destroy_phase_file 01_destroy_simple.cql"
