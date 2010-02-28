#!/bin/bash
# $Header: /CVS/cvsadmin/cvsrepository/admin/projects/oralms/oralms_gather_monitor.sh,v 1.24 2010/02/23 15:03:47 remikcvs Exp $
# This script should be run from crontab and monitor for existing connection for oralms_gather. If it finds a broken connection (eg. as a result of system reboot) it will span one.
#set -x

LOCKFILE=/tmp/oralms_gather_monitor.lock
LOCKFILE_SPAN_DIR=/tmp/logwatch/oralms/all/locks
LOCKFILE_SPAN=oralms_gather_span
GREP=/bin/grep
ECHO=/bin/echo
SSH=/usr/bin/ssh
GLOBAL_ALERT=/tmp/global_alert.log
GLOBAL_ALERT_RAW=/tmp/global_alert_raw.log
TMP_LOG_DIR=/tmp/oralms
CONFIG_FILE=/tmp/oralms_ldap_list.txt
AWK_FILE=/tmp/ldap_list.awk

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

RECIPIENTS='Remigiusz_Boguszewicz'

# Sanity check
check_lock $LOCKFILE

# check for TMP_LOG_DIR
if [ ! -d $TMP_LOG_DIR ] ; then
   mkdir $TMP_LOG_DIR
fi

if [ ! -d $LOCKFILE_SPAN ] ; then
   mkdir -p $LOCKFILE_SPAN_DIR
fi

msgd "Ask the ldap for all the alert logs to monitor"
msgd " first pass, determine length of longest host, sid and tns name from ldap"
$HOME/scripto/perl/ask_ldap.pl "(&(remikDbAlertLogFile=*)(remikDbAlertLogMonitoring=TRUE))" "['remikOsLogwatchUser', 'orclSystemName', 'remikDbAlertLogFile', 'orclSid','cn']" | awk '{ print $4}'         >  /tmp/conf4.list

$HOME/scripto/perl/ask_ldap.pl "(&(remikDbAlertLogFile=*)(remikDbAlertLogMonitoring=TRUE))" "['remikOsLogwatchUser', 'orclSystemName', 'remikDbAlertLogFile', 'orclSid','cn']" | awk '{ print $2}'         >  /tmp/conf2.list

$HOME/scripto/perl/ask_ldap.pl "(&(remikDbAlertLogFile=*)(remikDbAlertLogMonitoring=TRUE))" "['remikOsLogwatchUser', 'orclSystemName', 'remikDbAlertLogFile', 'orclSid','cn']" | awk '{ print $5}'         >  /tmp/conf5.list

LEN_4=`cat /tmp/conf4.list | wc -L`

LEN_2=`cat /tmp/conf2.list | wc -L`

LEN_5=`cat /tmp/conf5.list | wc -L`

msgd "AWK_FILE: $AWK_FILE"
echo '{ printf $1 " " $2 " " $3 " [" substr($5 "_____________________________",1,' $LEN_5 ') "_" substr($4 "_____________________________",1,' $LEN_4 ') "_" substr($2 "____________________________",1,' $LEN_2 '); v_spnr=split ($3, a, "/"); if (substr(a[v_spnr], 1, 3) == "ale") printf "_A"; if (substr(a[v_spnr], 1, 3) == "drc") printf "_D"; print "] dummy_parm"}' > $AWK_FILE

$HOME/scripto/perl/ask_ldap.pl "(&(remikDbAlertLogFile=*)(remikDbAlertLogMonitoring=TRUE))" "['remikOsLogwatchUser', 'orclSystemName', 'remikDbAlertLogFile', 'orclSid','cn']"         | awk -f $AWK_FILE >  $CONFIG_FILE

check_file $CONFIG_FILE

# Set lock file
touch $LOCKFILE

# Connect with ssh agent
. /home/logwatch/.ssh-agent

# Direct all messages to a file
exec >> $GLOBAL_ALERT 2>&1

msgd "Cycle through CONFIG_FILE: $CONFIG_FILE and start the data gathering"
exec 3<> $CONFIG_FILE
while read LINEALL <&3
do {
  msgd "LINEALL: $LINEALL"
  LINE=${LINEALL}
  if [ ! -z "$LINE" ]; then
    LOG_ID=""
    # set variables

    USERNAME=`echo ${LINE} | gawk '{ print $1 }'`
    HOST=`echo ${LINE} | gawk '{ print $2 }'`
    LOGFILE_PATH=`echo ${LINE} | gawk '{ print $3 }'`
    ## when last in LINE and host contains 't' >= 't' !!! ( bash or gawk bug ?? )
    LOG_ID=`echo "${LINE}" | gawk '{ print $4 }'`

    # Check for active ssh connection
    ps -ef | grep -v grep | grep "${USERNAME}@${HOST} tail -f ${LOGFILE_PATH}" > /dev/null

    # If ssh connection is not found establish one
    if [ ! $? -eq 0 ]; then
      sleep 1
      echo   "${LOG_ID} [gather_monitor] Establishing connection for ${HOST}"
      if [ ! -f "${TMP_LOG_DIR}/${LOG_ID}" ] ; then
         touch "${TMP_LOG_DIR}/${LOG_ID}"
      fi
      $SSH -o BatchMode=yes ${USERNAME}@${HOST} "tail -f ${LOGFILE_PATH}"  > ${TMP_LOG_DIR}/${LOG_ID} &
      PID=$!
      touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
      msgd "Sleep 8"
      sleep 8

      # If the new monitoring log has been added it need an ssh and tail
      # Hovewer if the connection is lost because of eg backup, then the ssh has to be refreshed only,
      # not tail
      ps -ef | grep -v grep | grep --fixed-strings "tail -f ${TMP_LOG_DIR}/${LOG_ID}" > /dev/null
      if [ ! $? -eq 0 ]; then
        sleep 1
        echo "${LOG_ID} [gather_monitor] Launching tail for ${TMP_LOG_DIR}/${LOG_ID}"
         tail -f "${TMP_LOG_DIR}/${LOG_ID}" | gawk -v tmp_str="${LOG_ID}" '{ print ( tmp_str, $0 ); system(""); fflush("") }' >> ${GLOBAL_ALERT_RAW} &
        PID=$!
        sleep 1
        touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
      else
        echo "${LOG_ID} [gather_monitor] tail for ${LOG_ID} already exists"
      fi
    fi

  fi

   }
done
exec 3>&-

# On exit remove lock file
rm -f $LOCKFILE
