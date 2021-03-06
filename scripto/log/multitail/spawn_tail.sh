#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

LOCKFILE_SPAN_DIR=/tmp/remote_log_spanned
LOCKFILE_SPAN=gather_span

F_FETCH_THAT=$1
check_file $F_FETCH_THAT
msgd "F_FETCH_THAT: $F_FETCH_THAT"

run_command_e "mkdir -p /tmp/remote_log_raw /tmp/remote_log_prefix $LOCKFILE_SPAN_DIR"
run_command_e "rm -f /tmp/remote_log_raw/* /tmp/remote_log_prefix/*"

msgd "Filter out comments"
F_FETCH_THAT_NO_COMMENT=/tmp/remote_log_raw.input
run_command_e "cat $F_FETCH_THAT | grep -v '^#' > $F_FETCH_THAT_NO_COMMENT"
run_command_d "cat $F_FETCH_THAT_NO_COMMENT"


exec 3<> $F_FETCH_THAT_NO_COMMENT
while read LINE <&3
do {
  echo $LINE

  

  V_USERNAME=`echo $LINE | awk '{print $1}'`
  msgd "V_USERNAME: $V_USERNAME"
  check_parameter $V_USERNAME
  V_HOSTNAME=`echo $LINE | awk '{print $2}'`
  msgd "V_HOSTNAME: $V_HOSTNAME"
  check_parameter $V_HOSTNAME
  V_LOGFILE=`echo $LINE | awk '{print $3}'`
  msgd "V_LOGFILE: $V_LOGFILE"
  check_parameter $V_LOGFILE

  V_LOGNAME=`basename $V_LOGFILE `
  msgd "V_LOGNAME: $V_LOGNAME"
  check_parameter $V_LOGNAME

  msgd "Prefix"
  #V_PREFIX=$V_HOSTNAME
  V_PREFIX=`echo $LINE | awk '{print $4}'`
  msgd "V_PREFIX: $V_PREFIX"
  check_parameter $V_PREFIX

  msgd "Spanning tail through ssh"
  ssh -o BatchMode=yes ${V_USERNAME}@${V_HOSTNAME} "tail -f $V_LOGFILE " > /tmp/remote_log_raw/${V_PREFIX}_${V_LOGNAME} &
  PID=$!
  msgd "PID: $PID"
  touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
  sleep 1

  msgd "Spanning prefix addon"
  tail -f /tmp/remote_log_raw/${V_PREFIX}_${V_LOGNAME} | awk -v var="${V_PREFIX}" '$0=var" "$0; system("")' > /tmp/remote_log_prefix/${V_PREFIX}_${V_LOGNAME} &
  #PID=$!
  #msgd "PID: $PID"
  #touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
  sleep 1


#exit 0
   }
done
exec 3>&-

