#!/bin/bash
# This script should be run from crontab and monitor for existing connection for oralms_gather. If it finds a broken connection (eg. as a result of system reboot) it will span one.

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/check_if_gather_stats_is_running
LOCKFILE=$TMP_LOG_DIR/check_if_gather_stats_is_running.lock
CONFIG_FILE=$TMP_LOG_DIR/oralms_ldap_list_check_gs.txt
EXP_SSH_CMD=$HOME/oi_oralms/ssh_passwd_common.exp

#INFO_MODE=DEBUG


# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


mkdir -p $TMP_LOG_DIR
check_directory "$TMP_LOG_DIR"

# Sanity check
check_lock $LOCKFILE
check_file ${EXP_SSH_CMD}

# check for TMP_LOG_DIR
msgd "Ask the ldap for all the hosts to chec. We check there where alert logs are monitored"

$HOME/scripto/perl/ask_ldap.pl "(&(orainfDbAlertLogFile=*)(orainfDbAlertLogMonitoring=TRUE))" "['orainfOsLogwatchUser', 'orclSystemName', 'cn', 'orainfOsLogwatchUserAuth']" | awk '{print $1" "$2" ["$3"_"$2"] "$4}' > $CONFIG_FILE

check_file $CONFIG_FILE

run_command_d "cat $CONFIG_FILE"

# Set lock file
#touch $LOCKFILE


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
    LOG_ID=`echo "${LINE}" | gawk '{ print $3 }'`
    msgd "LOG_ID: $LOG_ID"


    # Very not elegant way of obtaining 'cn' because of the whole mess to have the prefix at the same length
    CN=`echo $LOG_ID | sed 's/\_.*//' | sed 's/^\[//'`
    msgd "CN: $CN"
   
    # Check the autorisation, if nothing is specified then we assume 'key'
    USER_AUTH=`echo "${LINE}" | gawk '{ print $4 }'`
    msgd "USER_AUTH: $USER_AUTH"

    if [ -z "$USER_AUTH" ]; then
      msgd "USER_AUTH was not set by the LDAP parameter orainfOsLogwatchUserAuth, defaulting to key"
      USER_AUTH=key
    else
      msgd "It was set by the user: $USER_AUTH"
    fi
    msgd "USER_AUTH: $USER_AUTH"


    # prepare command to execute on remote machine
    #V_CMD=". ~/.profile_custom; find \$dblog -name gather_* -mtime -24 | grep -i $CN"
    # this 1/24 does not mean 1h - Solaris find does not do arythmetics
    #V_CMD=". ~/.profile_custom; find \$dblog -name gather_* -mtime -1/24 | grep -i $CN"
    # With Solaris find I can only check last day, 1 and 1/24 mean the same for him
    V_CMD=". ~/.profile_custom; find \$dblog -name gather_* -mtime -1 | grep -i $CN"

    mkdir -p ${TMP_LOG_DIR}/${LOG_ID}
    check_directory "${TMP_LOG_DIR}/${LOG_ID}"
    V_DATE=`date '+%Y%m%d_%H%M%S'`
    
      case $USER_AUTH in
        "key")
          msgd "$USER_AUTH authentication method"
          #ssh -o BatchMode=yes ${USERNAME}@${HOST} "pwd"  > ${TMP_LOG_DIR}/${LOG_ID} &
          PID=$!
          ;;
        "password")
          msgd "$USER_AUTH authentication method"
          INDEX_HASH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfOsLogwatchIndexHash']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
          msgd "INDEX_HASH: $INDEX_HASH"
          HASH=`echo "$INDEX_HASH" | base64 --decode -i`
          msgd "HASH: $HASH"
          if [ -f "$PWD_FILE" ]; then
            V_PASS=`cat $PWD_FILE | grep $HASH | awk '{print $2}'`
            #msgd "V_PASS: $V_PASS"

            #/home/orainf/oi_oralms/ssh_passwd.exp ${USERNAME} ${HOST} ${V_PASS} ${LOGFILE_PATH} > ${TMP_LOG_DIR}/${LOG_ID} &
            msgd "V_CMD: $V_CMD"
            $EXP_SSH_CMD ${USERNAME} ${HOST} ${V_PASS} "${V_CMD}" > ${TMP_LOG_DIR}/${LOG_ID}/${V_DATE}

            #checking the remote command output in search for "gather_" files which would indicate recent GS
            TMP_CHK=`cat ${TMP_LOG_DIR}/${LOG_ID}/${V_DATE} | grep -v "spawn" | grep "gather_" | wc -l`
            if [ "${TMP_CHK}" -gt 0 ]; then
              msgd "Found some gather_ files which would indicate recent GS"
              run_command_d "cat ${TMP_LOG_DIR}/${LOG_ID}/${V_DATE}"
              echo "${LOG_ID} ### warning ###"
              echo "${LOG_ID} ### warning: Gather Stats running in the last 24h ###"
              echo "${LOG_ID} ### warning ###"
            else
              msgd "No gather_ files found, no indication on GS performed"
            fi
          else
            msge "Unable to find the password file. Skipping this CN. Continuing"
            continue
          fi

          ;;
        *)
          msge "Unknown Authentication method. Continue. _${USER_AUTH}_"
          continue
          ;;
      esac

   fi


#exit 0
      msgd "Sleep 1"
      sleep 1


   }
done
exec 3>&-

# On exit remove lock file
rm -f $LOCKFILE
