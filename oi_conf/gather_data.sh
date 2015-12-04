#!/bin/bash
# 

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock
CONFIG_FILE=$TMP_LOG_DIR/ldap_out.txt
EXP_SCP_CMD=$HOME/oi_conf/scp_passwd_common.exp
D_CVS_REPO=$HOME/conf_repo

INFO_MODE=DEBUG


# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


mkdir -p $TMP_LOG_DIR
check_directory "$TMP_LOG_DIR"
check_directory $D_CVS_REPO

# Sanity check
check_lock $LOCKFILE
check_file ${EXP_SCP_CMD}

# check for TMP_LOG_DIR
msgd "Ask the ldap for all the hosts to chec. We check there where alert logs are monitored"

$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitFile=*)" "['orainfOsLogwatchUser', 'orclSystemName', 'cn', 'orainfOsLogwatchUserAuth', 'orainfDbInitFile']" | awk '{print $1" "$2" ["$3"_"$2"] "$4" "$5}' > $CONFIG_FILE

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

    # filename to copy from remote host
    F_COPY_FROM_REMOTE=`echo "${LINE}" | gawk '{ print $5 }'`
    msgd "F_COPY_FROM_REMOTE: $F_COPY_FROM_REMOTE"

    if [ -z "$USER_AUTH" ]; then
      msgd "USER_AUTH was not set by the LDAP parameter orainfOsLogwatchUserAuth, defaulting to key"
      USER_AUTH=key
    else
      msgd "It was set by the user: $USER_AUTH"
    fi
    msgd "USER_AUTH: $USER_AUTH"

    # Change the working directory to local CVS repo
    cd $D_CVS_REPO
    mkdir -p "$CN"
    cvs add $CN > /dev/null 2>&1
    cd $CN 

    case $USER_AUTH in
      "key")
        msgd "$USER_AUTH authentication method"
        msge "WIP"
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

          $EXP_SCP_CMD ${USERNAME} ${HOST} ${V_PASS} "${F_COPY_FROM_REMOTE}" 

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

    # Adding the files to CVS
    cvs add * > /dev/null 2>&1
    cvs commit -m "Auto added on `date -I`"

  fi


#exit 0
      msgd "Sleep 1"
      sleep 1


   }
done
exec 3>&-

# On exit remove lock file
rm -f $LOCKFILE
