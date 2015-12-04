#!/bin/bash
# This script should be run from crontab and monitor for existing connection for oralms_gather. If it finds a broken connection (eg. as a result of system reboot) it will span one.

LOCKFILE=/tmp/oralms_gather_monitor.lock
LOCKFILE_SPAN_DIR=/tmp/orainf/oralms/all/locks
LOCKFILE_SPAN=oralms_gather_span
GLOBAL_ALERT=/tmp/global_alert.log
GLOBAL_ALERT_RAW=/tmp/global_alert_raw.log
TMP_LOG_DIR=/tmp/oralms
CONFIG_FILE=/tmp/oralms_ldap_list.txt
AWK_FILE=/tmp/ldap_list.awk
PWD_FILE=/home/orainf/.passwords
TAG_CREATION=easy

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


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

if [ "$TAG_CREATION" = "easy" ]; then
  msgd "easy tag creation"

  $HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'orainfDbAlertLogFile', 'cn']" | awk '{print $1" "$2" "$3" ["$4"_"$2"]"}' > $CONFIG_FILE
else
  msgd "messy tag creation, but equally idented "
  msgd "first pass, determine length of longest host, sid and tns name from ldap"
  $HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'orainfDbAlertLogFile', 'orclSid','cn']" | awk '{ print $4}'         >  /tmp/conf4.list

  $HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'orainfDbAlertLogFile', 'orclSid','cn']" | awk '{ print $2}'         >  /tmp/conf2.list

  $HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'orainfDbAlertLogFile', 'orclSid','cn']" | awk '{ print $5}'         >  /tmp/conf5.list

  LEN_4=`cat /tmp/conf4.list | wc -L`

  LEN_2=`cat /tmp/conf2.list | wc -L`

  LEN_5=`cat /tmp/conf5.list | wc -L`

  msgd "AWK_FILE: $AWK_FILE"
  echo '{ printf $1 " " $2 " " $3 " [" substr($5 "_____________________________",1,' $LEN_5 ') "_" substr($4 "_____________________________",1,' $LEN_4 ') "_" substr($2 "____________________________",1,' $LEN_2 '); v_spnr=split ($3, a, "/"); if (substr(a[v_spnr], 1, 3) == "ale") printf "_A"; if (substr(a[v_spnr], 1, 3) == "drc") printf "_D"; print "] dummy_parm"}' > $AWK_FILE

  $HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'orainfDbAlertLogFile', 'orclSid','cn']"         | awk -f $AWK_FILE >  $CONFIG_FILE
fi 


check_file $CONFIG_FILE

run_command_d "cat $CONFIG_FILE"

# Set lock file
touch $LOCKFILE

# Connect with ssh agent
#. /home/orainf/.ssh-agent

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
    msgd "USERNAME: $USERNAME"
    HOST=`echo ${LINE} | gawk '{ print $2 }'`
    msgd "HOST: $HOST"
    LOGFILE_PATH=`echo ${LINE} | gawk '{ print $3 }'`
    msgd "LOGFILE_PATH: $LOGFILE_PATH"
    ## when last in LINE and host contains 't' >= 't' !!! ( bash or gawk bug ?? )
    LOG_ID=`echo "${LINE}" | gawk '{ print $4 }'`
    msgd "LOG_ID: $LOG_ID"


    # Very not elegant way of obtaining 'cn' because of the whole mess to have the prefix at the same length
    CN=`echo $LOG_ID | sed 's/\_.*//' | sed 's/^\[//'`
    msgd "CN: $CN"
   
    # Check the autorisation, if nothing is specified then we assume 'key'
    USER_AUTH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfOsLogwatchUserAuth']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
    msgd "USER_AUTH: $USER_AUTH"

    if [ -z "$USER_AUTH" ]; then
      msgd "USER_AUTH was not set by the LDAP parameter orainfOsLogwatchUserAuth, defaulting to key"
      USER_AUTH=key
    else
      msgd "It was set by the user: $USER_AUTH"
    fi
    msgd "USER_AUTH: $USER_AUTH"


    msgd "Check for active ssh connection"
    ps -ef | grep -v grep | grep "${USERNAME}@${HOST} tail -f ${LOGFILE_PATH}" > /dev/null

    # If ssh connection is not found establish one
    if [ ! $? -eq 0 ]; then
      sleep 1
      echo   "${LOG_ID} [gather_monitor] Establishing connection for ${HOST}"
      if [ ! -f "${TMP_LOG_DIR}/${LOG_ID}" ] ; then
         touch "${TMP_LOG_DIR}/${LOG_ID}"
      fi

      case $USER_AUTH in
        "key")
          msgd "$USER_AUTH authentication method"
          ssh -o BatchMode=yes ${USERNAME}@${HOST} "tail -f ${LOGFILE_PATH}"  > ${TMP_LOG_DIR}/${LOG_ID} &
          PID=$!
          touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
          ;;
        "password")
          msgd "$USER_AUTH authentication method"
          INDEX_HASH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfOsLogwatchIndexHash']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
          msgd "INDEX_HASH: $INDEX_HASH"
          HASH=`echo "$INDEX_HASH" | base64 --decode -i`
          msgd "HASH: $HASH"
          if [ -f "$PWD_FILE" ]; then
            V_PASS=`cat $PWD_FILE | grep $HASH | awk '{print $2}'`
            msgd "V_PASS: $V_PASS"

            /home/orainf/oi_oralms/ssh_passwd.exp ${USERNAME} ${HOST} ${V_PASS} ${LOGFILE_PATH} > ${TMP_LOG_DIR}/${LOG_ID} &
            PID=$!
            touch ${LOCKFILE_SPAN_DIR}/${LOCKFILE_SPAN}_${PID}_.lock
          else
            msge "Unable to find the password file. Continuing"
            continue
          fi

          ;;
        *)
          msge "Unknown Authentication method. Continue. _${USER_AUTH}_"
          continue
          ;;
      esac


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
    else
      msgd "${LOG_ID} ssh connection already exists, doing nothing."
    fi

  fi

   }
done
exec 3>&-

# On exit remove lock file
rm -f $LOCKFILE
