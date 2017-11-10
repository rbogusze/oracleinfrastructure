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
run_command_e "docker run --name cassandra1 -m 4g -d --rm cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker run --name cassandra2 -m 2g -d --rm -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra1)" cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker exec -i -t cassandra1 sh -c 'nodetool status'"

run_command_e "docker run --name cassandra3 -m 2g -d --rm -e CASSANDRA_SEEDS="$(docker inspect --format='{{ .NetworkSettings.IPAddress }}' cassandra1)" cassandra:$V_CAS_VERSION"
run_command "sleep 60"
run_command_e "docker exec -i -t cassandra1 sh -c 'nodetool status'"

msgi "Installing some packages and scripto"
run_command_e "docker exec -i -t cassandra1 sh -c 'apt-get update'"
run_command_e "docker exec -i -t cassandra1 sh -c 'apt-get --assume-yes install vim subversion less telnet x11-apps openssh-server'"
run_command_e "docker exec -i -t cassandra1 sh -c 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'"
run_command_e "docker exec -i -t cassandra1 sh -c 'echo X11UseLocalhost no >> /etc/ssh/sshd_config'"
run_command_e "docker exec -i -t cassandra1 sh -c 'echo PermitRootLogin yes >> /etc/ssh/sshd_config'"
run_command_e "docker exec -i -t cassandra1 sh -c 'mkdir ~/.ssh'"
run_command_e "docker exec -i -t cassandra1 sh -c 'echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGlfTRL4PHnOEuOUNHamd52lvTwWBMJsOLhA7iaScUMAdlo5Jby8Yha4jZvhFJo/mcfwNNUMI5glZ4vHfZ4DiaqH3T7i1ADiDugC/VmdtHYrJCnF2MwsWXWN8upmAiMT9RcmpAMuam/kvOEZvE7zG4Qn7i7cOnT/ksjTrwvwXqkobJv/AEtsNWo25BaY2GBnkYYXuz6VLozOMWEr7CM8CaPKop7FMbzwznztqYhLYusBqf6eJNxfdxWBkp/oOF/xwTdoIQxPtaNHGrktyMfFmJhHfCFNC29dNEB/sxws6FkHoEye4bHzWUw6L0egVXL/F+KdvCyeaDWjzYzBFIoHL3 remigbog@POLO-1113 >> ~/.ssh/authorized_keys'"
run_command_e "docker exec -i -t cassandra1 sh -c 'echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx4o0qYWZAkJjKGJ+XJ7kdeCF0NlOC8C6+tRsGzFxdbDqYTl0i2hiCmF+QndQXOeouLrSXlbZYzbJ4lvOKt+POHn2SbtzdV79FKE1ZEAHHhlH7eQB/uq5XsoSwE3ZFYkv3GNIczpQBElgSVdId5A4/GCwphk4PPcrt17+PWoMCn4OPbN04HsqwGS+rr5Yj7ye5jiqBsKSceiJZmqiXWQQU4qOnL6/6fRwb9Zs7GxSYSM1HIpPPRn+a1iF+L7jU0m3NIi6kS3KPDOaa4YLIdBSdNtFe9MHtynCsbMa5hBp1NXJmML1RVYCbre1dIG9sXitXcveSll0ZgKusFq5DPAIH root@ubu7 >> ~/.ssh/authorized_keys'"
run_command_e "docker exec -i -t cassandra1 sh -c 'chmod 600 ~/.ssh/authorized_keys'"
run_command_e "docker exec -i -t cassandra1 sh -c '/etc/init.d/ssh start'"
run_command_e "docker exec -i -t cassandra1 sh -c 'cd; svn checkout https://github.com/rbogusze/oracleinfrastructure/trunk/scripto'"
msgi "Installing JDK for jconsole"
run_command_e "docker exec -i -t cassandra1 sh -c 'apt-get --assume-yes install -t jessie-backports  openjdk-8-jre-headless ca-certificates-java openjdk-8-jdk'"

msgi "Running the test"
run_command_e "docker exec -i -t cassandra1 sh -c 'cd ~/scripto; svn update; cd ~/scripto/cassandra/test_cases; ./$V_TEST_TO_RUN'"
msgi "You can connect to JMX with jconsole: localhost:7199"


