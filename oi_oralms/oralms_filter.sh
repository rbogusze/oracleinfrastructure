#!/bin/bash
# $Header: /home/remik/cvs_root_kgp/oralms/oralms_filter.sh,v 1.1 2012-05-25 11:22:11 orainf Exp $

#set -x

LOCKFILE_ORALMS=/tmp/oralms_filter.lock
LOCKFILE_SPAN_DIR=/tmp/oralms_filter_span
LOCKFILE_SPAN=${LOCKFILE_SPAN_DIR}/oralms_filter_span
GREP=/bin/grep
ECHO=/bin/echo
SSH=/usr/bin/ssh
GLOBAL_ALERT_RAW=/tmp/global_alert_raw.log
GLOBAL_ALERT=/tmp/global_alert.log
TMP_LOG_DIR=/var/log/oralms
REDO_LOGS_DIR=./redo_logs

mkdir -p ${LOCKFILE_SPAN_DIR}
check_directory ${LOCKFILE_SPAN_DIR}

# create redo logs directory, for how many times each maschine has switched
mkdir -p ${REDO_LOGS_DIR}

# now as parameter
#LOGSURFER_CONFIG_FILE=./logsurfer_global_alert_raw.conf

# Upon exit, remove lockfile.
trap "{ rm -f $LOCKFILE_ORALMS ; exit 255; }" EXIT

# Sanity check
if [ -f $LOCKFILE_ORALMS ]; then
  echo "$LOCKFILE_ORALMS found, another instance of oralms is already running "
  exit 1
fi

# Set lock file
touch $LOCKFILE_ORALMS

# Check if parameter with config file was provided
if [ "$1" == ""  ]; then
  echo "No parameter was provided. Please provide the configuration file as first parameter. "
  exit 1
fi
LOGSURFER_CONFIG_FILE="$1"
echo "Using configuration file: ${LOGSURFER_CONFIG_FILE}"


# Filter global_alert_raw.log to global_alert.log based on rules defined in logsurfer_global_alert_raw.conf
logsurfer -f -s -c ${LOGSURFER_CONFIG_FILE} ${GLOBAL_ALERT_RAW} >> ${GLOBAL_ALERT} &
PID=$!
touch ${LOCKFILE_SPAN}_${PID}_.lock


# The last called application, after which all processes spawned will be killed
echo "Please leave this window open."
echo "Filtering has been started."
echo "If you press any key all the filtering will be stopped."
echo "Launch viewing now in another window"
read

# Kill all the spanned processes
echo "Please wait untill I kill all the spawned processes"
for i in `ls -1 ${LOCKFILE_SPAN}_*.lock`; do
  # get proccess PID
  PID=`echo $i | awk -F _ '{ print $4 }'`
  echo "Killing PID : ${PID}"
  kill ${PID}
  echo "Removing lock file: $i"
  rm -f $i
done
echo "Done."
