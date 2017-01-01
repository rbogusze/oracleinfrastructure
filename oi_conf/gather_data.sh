#!/bin/bash
# 
# If orainfDbInitFile= is set, then the instance is taken under consideration. If you want to disable it
# just remove that attribute from the entity

# General variables
PWD_FILE=/home/orainf/.passwords

# Local variables
TMP_LOG_DIR=/tmp/oi_conf
LOCKFILE=$TMP_LOG_DIR/lock
CONFIG_FILE=$TMP_LOG_DIR/ldap_out.txt
EXP_SCP_CMD=$HOME/oi_conf/scp_passwd_common.exp
EXP_SSH_CMD=$HOME/oi_conf/ssh_passwd_common.exp
D_CVS_REPO=$HOME/conf_repo

INFO_MODE=DEBUG


# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi


check_directory "$TMP_LOG_DIR"
check_directory $D_CVS_REPO

# Sanity check
#WIP check_lock $LOCKFILE
check_file ${EXP_SCP_CMD}
check_file ${EXP_SSH_CMD}

check_file $CONFIG_FILE
run_command_d "cat $CONFIG_FILE"

# Set lock file
touch $LOCKFILE


msgd "Cycle through CONFIG_FILE: $CONFIG_FILE and start the data gathering"
exec 3<> $CONFIG_FILE
while read LINEALL <&3
do {
  msgd "################################################################################################"
  msgd "LINEALL: $LINEALL"
  LINE=${LINEALL}

  msgd "Skip line if it is a comment"
  if [[ "$LINE" = \#* ]]; then
    msgd "Line is a comment, skipping"      
    continue
  else
    msgd "Line is NOT a comment. Procceding"
  fi


  if [ ! -z "$LINE" ]; then
    LOG_ID=""
    # set variables

    USERNAME=`echo ${LINE} | gawk '{ print $1 }'`
    msgd "USERNAME: $USERNAME"
    HOST=`echo ${LINE} | gawk '{ print $2 }'`
    msgd "HOST: $HOST"
    LOG_ID=`echo "${LINE}" | gawk '{ print $3 }'`
    msgd "LOG_ID: $LOG_ID"

    msgd "Sanity check if I can ping to the host: $HOST"
    ping -c 1 $HOST >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      msgd "System $OS_USER_NAME @ $HOST found (ping). Continuing."
      echo -n ""
    else
      msge "Host $HOST not found (ping). Skipping."
      continue
    fi



    # Very not elegant way of obtaining 'cn' because of the whole mess to have the prefix at the same length
    CN=`echo $LOG_ID | sed 's/\_.*//' | sed 's/^\[//'`
    msgd "CN: $CN"
   
    # Check the autorisation, if nothing is specified then we assume 'key'
    USER_AUTH=`echo "${LINE}" | gawk '{ print $4 }'`
    msgd "USER_AUTH: $USER_AUTH"

# no longer needed, location of spfile is irrelevant as we create a pfile remotely on desired location
#    # filename to copy from remote host
#    F_COPY_FROM_REMOTE=`echo "${LINE}" | gawk '{ print $5 }'`
#    msgd "F_COPY_FROM_REMOTE: $F_COPY_FROM_REMOTE"

    V_ORACLE_SID=`echo "${LINE}" | gawk '{ print $6 }'`
    msgd "V_ORACLE_SID: $V_ORACLE_SID"
    check_parameter $V_ORACLE_SID

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
          EXECUTE_ON_REMOTE="pwd; . .bash_profile; env | grep ORA; export ORACLE_SID=$V_ORACLE_SID; export ORAENV_ASK=NO; . oraenv; echo -e 'create pfile=\047/tmp/dbinit.txt\047 from spfile;' | sqlplus / as sysdba "
          msgd "EXECUTE_ON_REMOTE: $EXECUTE_ON_REMOTE"
          $EXP_SSH_CMD ${USERNAME} ${HOST} ${V_PASS} "${EXECUTE_ON_REMOTE}" 

          # now the spfile location is actually irrelevant, as we just have the init
          F_COPY_FROM_REMOTE="/tmp/dbinit.txt"
          msgd "F_COPY_FROM_REMOTE: $F_COPY_FROM_REMOTE"

          $EXP_SCP_CMD ${USERNAME} ${HOST} ${V_PASS} "${F_COPY_FROM_REMOTE}" 
          #run_command_d "pwd"
          #run_command_d "ls -l"
          msgd "Some init file cleanup"
          check_file "dbinit.txt"
          run_command "cat dbinit.txt | grep -v '__' > dbinit.txt.tmp "
          run_command "mv dbinit.txt.tmp dbinit.txt"

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

    #run_command_d "ls -l" 

    # no longer needed, as we create init file remotely now.
#    # if there are any spfiles convert them to plain txt files
#    for i in `ls -1 | grep spfile`
#    do
#      msgd "Found spfile, will convert it to plain txt"
#      # one of the ways, but breaks some lines in weird places
#      #strings $i | grep -v '__' > ${i}.txt
#      
#      # better, but requires sqlplus from databse binaries
#      msgd "Running locally create pfile from downloaded spfile"
#      echo -e "create pfile=\047`pwd`/${i}.txt\047 from spfile=\047`pwd`/${i}\047;" | sqlplus / as sysdba
#
#      cat ${i}.txt | grep -v '__' > $i 
#      rm -f ${i}.txt
#    done

    # Adding the files to CVS
    cvs add * > /dev/null 2>&1
    cvs commit -m "Auto added on `date -I` for $CN"

  fi

      msgd "Sleep 1"
      sleep 1


   }
done
exec 3>&-

# On exit remove lock file
rm -f $LOCKFILE
