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

V_IP=`cat /etc/hosts | grep $HOSTNAME | awk '{print $1}'`
msgd "V_IP: $V_IP"
check_parameter $V_IP

check_file /etc/cassandra/cassandra-env.sh
cat >> /etc/cassandra/cassandra-env.sh << EOF
JVM_OPTS="\$JVM_OPTS -Djava.rmi.server.hostname=$V_IP"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.port=\$JMX_PORT"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.rmi.port=\$JMX_PORT"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
EOF
