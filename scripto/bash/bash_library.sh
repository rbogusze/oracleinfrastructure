#!/bin/ksh
#$Id: bash_library.sh,v 1.64 2010/02/26 13:57:31 remikcvs Exp $
#
# This is the main script that is included in every bash script I write
# This should be the central and one place to change things that should be centralised
# ala ma kota

# if RECIPIENTS value is set, preserve it.
# RECIPIENTS not set, ~/.scripto_recipients found, setting from file
if [ -z "$RECIPIENTS" ] && [ -f ~/.scripto_recipients ]; then
  RECIPIENTS=`cat ~/.scripto_recipients`
fi

# if RECIPIENTS was somehow not set in ~/.scripto_recipients
[ -z "$RECIPIENTS" ] && RECIPIENTS='remigiusz.boguszewicz@gmail.com'

# Level of messages
[ -z "$INFO_MODE" ] && INFO_MODE='INFO'
# The default level of messages is INFO. It is active if no INFO_MODE is set.
# Which function is printing the output
# | INFO_MODE 	| 	|
# | NONE      	|	|
# | ERROR	| msge	|
# | INFO	| msge, msga, msgb, msgw, msgi |
# | DEBUG	| msge, msga, msgb, msgw, msgi, msgd |

# Usefull Functions

error_log()
{
  echo "[ error ]["`hostname`"]""["$0"]" $1
  MSG=$1
  shift
  for i in $*
  do
    if `echo ${i} | grep "@" 1>/dev/null 2>&1`
    then
      echo "[ info ] Found @ in adress, sending above error to ${i}"
      $MAILCMD -s "[error]["`hostname`"]""["$0"] ${MSG}" ${i} < /dev/null > /dev/null
    else
      echo "[ info ] Not found @ in adress, sending above error to ${i}@orainf.com"
      $MAILCMD -s "[ error ]["`hostname`"]""["$0"] ${MSG}" ${i}@orainf.com < /dev/null > /dev/null
    fi
    shift
  done
}

check_directory()
{
  # Sanity check. For writable logging directory
  if [ ! -d $1 ]; then
    error_log "Directory ${1} does not exists. Exiting. " ${RECIPIENTS}
    exit 1
  fi

  # Sanity checking: check for writable logging directory
  if [ ! -w $1 ]; then
    error_log "Directory ${1} is not writable. Exiting. " ${RECIPIENTS}
    exit 1
  fi
}

check_file()
{
  if [ -z "$1" ]; then
    error_log "[ check_file ] Provided parameter is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi

  if [ ! -f "$1" ]; then
    error_log "[ error ] $1 not found. Exiting. " ${RECIPIENTS}
    exit 1
  else
    msgd "$1 found."
  fi
}

check_variable()
{
  if [ -z "$1" ]; then
    error_log "[ check_variable ] Provided variable ${2} is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi
}

check_parameter()
{
  check_variable "$1" "$2"
}

check_lock()
{
  if [ -z "$1" ]; then
    error_log "[ check_lock ] Provided parameter is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi

  if [ -f $1 ]; then
    error_log "[ error ] Lock file $1 found. Another process is already running. Exiting. " ${RECIPIENTS}
    exit 1
  fi
}



msg()
{
  echo "| `/bin/date '+%Y%m%d %H:%M:%S'` $1"
}

# Fancy msg with prefix message and colors

# [debug] in green
msgd()
{
  if [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[32m'
    echo -n "[debug]    "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}

# [debug] in magenta
msgdm()
{
  if [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[35m'
    echo -n "[debug] "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}


# [info] in green
msgi()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[32m'
    echo -n "[info]     "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}

# raw output in green without end line character
msgri()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -e -n '\E[32m'
    echo -n "$1"
    echo -e -n '\E[39m\E[49m'
  fi
}



# [error] in red, and beep
msge()
{
  if [ "$INFO_MODE" = "ERROR" ] || [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[31m\07'
    echo -n "[error]  "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}

# [action] in blue
msga()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[34m'
    echo -n "[action] "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}

# [block] in magenta
msgb()
{
  if [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[35m'
    echo -n "[block] "
    echo -e -n '\E[39m\E[49m'
    echo "$1"
  fi
}

# [wait] in cyan
msgw()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    echo -e -n '\E[36m'
    echo -n "[wait]   "
    echo -e -n '\E[39m\E[49m\07'
    echo "$1"
  fi
}

# [continue] in yellow
# print text $1 and wait for user reply $2 / $3
# $2 continue, $3 exit, default yes no
# msgc "Are You sure to continue" "yes" "no"
msgc()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    
    RET_TMP=""
	LOOP=1
	YY=$2
	NN=$3
	[ -z "$YY" ] &&  YY="yes"
	[ -z "$NN" ] &&  NN="no"
    # echo "$1 ($2/$3) ?"
	## while proper reply
	
	while [ "$LOOP" ] ; do
	    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
        echo -e -n '\E[33m'
        echo -n "[continue] "
        echo -e -n '\E[33m\E[49m\07'
        read -p  "$1 ($YY/$NN) ?  "   RET_TMP
	
	    if [ "$RET_TMP" == "$YY"  ] ; then
	         echo -e -n '\E[39m\E[49m\07'
	         return 0
	    elif [ "$RET_TMP" == "$NN" ] ; then
		     echo -e -n '\E[39m\E[49m\07'
	         exit 1
	    else 
		     echo
			 echo -e -n '\E[31m\07'
	         echo " Please respond $YY or $NN "
			 echo -e -n '\E[39m\E[49m\07'
			 echo
			 
	    fi
	done
	
  fi
}


# Runs the command provided as parameter. 
# Does NOT exit if the command fails.
# Sends error message if the command fails.
run_command()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    msg "\"$1\""
  fi

  # Determining if we are running in a debug mode. If so wait for any key before eval
  if [ -n "$DEBUG_MODE" ]; then
    if [ "$DEBUG_MODE" -eq "1" ] ; then
      echo "[debug wait] Press any key if ready to run the printed command"
      read
    fi  
  fi

  eval $1
  if [ $? -ne 0 ]; then
    error_log "[error] An error occured during: \"$1\"" ${RECIPIENTS}
    return 1
  fi
  return 0
} #run_command

# run command only when INFO_MODE=debug
run_command_d()
{
  if [ -n "$INFO_MODE" ]; then
    if [ "$INFO_MODE" = "DEBUG" ] ; then
      msg "\"$1\""
      eval $1
    fi  
  fi
  return 0
} #run_command_d

# Runs the command provided as parameter. 
# Does exit if the command fails.
# Sends error message if the command fails.
run_command_e()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    msg "\"$1\""
  fi

  # Determining if we are running in a debug mode. If so wait for any key before eval
  if [ -n "$DEBUG_MODE" ]; then
    if [ "$DEBUG_MODE" -eq "1" ] ; then
      echo "[debug wait] Press any key if ready to run the printed command"
      read
    fi  
  fi

  eval $1
  if [ $? -ne 0 ]; then
    error_log "[critical] An error occured during: \"$1\". Exiting NOW." ${RECIPIENTS}
    exit 1
  fi
  return 0
} #run_command_e

# Run command untill successfull, when error encoutered waits for any key, then repeats the command
run_command_ok()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    msg "\"$1\""
  fi

  eval $1
  if [ $? -ne 0 ]; then
    msge "zzz An error occured during: \"$1\". "                             
    msgw "Fix the problem and press any key (any)"
    exec 8</dev/tty
    read V_TMP <&8
    run_command_ok "$1"
  fi
  return 0
} #f_run_untill_ok



# eg. check_for_running_processes "FND"
#     check_for_running_processes "ora_"
check_for_running_processes()
{
  if [ -z "$1" ]; then
    error_log "[ check_for_running_processes ] Provided parameter is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi

  msg "[check_for_running_processes] Checking for running $1 processess"
  if [ `ps -ef |egrep -v '(grep|vppdc)'|egrep -c $1` -ne 0 ]; then
    error_log "$1 [ check_for_running_processes ] processes are still running. Exiting." ${RECIPIENTS}
    exit 1
  fi
  msg "[ check_for_running_processes ] no running $1 processess found"
}

# Check for free space on specified volume ($1) in GB ($2)
# eg check_for_free_space "$DEST_VOLUME" "$DEST_VOLUME_FREE_NEEDED"
#    check_for_free_space "/d8" "30"
check_for_free_space()
{

  DEST_VOLUME=$1
  DEST_VOLUME_FREE_NEEDED=$2

  check_variable "$DEST_VOLUME"
  check_variable "$DEST_VOLUME_FREE_NEEDED"

  msg "[ check_for_free_space ] Checking for available free space."
  msg "[ check_for_free_space ] on $DEST_VOLUME has to be at least $DEST_VOLUME_FREE_NEEDED G of free space"
  DEST_VOLUME_FREE=`df -h $DEST_VOLUME | grep -v "capacity" | awk '{print $4}' | sed 's/G//'`
  msg "[ check_for_free_space ] found $DEST_VOLUME_FREE G of free space"
  if [ "$DEST_VOLUME_FREE" -lt "$DEST_VOLUME_FREE_NEEDED" ] ; then
    error_log "[ check_for_free_space ] There is not enough space on $DEST_VOLUME. I need $DEST_VOLUME_FREE_NEEDED G" ${RECIPIENTS}
    exit 1
  fi
}

# Replaces all occurences of a string in a file
#  to replace ola with zosia in a file laski.txt do
#  replace_in_file "laski.txt" "ola" "zosia"
replace_in_file()
{
  FILE_NAME=$1
  OLD_STR=$2
  NEW_STR=$3
  check_file "$FILE_NAME"
  check_variable "$OLD_STR"

  sed -e "s/$OLD_STR/$NEW_STR/g" $FILE_NAME > $FILE_NAME.tmp
  mv $FILE_NAME.tmp $FILE_NAME
}

remove_empty_lines_in_file()
{
  FILE_NAME=$1
  check_file "$FILE_NAME"

  grep -v "^$" $FILE_NAME > $FILE_NAME.tmp
  mv $FILE_NAME.tmp $FILE_NAME
}

prepend_file_with_string()
{
  FILE_NAME=$1
  NEW_STR=$2
  check_file "$FILE_NAME"

  echo "$NEW_STR" > $FILE_NAME.tmp
  cat $FILE_NAME >> $FILE_NAME.tmp
  mv $FILE_NAME.tmp $FILE_NAME
}

# Return random integer between FLOOR and RANGE (noninclusive)
# example: RND_MM=`random_int "0" "60"`
random_int()
{
  FLOOR=$1
  RANGE=$2

  number=0   #initialize
  while [ "$number" -le $FLOOR ]
  do
    number=$RANDOM
    let "number %= $RANGE"  # Scales $number down within $RANGE.
  done
  echo $number
}


# send_message "Probably the script" $SEND_MAIL_RECIPIENTS
send_message()
{
  echo "[ send_message ]["`hostname`"]""["$0"]" $1
  MSG=$1
  if [ -z "$MSG" ]; then
    msg "Not sending empty email."
  else
    shift
    for i in $*
    do
      echo "[info] Sending email [msg]["`hostname`"]""["$0"] ${MSG} to ${i}"
      echo "${MSG}" | $MAILCMD -s "[msg]["`hostname`"]""["$0"] ${MSG}" ${i}
      shift
    done
  fi
}

# wait for confirmation before running the block
# To be used in construction like:
#b_template()
#{
#  msgb " "
#  msgb " "
#  f_confirm_block_run
#  if [ "${CONFIRM_BLOCK_STATUS}" -eq 0 ]; then
#    msgi "ala ma kota"
#  fi #CONFIRM_BLOCK_STATUS
#} #b_template
f_confirm_block_run()
{
  CONFIRM_BLOCK_STATUS=0
  if [ -n "$CONFIRM_BLOCK" ]; then
    if [ "$CONFIRM_BLOCK" -eq "1" ] ; then
      read -p "[ wait_for_block ] ${FUNCNAME[1]} - Press Enter key if ready (n/any)? " CONFIRM_BLOCK_REPLY

      if [ "$CONFIRM_BLOCK_REPLY" = "n" ]; then
        msgb "${FUNCNAME[1]} skipped by user request."
        CONFIRM_BLOCK_STATUS=1
      else
        msgb "${FUNCNAME[1]} Proceeding with block."
      fi

    fi
  fi
} #f_confirm_block_run

# Run the SQL provided as parameter, eg:
# f_execute_sql "select count(*) from sys.deferror;"
# The return value stored in variable V_EXECUTE_SQL, I can not return it by return x, becouse x has to be integer
# - input as SQL to be executed
f_execute_sql()
{
  check_parameter $ORACLE_HOME
  SQLPLUS=$ORACLE_HOME/bin/sqlplus
  check_file $SQLPLUS

  F_EXECUTE_SQL=/tmp/sql_output.tmp_${USERNAME}_${ORACLE_SID}
 
  msga "Executing SQL: $1"
  $SQLPLUS -S "/ as sysdba" <<EOF > $F_EXECUTE_SQL
set heading off
$1
EOF
  V_EXECUTE_SQL=`cat $F_EXECUTE_SQL | grep -v '^ *$' | tr -d "\n" | tr "\t" " " | tr -s '[:blank:]'`

  TMP_CHK=`echo $V_EXECUTE_SQL | grep "ORA-01034"`
  if [ `echo $TMP_CHK | grep -v '^ *$' | wc -l` -ne 0 ]; then
    echo $V_EXECUTE_SQL
    msge "ORACLE not available. Exiting."
    exit 1
  fi
} #f_execute_sql



# I need this function modified, dirty trick, but i am afraid to change the main one, should be deleted.
f2_execute_sql()
{
  check_parameter $ORACLE_HOME
  SQLPLUS=$ORACLE_HOME/bin/sqlplus
  check_file $SQLPLUS

  F_EXECUTE_SQL=/tmp/sql_output.tmp_${USERNAME}_${ORACLE_SID}
 
  msga "Executing SQL: $1"
  $SQLPLUS -S "/ as sysdba" <<EOF > $F_EXECUTE_SQL
set heading off
set linesize 200
$1
EOF
  V_EXECUTE_SQL=`cat $F_EXECUTE_SQL | grep -v '^ *$' | tr -d "\n" | tr "\t" " " | tr -s '[:blank:]'`

  TMP_CHK=`echo $V_EXECUTE_SQL | grep "ORA-01034"`
  if [ `echo $TMP_CHK | grep -v '^ *$' | wc -l` -ne 0 ]; then
    echo $V_EXECUTE_SQL
    msge "ORACLE not available. Exiting."
    exit 1
  fi
} #f2_execute_sql

# needed modified f_execute_sql to include the heading
f3_execute_sql()
{
  check_parameter $ORACLE_HOME
  SQLPLUS=$ORACLE_HOME/bin/sqlplus
  check_file $SQLPLUS

  F_EXECUTE_SQL=/tmp/sql_output.tmp_${USERNAME}_${ORACLE_SID}
 
  msga "Executing SQL: $1"
  $SQLPLUS -S "/ as sysdba" <<EOF > $F_EXECUTE_SQL
$1
EOF
  V_EXECUTE_SQL=`cat $F_EXECUTE_SQL | grep -v '^ *$' | tr -d "\n" | tr "\t" " " | tr -s '[:blank:]'`

  TMP_CHK=`echo $V_EXECUTE_SQL | grep "ORA-01034"`
  if [ `echo $TMP_CHK | grep -v '^ *$' | wc -l` -ne 0 ]; then
    echo $V_EXECUTE_SQL
    msge "ORACLE not available. Exiting."
    exit 1
  fi
} #f3_execute_sql




# For running SQL connected as provided user. Connection as $2 in format "user/password"
f_user_execute_sql()
{
  check_parameter $ORACLE_HOME
  SQLPLUS=$ORACLE_HOME/bin/sqlplus
  check_file $SQLPLUS
  check_parameter $2

  F_EXECUTE_SQL=/tmp/sql_output.tmp_${USERNAME}_${ORACLE_SID}_$$
 
  msgd "Executing SQL: $1"
  $SQLPLUS -S "$2" <<EOF > $F_EXECUTE_SQL
set heading off
set linesize 200
$1
EOF
  V_EXECUTE_SQL=`cat $F_EXECUTE_SQL | grep -v '^ *$' | tr -d "\n" | tr "\t" " " | tr -s '[:blank:]'`

  TMP_CHK=`echo $V_EXECUTE_SQL | grep "ORA-01034"`
  if [ `echo $TMP_CHK | grep -v '^ *$' | wc -l` -ne 0 ]; then
    echo $V_EXECUTE_SQL
    msge "ORACLE not available. Exiting."
    exit 1
  fi
} #f_user_execute_sql


# Return error if any rows from query are returned
f_execute_sql_no_rows_expected()
{
  check_parameter $ORACLE_HOME
  SQLPLUS=$ORACLE_HOME/bin/sqlplus
  check_file $SQLPLUS

  F_EXECUTE_SQL=/tmp/sql_output.tmp_${USERNAME}_${ORACLE_SID}
 
  msga "Executing SQL: $1"
  $SQLPLUS -S "/ as sysdba" <<EOF > $F_EXECUTE_SQL
set heading off
$1
EOF
  V_EXECUTE_SQL=`cat $F_EXECUTE_SQL | grep -v '^ *$' | tr -d "\n" | tr "\t" " " | tr -s '[:blank:]'`

  if [ ! "$V_EXECUTE_SQL" = "no rows selected" ]; then
    echo $V_EXECUTE_SQL
    msge "The query returned some rows, it should not. Exiting"
    exit 1
  fi
} #f_execute_sql_no_rows_expected

# Gather basic information aout db, version, invalids, etc.
# eg. f_db_status "invalids_before_pre-upgrade_preparation"
# - input as outbut file to store the results
f_db_status()
{
  check_file $SQLPLUS
  check_parameter $1
  msgi "f_db_status, output into: $1"
  $SQLPLUS -S "/ as sysdba" <<EOF > $1
select * from v\$version;
select name from v\$database;
set pagesize 999
column status format a15
column version format a15
column comp_name format a35
column object_name format A30
column owner format A20
select object_name, owner, object_type from dba_objects where status != 'VALID' order by owner;
SELECT comp_name, status, substr(version,1,10) as version from dba_registry order by modified;
EOF
} #f_db_status

# Change memory parameter in init file if lower than provided value
# The point is not to blindly set specufic values if they were already larger
# $1 - init file (text)
# $2 - parameter
# $3 - desired minimal value
# | parameter | current value | should be | Status |
f_change_init_para()
{
  FILE=$1
  INIT_PARAM=$2
  MIN_VALUE=$3
  check_parameter $FILE
  check_parameter $INIT_PARAM
  check_parameter $MIN_VALUE

  msgd "Checking $1 for value of $2 which should be larger than $3"
  INIT_VALUE=`cat $FILE | grep -i "$INIT_PARAM" | awk -F"=" '{ print $2 }'`
  # If no value is returned it means that parameter is not set and I assume value 0
  if [ -z "$INIT_VALUE" ]; then
    INIT_VALUE=0
  fi
  msgd "Value from init file: INIT_VALUE: $INIT_VALUE"

  # Nothing will change if the value is already in bytes
  INIT_VALUE_BYTES=$INIT_VALUE

  # Convert into bytes if value provided as xM or xG to ease comparison
  if [ `echo $INIT_VALUE | grep -i "M"` ]; then
    TMP_VAL=`echo $INIT_VALUE | sed -e s/[mM]//`
    INIT_VALUE_BYTES=`expr $TMP_VAL \* 1024 \* 1024`
    msgd "Convert into bytes if M: INIT_VALUE_BYTES: $INIT_VALUE_BYTES"
  fi

  if [ `echo $INIT_VALUE | grep -i "G"` ]; then
    TMP_VAL=`echo $INIT_VALUE | sed -e s/[gG]//`
    INIT_VALUE_BYTES=`expr $TMP_VAL \* 1024 \* 1024 \* 1024`
    msgd "Convert into bytes if G: INIT_VALUE_BYTES: $INIT_VALUE_BYTES"
  fi

  MIN_VALUE_BYTES=$MIN_VALUE
  if [ `echo $MIN_VALUE | grep -i "M"` ]; then
    TMP_VAL=`echo $MIN_VALUE | sed -e s/[mM]//`
    MIN_VALUE_BYTES=`expr $TMP_VAL \* 1024 \* 1024`
  fi

  if [ `echo $MIN_VALUE | grep -i "G"` ]; then
    TMP_VAL=`echo $MIN_VALUE | sed -e s/[gG]//`
    MIN_VALUE_BYTES=`expr $TMP_VAL \* 1024 \* 1024 \* 1024`
  fi

  msgd "Comparing $INIT_VALUE_BYTES $MIN_VALUE_BYTES"
  check_parameter $INIT_VALUE_BYTES
  check_parameter $MIN_VALUE_BYTES
  if [ $INIT_VALUE_BYTES -ge $MIN_VALUE_BYTES ]; then
    echo "| $INIT_PARAM | $INIT_VALUE | $MIN_VALUE | OK. |"
  else
    echo "| $INIT_PARAM | $INIT_VALUE | $MIN_VALUE | too small |"
    echo "| [action] changing value of $INIT_PARAM to $MIN_VALUE |"
    cat $FILE | grep -i -v "$INIT_PARAM" > /tmp/tmp_10g_init
    echo "${INIT_PARAM}=${MIN_VALUE}" >> /tmp/tmp_10g_init
    cp /tmp/tmp_10g_init $FILE
  fi
} #f_change_init_para


f_determine_sby_conf() {
	msgi "Determine database configuration ( primary / standby / single )"
	
    VROLE=single
    f_execute_sql "select database_role from v\$database;"
	RET=`cat $F_EXECUTE_SQL | grep STANDBY`
	#msgw "1 $RET"
    if [ "$RET" == "PHYSICAL STANDBY" ] ; then
       VROLE=standby
    else
       ## primary or single ?
       f_execute_sql "select group# from v\$standby_log;"
	   RET=`cat $F_EXECUTE_SQL | grep 'no rows'`
	   #msgw "2 $RET"
       if [ "$RET" == "no rows selected" ] ; then
          VROLE=single
       else
          VROLE=primary
       fi
       
    fi
    
    # for test
    export  VROLE
	msgw "DB role is : $VROLE"


} #f_determine_sby_conf


# Perform checksum of the file provided as $1 with the digest provided as $2
# If they do not match, exit
f_checksum()
{
  check_file $1
  check_parameter $2
  msga "Computing checksum of $1"
  run_command_e "V_CKSUM=`cksum $1 | awk '{ print $1}'`"
  msgi "Computed digest: $V_CKSUM"
  msgi "Provided digest: $2"
  if [ "$V_CKSUM" -eq "$2" ]; then
    msgi "Digest matches. OK"
  else
    msge "Digest does not match. Exiting"
    exit 1
  fi
} #f_checksum

# Run commands contained in a text file $3 on host $1@$2
# it is assumed that connection is made without beeing asked for password
f_run_sh_on_remote_host()
{
  OS_USER_NAME=$1
  HOST_NAME=$2
  SH_FILE=$3
  check_parameter $OS_USER_NAME
  check_parameter $HOST_NAME
  check_parameter $SH_FILE

  COMMANDS_TO_RUN=`cat ${SH_FILE}`
  check_parameter $COMMANDS_TO_RUN
  #echo "I will run: $COMMANDS_TO_RUN"

  ping -c 1 $HOST_NAME >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    #msgi "System $OS_USER_NAME @ $HOST_NAME found (ping). Continuing."
    echo -n ""
  else
    msge "Host $HOST_NAME not found (ping). Skipping."
    exit 1
  fi

  echo $COMMANDS_TO_RUN | ssh -T -o BatchMode=yes -o ChallengeResponseAuthentication=no -o PasswordAuthentication=no -o PubkeyAuthentication=yes -o RSAAuthentication=no -2 -l $OS_USER_NAME $HOST_NAME
} #f_run_sh_on_remote_host


# Run SQL as sysdba contained in a text file $3 on host $1@$2
# it is assumed that connection is made without beeing asked for password
f_run_sql_on_remote_host()
{
  OS_USER_NAME=$1
  HOST_NAME=$2
  SQL_FILE=$3
  check_parameter $OS_USER_NAME
  check_parameter $HOST_NAME
  check_parameter $SQL_FILE

  TMP_FILE=$D_TMPDIR/prepare_to_failover.tmp_sql_output
  COMMANDS_TO_RUN=`cat ${SQL_FILE}`
  check_parameter $COMMANDS_TO_RUN

  ping -c 1 $HOST_NAME >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    #msgi "System $OS_USER_NAME @ $HOST_NAME found (ping). Continuing."
    echo -n ""
  else
    msge "Host $HOST_NAME not found (ping). Skipping."
    exit 1
  fi

  echo "echo \"${COMMANDS_TO_RUN}\" | sqlplus -s '/ as sysdba'" | ssh -T -o BatchMode=yes -o ChallengeResponseAuthentication=no -o PasswordAuthentication=no -o PubkeyAuthentication=yes -o RSAAuthentication=no -2 -l $OS_USER_NAME $HOST_NAME > ${TMP_FILE} 2>&1

  # If database is not available exit with error. Checking for ORA-01034: ORACLE not available
  if [ `cat ${TMP_FILE} | grep ORA-01034 | wc -l` -ne 0 ]; then
    msge "Database at $OS_USER_NAME @ $HOST_NAME not open. Exiting."
    exit 0
  fi

  cat ${TMP_FILE} | grep -v "SQL>" | grep -v "Connected to" | grep -v "Enterprise Edition Release" | grep -v "With the Partitioning" | grep -v "JServer Release" | grep -v "Copyright (c)" | grep -v "SQL.Plus. Release" | grep -v "Sun Microsystems Inc" | grep -v "You have new mail" | grep -v "^$" | grep -v "You are now on" | grep -v "Setting up the" | grep -v "stty. . Invalid argument" | grep -v "Po<B3><B1>czenie z" | grep -v "With the OLAP option" | grep -v "You have mail"
} #f_run_sql_on_remote_host

# This is a very dirty function. It assumes that certain variables are present in environment
# Switch logfile on primary and make sure it is applied on standby
b_primary_standby_confirm_redo_application()
{
  B_PAR=$1 # Check if block was run with parameter
  # Info section
  msgb "${FUNCNAME[0]} Beginning."
  f_confirm_block_run
  if [ "${CONFIRM_BLOCK_STATUS}" -eq 0 ]; then

  check_parameter $V_USER_PRIMARY
  check_parameter $V_HOST_PRIMARY
  check_parameter $V_USER_STANDBY
  check_parameter $V_HOST_STANDBY
  check_directory $D_TMPDIR
  check_parameter $F_SQL_CMND

  msga "Switch logfile"
  cat > $F_SQL_CMND << EOF
alter system checkpoint;
alter system archive log current;
EOF
  f_run_sql_on_remote_host $V_USER_PRIMARY $V_HOST_PRIMARY $F_SQL_CMND

  msga "Record the last applied redo on primary"
  cat > $F_SQL_CMND << EOF
set heading off
SELECT MAX(SEQUENCE#) AS "LAST_APPLIED_LOG" FROM V\\\$LOG_HISTORY GROUP BY THREAD#;
EOF
  f_run_sql_on_remote_host $V_USER_PRIMARY $V_HOST_PRIMARY $F_SQL_CMND > $D_TMPDIR/prepare_to_failover.value.primary_last_applied
  cat $D_TMPDIR/prepare_to_failover.value.primary_last_applied

  V_TMP1=`cat $D_TMPDIR/prepare_to_failover.value.primary_last_applied`
  V_TMP2=0
  while [ ${V_TMP1} -gt ${V_TMP2} ]
  do
    msgi "Sleeping 5sec waiting for redo to be applied on standby"
    sleep 5
    cat > $F_SQL_CMND << EOF
set heading off
SELECT MAX(SEQUENCE#) AS "LAST_APPLIED_LOG" FROM V\\\$LOG_HISTORY GROUP BY THREAD#;
EOF
    f_run_sql_on_remote_host $V_USER_STANDBY $V_HOST_STANDBY $F_SQL_CMND > $D_TMPDIR/prepare_to_failover.value.standby_last_applied
    cat $D_TMPDIR/prepare_to_failover.value.standby_last_applied
    V_TMP2=`cat $D_TMPDIR/prepare_to_failover.value.standby_last_applied`
  done
  msgb "${FUNCNAME[0]} Finished."
  fi #CONFIRM_BLOCK_STATUS
} #b_primary_standby_confirm_redo_application

f_check_if_spfile_is_used()
{
  msgi "Check if spfile is used. It should."
  f_execute_sql "select VALUE from v\$parameter where NAME='spfile';"
  if [ "$V_EXECUTE_SQL" = "" ]; then
    echo $V_EXECUTE_SQL
    msge "Spfile NOT used. Exiting."
    exit 1
  fi
} #f_check_if_spfile_is_used

# Manual and primitive test to make sure you are on cached filesystem
f_check_if_fs_is_cached()
{
  msgb "${FUNCNAME[0]} Started."

  USER_ANSWER=''
  EXIT_WHILE=''
  while [ ! "$EXIT_WHILE" ]
  do
    read -p "[wait] Do you want to test if the filesystem is mounted as cached? (yes/no)" USER_ANSWER
    if [ "$USER_ANSWER" = "yes" ]; then
      msgi "Checking if filesystem is cached"
      EXIT_WHILE=1
    fi
    if [ "$USER_ANSWER" = "no" ]; then
      msgi "Doing nothing."
      return 0
      EXIT_WHILE=1
    fi
  done

  read -p "[wait] Provide a directory where should the test run. (I need to be able to create a subdirectory): " D_CACHE_TEST

  check_directory $D_CACHE_TEST
  run_command_e "cd $D_CACHE_TEST"
  if [ -d "${D_CACHE_TEST}/test_cache" ]; then
    msge "There should be no such a directory ${D_CACHE_TEST}/test_cache "
    msge "It means that the test was interrupted or that such a directory exists."
    msge "Either way something is wrong, please check manually. Exiting"
    exit 0
  fi
  run_command_e "mkdir test_cache"
  run_command_e "cd test_cache"
  if [ ! -f cache.tar.gz ]; then
     run_command_e "wget -q -c http://mirror.pgf.com.pl/oracle/perftuning/cache.tar.gz"
  else
     msgi "Already found cache.tar.gz, not downloading again. OK"
  fi
  run_command_e "gunzip cache.tar.gz"
  msgi "Untaring. Should be below 2min"
  { time tar xf cache.tar ; } 2> $LOG_DIR/test_cache_time
  run_command_e "cd $D_CACHE_TEST"
  run_command_e "rm -Rf test_cache"
  run_command_e "cat $LOG_DIR/test_cache_time"
  V_ELAPSED_TIME=`cat $LOG_DIR/test_cache_time | grep real | awk '{ print $2 }' | awk -F"m" '{ print $1 }'`
  if [ $V_ELAPSED_TIME -lt 2 ]; then
    msgi "It looks like we are on cached filesystem. OK"
  else
    msge "It looks like we are on non-cached filesystem. NOT OK."
    read -p "[wait] Are you sure you want to continue? NOT recommended (yes/any)" V_CONTINUE
    if [ "$V_CONTINUE" = "yes" ]; then
      msgi "Continuing despite recommendation not to continue."
    else
      msge "Exiting"
      exit 1
    fi
  fi 
  
  msgb "${FUNCNAME[0]} Finished."
} #f_check_if_fs_is_cached

# Make sure that we have the min version of dependent files
f_check_min_version_of_script()
{
  V_CHECK_FILE=$1
  V_CHECK_VERSION=`echo $2 | awk -F"." '{ print $2 }'`
  check_file $V_CHECK_FILE
  check_parameter $V_CHECK_VERSION
  V_FILENAME=`basename $V_CHECK_FILE`
  V_FILEDIR=`dirname $V_CHECK_FILE`
  check_directory $V_FILEDIR
  msgd "Checking if file $V_CHECK_FILE is at least on version $V_CHECK_VERSION"
  cd $V_FILEDIR
  V_CURRENT_VERSION=`cvs status $V_FILENAME | grep "Working revision" | tr -d "Working revision:" | tr -d "\t" | awk -F"." '{ print $2 }'`
  msgd "Current version: $V_CURRENT_VERSION"
  msgd "Expected min version: $V_CHECK_VERSION"

  if [ "${V_CHECK_VERSION}" -le "${V_CURRENT_VERSION}" ]; then
    msgd "OK, min expected version: $V_CHECK_VERSION curren version: $V_CURRENT_VERSION"
  else
    msge "min expected version: $V_CHECK_VERSION curren version: $V_CURRENT_VERSION"
    msge "Consider updateing $V_CHECK_FILE to current version"
    msge "Exiting."
    exit 1
  fi
} #f_check_min_version_of_script

f_check_expected_format_for_etc_hosts()
{
  # If the provided first parameter is EXIT I exit on error
  V_EXIT=$1

  msgi "Checking if line with localhost contains the hostname. It should not."
  V_CHECK=`cat /etc/hosts | grep -v '^#' | grep localhost | grep ${HOSTNAME} | wc -l`
  msgd "V_CHECK: $V_CHECK"
  if [ "$V_CHECK" -gt 0 ]; then
    msge "Line with localhost contains the hostname. It should not."
    cat /etc/hosts | grep localhost
    msge "Line with localhost should look like:"
    echo "127.0.0.1       localhost"
    msge "This results with the problems in DB agent."
  fi

  msgi "Checking if expected format for localhost found in /etc/hosts"
  msgi "IP      hostname.domain hostname loghost"
  msgd "HOSTNAME: ${HOSTNAME}"
  V_NR_HOSTLINE=`cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl | wc -l`
  if [ "${V_NR_HOSTLINE}" -ne 1 ]; then
    msge "Different number of entries than 1 for ${HOSTNAME}.pgf.com.pl found in /etc/hosts"
    cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl
  else
    V_HOSTLINE1=`cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl | awk '{ print $1 }'`
    msgd "V_HOSTLINE1: $V_HOSTLINE1"
    V_HOSTLINE2=`cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl | awk '{ print $2 }'`
    msgd "V_HOSTLINE2: $V_HOSTLINE2"
    V_HOSTLINE3=`cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl | awk '{ print $3 }'`
    msgd "V_HOSTLINE3: $V_HOSTLINE3"
    V_HOSTLINE4=`cat /etc/hosts | grep -v '^#' | grep ${HOSTNAME}.pgf.com.pl | awk '{ print $4 }'`
    msgd "V_HOSTLINE4: $V_HOSTLINE4"

    if [ ! "${V_HOSTLINE2}" = "${HOSTNAME}.pgf.com.pl" ]; then
      msge "The second column should be ${HOSTNAME}.pgf.com.pl"
      if [ "$V_EXIT" == "EXIT" ]; then msge "Exiting. Fix the problem and rerun."; exit 1; fi
    fi
    if [ ! "${V_HOSTLINE3}" = "${HOSTNAME}" ]; then
      msge "The third column should be ${HOSTNAME}"
      if [ "$V_EXIT" == "EXIT" ]; then msge "Exiting. Fix the problem and rerun."; exit 1; fi
    fi
    if [ ! "${V_HOSTLINE4}" = "loghost" ]; then
      msge "The fourth column should be loghost"
      if [ "$V_EXIT" == "EXIT" ]; then msge "Exiting. Fix the problem and rerun."; exit 1; fi
    fi
  fi # ${V_NR_HOSTLINE}" -ne 1

  msgi "The production host should use DNS and not static entries from /etc/hosts"
  msgi "Checking if static entries exist in /etc/hosts"
  V_STATIC_HOSTS_NR=`cat /etc/hosts | grep -v "^#" | grep -v localhost | grep -v ${HOSTNAME}.pgf.com.pl | wc -l`
  if [ "${V_STATIC_HOSTS_NR}" -ne 0 ]; then
    msge "Found static entries in /etc/hosts. If this is a production host this should not happen"
    cat /etc/hosts | grep -v "^#" | grep -v localhost | grep -v ${HOSTNAME}.pgf.com.pl
    if [ "$V_EXIT" == "EXIT" ]; then msge "Exiting. Fix the problem and rerun."; exit 1; fi
  fi

  msgi "Check if I can ping to myself"
  run_command "ping ${HOSTNAME} > /dev/null"
  run_command "ping ${HOSTNAME}.pgf.com.pl > /dev/null"

} #f_check_expected_format_for_etc_hosts

# To warn eg about potential errors with cvs issue a warning when we are getting close 
# to cvs shautdow on 23:00
# $1 - hour HH:MM
# $2 - nr of minutes
f_issue_warning_when_getting_close_to_hour()
{
  msgd "${FUNCNAME[0]} Begin."
  V_HOUR=$1
  V_CLOSE=$2
  check_parameter $V_HOUR
  check_parameter $V_CLOSE

  V_CURRENT_DATE_SEC=`$DATE +%s`
  msgd "V_CURRENT_DATE_SEC: $V_CURRENT_DATE_SEC"

  V_CURRENT_DATE=`$DATE -I`

  V_FUTURE_DATE_SEC=`$DATE --date="$V_CURRENT_DATE $V_HOUR" +%s`
  msgd "V_FUTURE_DATE_SEC : $V_FUTURE_DATE_SEC"

  V_SEC_BETWEEN=`expr $V_FUTURE_DATE_SEC - $V_CURRENT_DATE_SEC`
  msgd "V_SEC_BETWEEN: $V_SEC_BETWEEN"

  if [ "${V_SEC_BETWEEN}" -lt 0 ]; then
    msgd "V_SEC_BETWEEN negative, get an absolute value"
    V_SEC_BETWEEN=`expr $V_SEC_BETWEEN \* -1`
    msgd "V_SEC_BETWEEN: $V_SEC_BETWEEN"
  fi

  V_CLOSE_IN_SEC=`expr $V_CLOSE \* 60 `
  msgd "V_CLOSE_IN_SEC: $V_CLOSE_IN_SEC"

  if [ "${V_SEC_BETWEEN}" -lt "${V_CLOSE_IN_SEC}" ]; then
    msge "We are getting close to provided hour. Issuing a warning"
    ACTION_FINISHED=""
    while [ ! "$ACTION_FINISHED" = "yes" ] && [ ! "$ACTION_FINISHED" = "no" ]
    do
      read  -p "[wait] Are you sure, that you want to continue? (yes/no)" ACTION_FINISHED
    done

    if [ "$ACTION_FINISHED" == "yes" ]; then
      msgi "Continuing despite warning"
    else
      msge "Exiting"
      exit 0
    fi
  else
    msgd "OK, plenty of time"
  fi

  msgd "${FUNCNAME[0]} End."
} #f_issue_warning_when_getting_close_to_hour

# Check file log provided as parameter. 
# By default do not exit when the error is encountered, just send the mail.
#  when $2 is set to EXIT - do exit when errors are found.
check_log()
{
  msgd "${FUNCNAME[0]} Begin."
  F_LOG=$1
  check_file $F_LOG

  V_EXIT_ON_ERROR=$2

  TMP_VAL=`cat $F_LOG | $GREP -i -e "^error" -e "^ORA-" -e "^SP2-"`
  if [ ! "$TMP_VAL" = "" ]; then
    msge "There are some errors in the log file: $F_LOG"
    error_log "There are some errors in the log file: $F_LOG" ${RECIPIENTS}
    echo $TMP_VAL
    if [ "$V_EXIT_ON_ERROR" = "EXIT" ]; then
      msge "Exiting"
      exit 1
    fi

  else
    msgd "No errors in upgrade log file. OK"
  fi

  msgd "${FUNCNAME[0]} End."
} #check_log

# EBS R12 $AD_TOP/sql/ADZDSHOWED.sql
f_R12_ADZDSHOWED()
{
  msgd "${FUNCNAME[0]} Begin."

  F_TMP=/tmp/${USERNAME}_${ORACLE_SID}_f_R12_ADZDSHOWED.tmp

  cat > $F_TMP << EOF
alter session set current_schema = APPS;

SET FEEDBACK OFF;
SET ECHO OFF;

set trimspool on
set pagesize 1000
set linesize 200
set lines 80

column "Edition Name" format a15
column "Type"         format a8
column "Status"       format a8
column "Current?"     format a8

prompt =========================================================================
prompt =                             Editions
prompt =========================================================================


select
    aed.edition_name "Edition Name"
  , ad_zd.get_edition_type(aed.edition_name) "Type"
  , decode(use.privilege, 'USE', 'ACTIVE', 'RETIRED') "Status"
  , decode(aed.edition_name, sys_context('userenv', 'current_edition_name'),
'CURRENT', '') "Current?"
from
    all_editions aed
  , database_properties prop
  , dba_tab_privs use
where prop.property_name = 'DEFAULT_EDITION'
  and use.privilege(+)   = 'USE'
  and use.owner(+)       = 'SYS'
  and use.grantee(+)     = 'PUBLIC'
  and use.table_name(+)  = aed.edition_name
order by 1
/

EOF

  V_TMP=`cat $F_TMP` 

  f_execute_sql "$V_TMP" > /dev/null
  cat $F_EXECUTE_SQL | grep -v "Session altered"

  msgd "${FUNCNAME[0]} End."
} #f_R12_ADZDSHOWED

# EBS R12 $AD_TOP/sql/ADZDSHOWSTATUS.sql (partially)
f_R12_ADOP_STATUS()
{
  msgd "${FUNCNAME[0]} Begin."

  F_TMP=/tmp/${USERNAME}_${ORACLE_SID}_f_R12_ADZDSHOWED.tmp

  cat > $F_TMP << EOF
alter session set current_schema = APPS;

WHENEVER OSERROR EXIT FAILURE ROLLBACK;
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;

SET FEEDBACK OFF;
SET ECHO OFF;
SET VERIFY OFF;
SET PAGESIZE 10000
SET LINESIZE 165
SET NEWPAGE NONE
SET TRIMSPOOL ON
SET SERVEROUT ON

REM  Spool results to adzdshowstatus.out file.
spool adzdshowstatus.out

SET TERMOUT OFF
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MON-YY HH:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-YY HH:MI:SS TZR';
SET TERMOUT ON

-- #################################
-- ## CURRENT PATCHING SESSION ID ##
-- #################################


SET TERMOUT OFF
COLUMN P1 NEW_VALUE 1
select null P1 from dual where 1=2;

VARIABLE parm VARCHAR2(20);
VARIABLE g_clone_at_next_s number;
VARIABLE g_clone_at_present_s number;
VARIABLE g_abandon_node_exists number;
-- initialize the bind variables
begin
  :g_clone_at_next_s := 0;
  :g_clone_at_present_s := 0;
  :g_abandon_node_exists := 0;
end;
/
begin
  select NVL('&1', 'NOVALUESPECIFIED')P1 into :parm from dual;
end;
/

SET TERMOUT on

-- This bind variable will hold the report session id (PATCH or RUN)
VARIABLE report_session_id NUMBER

declare
  l_session_id         number;
  l_session_id_patches number;
  l_bug_number         varchar2(30);
begin
  if (:parm = 'NOVALUESPECIFIED') then --no session id passed, use RUN session id
    begin
       select max(adop_session_id) into l_session_id from ad_adop_sessions;
    exception
      when others then
       RAISE_APPLICATION_ERROR (-20001, 'No Session ID found.');
    end;

    if (l_session_id is null)
    then
       RAISE_APPLICATION_ERROR (-20001, 'Status report cannot be generated until an online patching session has been run.');
    end if;
    select adop_session_id into l_session_id_patches from ad_adop_session_patches
           where
           adop_session_id = (select max(adop_session_id) from ad_adop_session_patches)
           and bug_number in ('CLONE','CONFIG_CLONE') and rownum = 1;
    if (l_session_id_patches > l_session_id) then
         :g_clone_at_next_s := 1;
         :report_session_id := l_session_id_patches;
    elsif (l_session_id_patches = l_session_id) then
         :g_clone_at_present_s := 1;
         :report_session_id := l_session_id_patches;
    else
         :report_session_id := l_session_id;
    end if;
  else
    begin
       select bug_number into l_bug_number
           from (select ap.bug_number from ad_adop_session_patches ap
           where ap.adop_session_id =  :parm
           and not exists ( select ad.adop_session_id
                            from ad_adop_sessions ad
                            where ad.adop_session_id = :parm ) ) where rownum=1;
       if(l_bug_number = 'CLONE' or l_bug_number = 'CONFIG_CLONE') then
           :g_clone_at_next_s := 1;
       else
           :g_clone_at_next_s := 0;
       end if;
    exception
       when others then
           :g_clone_at_next_s := 0;
    end;
    :report_session_id := :parm;
  end if;
exception
  when others then
    :report_session_id := l_session_id;
end;
/

DEFINE s_report_session_id = 0;
COLUMN SESSION_ALIAS NEW_VALUE s_report_session_id NOPRINT

-- Use the TRIM command to chop off leading white space in the display
select TRIM(:report_session_id) SESSION_ALIAS
  from dual;

DEFINE s_clone_at_next_s =0;
COLUMN REPORT_ALIAS NEW_VALUE s_clone_at_next_s NOPRINT
select TRIM(:g_clone_at_next_s) REPORT_ALIAS from dual;

-- #############################
-- ## CHECK IF SESSION EXISTS ##
-- #############################

declare
  l_adop_session_id number;
begin
select 1 into l_adop_session_id from dual
    where exists (select distinct adop_session_id
          from ad_adop_sessions
           where adop_session_id=&s_report_session_id)
    or
          exists (select distinct adop_session_id
          from ad_adop_session_patches
           where adop_session_id=&s_report_session_id);

exception
   when others then
        RAISE_APPLICATION_ERROR (-20001, 'No such SESSION_ID found.  Please
recheck SESSION_ID.');
end;
/

prompt Current Patching Session ID: &s_report_session_id
prompt

-- ##########################
-- ## CURRENT PHASE DETAIL ##
-- ##########################
BREAK ON "Node Name" SKIP 1 -
      ON "Node Type"

column "Node Name" format a15
column "Node Type" format a15
column "Phase"     format a15
column "Status"    format a15
column "Started"   format a30
column "Finished"  format a30
column "Elapsed"   format a12

select * from (
  select ap.node_name "Node Name",
       CASE
       WHEN exists (select fc.node_name from FND_OAM_CONTEXT_FILES fc
                where fc.NAME not in ('TEMPLATE','METADATA','config.txt')
                      and fc.CTX_TYPE='A' and (fc.status is null or upper(fc.status) in ('S','F'))
                      and EXTRACTVALUE(XMLType(TEXT),'//file_edition_type') = 'run'
                      and EXTRACTVALUE(XMLType(TEXT),'//oa_service_group_status[@oa_var=''s_web_admin_status'']')='enabled'
                      and EXTRACTVALUE(XMLType(TEXT),'//oa_service_list/oa_service[@type=''admin_server'']/oa_service_status')='enabled'
                      and fc.node_name = ap.node_name)
         THEN 'master'
         ELSE 'slave'
       END "Node Type",
       case
         when ap.bug_number = 'CLONE'
         then 'FS_CLONE'
         else ap.bug_number
        end "Phase",
       case
         when ap.status='Y' and ap.clone_status = 'COMPLETED'
            then 'COMPLETED'
          when ap.status='F' and ap.clone_status <> 'COMPLETED'
            then 'FAILED'
          when ap.status='R' and ap.clone_status <> 'COMPLETED'
             then 'RUNNING'
          when ap.status='N' and ap.clone_status = 'NOT-STARTED'
             then 'NOT STARTED'
          else
            'NOT APPLICABLE'
       end "Status",
       to_timestamp_tz(to_char(ap.start_date, 'DD-MON-YY HH:MI:SS'), 'DD-MON-YY HH:MI:SS TZR') "Started",
       to_timestamp_tz(to_char(ap.end_date, 'DD-MON-YY HH:MI:SS'), 'DD-MON-YY HH:MI:SS TZR') "Finished",
       floor((ap.end_date-ap.start_date)*24)||
       decode(TRUNC(ap.end_date-ap.start_date),null,' ',':')||
       lpad(floor(((ap.end_date-ap.start_date)*24-
       floor((ap.end_date-ap.start_date)*24))*60), 2, '0')||
       decode(TRUNC(ap.end_date-ap.start_date),null,' ',':')||
       lpad(mod(round((ap.end_date-ap.start_date)*86400), 60),
       2, '0') "Elapsed"
from ad_adop_session_patches ap
   where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =1
UNION ALL
select node_name "Node Name",
       to_char(NULL) "Node Type",
       'PREPARE' "Phase",
       'NOT APPLICABLE' "Status",
       to_timestamp_tz(NULL) "Started",
       to_timestamp_tz(NULL) "Finished",
       to_char(NULL) "Elapsed"
from ad_adop_session_patches ap
   where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =1
UNION ALL
select node_name "Node Name",
       to_char(NULL) "Node Type",
       'APPLY' "Phase",
       'NOT APPLICABLE' "Status",
       to_timestamp_tz(NULL) "Started",
       to_timestamp_tz(NULL) "Finished",
       to_char(NULL) "Elapsed"
from ad_adop_session_patches ap
   where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =1
UNION ALL
select node_name "Node Name",
       to_char(NULL) "Node Type",
       'CUTOVER' "Phase",
       'NOT APPLICABLE' "Status",
       to_timestamp_tz(NULL) "Started",
       to_timestamp_tz(NULL) "Finished",
       to_char(NULL) "Elapsed"
from ad_adop_session_patches ap
   where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =1
UNION ALL
select node_name "Node Name",
       to_char(NULL) "Node Type",
       'CLEANUP' "Phase",
       'NOT APPLICABLE' "Status",
       to_timestamp_tz(NULL) "Started",
       to_timestamp_tz(NULL) "Finished",
       to_char(NULL) "Elapsed"
from ad_adop_session_patches ap
   where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =1)
ORDER  BY "Node Name",
          DECODE("Phase",
                 'FS_CLONE',    10,
                 'CONFIG_CLONE',20,
                 'PREPARE',     30,
                 'APPLY',       40,
                 'FINALIZE',    50,
                 'CUTOVER',     60,
                 'CLEANUP',     70,
                                80);


select * from (
  select
    node_name "Node Name",
    node_type "Node Type",
    'PREPARE' "Phase",
    case
      when abort_status='Y'
        then 'SESSION ABORTED'
      else
        case
          when prepare_status='Y'
            then 'COMPLETED'
          when prepare_status='R' and status='F'
             then
              case
                 when exists(select 1 from ad_adop_sessions
                           where abandon_flag is null 
                           and node_type='master'
                           and adop_session_id = &s_report_session_id
                          )
                 then 'ABANDONED'
              else
                 'FAILED'
              end
          when prepare_status='R'
            then 'RUNNING'
          when prepare_status='N'
            then 'NOT STARTED'
          when prepare_status='X'
            then 'NOT APPLICABLE'
        end
    end "Status",
    to_timestamp_tz(to_char(prepare_start_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZR') "Started",
    to_timestamp_tz(to_char(prepare_end_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZR') "Finished",
    floor((prepare_end_date-prepare_start_date)*24)||
    decode(TRUNC(prepare_end_date-prepare_start_date),null,' ',':')||
    lpad(floor(((prepare_end_date-prepare_start_date)*24-
    floor((prepare_end_date-prepare_start_date)*24))*60), 2, '0')||
    decode(TRUNC(prepare_end_date-prepare_start_date),null,' ',':')||
    lpad(mod(round((prepare_end_date-prepare_start_date)*86400), 60),
         2, '0') "Elapsed"
  from ad_adop_sessions
  where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =0
  UNION ALL
  select
    node_name "Node Name",
    node_type "Node Type",
    'APPLY' "Phase",
    case
      when abort_status='Y'
        then 'SESSION ABORTED'
      else
        case
          when apply_status='Y'
            then 'COMPLETED'
          when apply_status='P' and cutover_status in ('N','X') and prepare_status in ('Y','X') and status='F'
             then
              case
                 when exists(select 1 from ad_adop_sessions
                           where abandon_flag is null
                           and node_type='master'
                           and adop_session_id = &s_report_session_id
                          )
                 then 'ABANDONED'
              else
                 'FAILED'
              end
          when apply_status='P' and cutover_status in ('N','X') and prepare_status in ('Y','X') and status='R'
            then 'RUNNING'
          when apply_status='N'
            then 'NOT STARTED'
          else
            'ACTIVE'
        end
    end "Status",
    to_timestamp_tz(to_char(apply_start_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Started",
    to_timestamp_tz(to_char(apply_end_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Finished",
    floor((apply_end_date-apply_start_date)*24)||
    decode(TRUNC(apply_end_date-apply_start_date),null,' ',':')||
    lpad(floor(((apply_end_date-apply_start_date)*24-
    floor((apply_end_date-apply_start_date)*24))*60), 2, '0')||
    decode(TRUNC(apply_end_date-apply_start_date),null,' ',':')||
    lpad(mod(round((apply_end_date-apply_start_date)*86400), 60),
         2, '0') "Elapsed"
  from ad_adop_sessions
  where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =0
  UNION ALL
  select
    node_name "Node Name",
    node_type "Node Type",
      'CUTOVER' "Phase",
    case
      when abort_status='Y'
        then 'SESSION ABORTED'
      else
        case
          when cutover_status='Y'
            then 'COMPLETED'
          when cutover_status not in ('N','Y','X') and status='F'
             then
              case
                 when exists(select 1 from ad_adop_sessions
                           where abandon_flag is null
                           and node_type='master'
                           and adop_session_id = &s_report_session_id
                          )
                 then 'ABANDONED'
              else
                 'FAILED'
              end
          when cutover_status not in ('N','Y','X') and status='R'
            then 'RUNNING'
          when cutover_status='N'
            then 'NOT STARTED'
          when cutover_status='X'
            then 'NOT APPLICABLE'
        end
    end "Status",
    to_timestamp_tz(to_char(cutover_start_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Started",
    to_timestamp_tz(to_char(cutover_end_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Finished",
    floor((cutover_end_date-cutover_start_date)*24)||
    decode(TRUNC(cutover_end_date-cutover_start_date),null,' ',':')||
    lpad(floor(((cutover_end_date-cutover_start_date)*24-
    floor((cutover_end_date-cutover_start_date)*24))*60), 2, '0')||
    decode(TRUNC(cutover_end_date-cutover_start_date),null,' ',':')||
    lpad(mod(round((cutover_end_date-cutover_start_date)*86400), 60),
         2, '0') "Elapsed"
  from ad_adop_sessions
  where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =0
  UNION ALL
  select
    node_name "Node Name",
    node_type "Node Type",
    'CLEANUP' "Phase",
    case
           when cleanup_status='Y'
              then 'COMPLETED'
           when prepare_status in ('Y','X') and apply_status='Y' and cutover_status in ('Y','X') and cleanup_status='N' and status='F'
              then 'FAILED'
           when prepare_status in ('Y','X') and apply_status='Y' and cutover_status in ('Y','X') and cleanup_status='N' and status='R'
              then 'RUNNING'
           else
              'NOT STARTED'
    end "Status",
    to_timestamp_tz(to_char(cleanup_start_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Started",
    to_timestamp_tz(to_char(cleanup_end_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Finished",
    floor((cleanup_end_date-cleanup_start_date)*24)||
    decode(TRUNC(cleanup_end_date-cleanup_start_date),null,' ',':')||
    lpad(floor(((cleanup_end_date-cleanup_start_date)*24-
    floor((cleanup_end_date-cleanup_start_date)*24))*60), 2, '0')||
    decode(TRUNC(cleanup_end_date-cleanup_start_date),null,' ',':')||
    lpad(mod(round((cleanup_end_date-cleanup_start_date)*86400), 60),
         2, '0') "Elapsed"
  from ad_adop_sessions
  where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =0
  UNION ALL
  select
    node_name "Node Name",
    node_type "Node Type",
    'FINALIZE' "Phase",
    case
      when abort_status='Y'
        then 'SESSION ABORTED'
      else
        case
          when finalize_status='Y'
            then 'COMPLETED'
          when prepare_status ='Y' and apply_status in ('Y','N','X') and finalize_status='R' and status='F'
             then
              case
                 when exists(select 1 from ad_adop_sessions
                           where abandon_flag is null
                           and node_type='master'
                           and adop_session_id = &s_report_session_id
                          )
                 then 'ABANDONED'
              else
                 'FAILED'
              end
          when prepare_status ='Y' and apply_status in ('Y','N','X') and finalize_status='R' and status='R'
            then 'RUNNING'
          when finalize_status = 'X'
            then 'NOT APPLICABLE'
          else
            'NOT STARTED'
        end
    end "Status",
    to_timestamp_tz(to_char(finalize_start_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Started",
    to_timestamp_tz(to_char(finalize_end_date, 'DD-MON-YY HH24:MI:SS'), 'DD-MON-YY HH24:MI:SS TZH:TZM') "Finished",
    floor((finalize_end_date-finalize_start_date)*24)||
    decode(TRUNC(finalize_end_date-finalize_start_date),null,' ',':')||
    lpad(floor(((finalize_end_date-finalize_start_date)*24-
    floor((finalize_end_date-finalize_start_date)*24))*60), 2, '0')||
    decode(TRUNC(finalize_end_date-finalize_start_date),null,' ',':')||
    lpad(mod(round((finalize_end_date-finalize_start_date)*86400), 60),
         2, '0') "Elapsed"
  from ad_adop_sessions
  where adop_session_id = &s_report_session_id
        and &s_clone_at_next_s =0
) order by "Node Type","Node Name",
  DECODE("Phase",
         'PREPARE',  10,
         'APPLY',    20,
         'FINALIZE', 30,
         'CUTOVER',  40,
         'CLEANUP',  50,
                     60);


EOF

  V_TMP=`cat $F_TMP` 

  f_execute_sql "$V_TMP" > /dev/null
  cat $F_EXECUTE_SQL | grep -v "Session altered" | grep -v "^$"

  msgd "${FUNCNAME[0]} End."
} #f_R12_ADOP_STATUS

# Setting some global variables. Now I take care of wheter I am on Linux or Solaris,
# so that I do not need to bother any further

# OS specific variables
case `uname` in
  "AIX")

    ORATAB=/etc/oratab
    # Find GNU find
    if [ -f /opt/freeware/bin/find ]; then
      FIND=/opt/freeware/bin/find
    else
      error_log "[ error ] Could not find suitable FIND executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU cvs
    if [ -f /opt/freeware/bin/cvs ]; then
      CVS=/opt/freeware/bin/cvs
    else
      error_log "[ error ] Could not find suitable CVS executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU awk
    if [ -f /opt/freeware/bin/gawk ]; then
      AWK=/opt/freeware/bin/gawk
    else
      error_log "[ error ] Could not find suitable gawk executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU sed
    if [ -f /opt/freeware/bin/sed ]; then
      SED=/opt/freeware/bin/sed
    else
      error_log "[ error ] Could not find suitable sed executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU date
    if [ -f /opt/freeware/bin/date ]; then
      DATE=/opt/freeware/bin/date
    else
      error_log "[ error ] Could not find suitable date executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU grep
    if [ -f /usr/bin/grep ]; then
      GREP=/usr/bin/grep
    else
      error_log "[ error ] Could not find suitable GREP executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi


    # Find GNU echo
    if [ -f /opt/freeware/bin/echo ]; then
      ECHO=/opt/freeware/bin/echo
    else
      error_log "[ error ] Could not find suitable ECHO executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi


    PING=/etc/ping

    ;;
  "SunOS")
    # echo "I am running on Solaris now"
    ORATAB=/var/opt/oracle/oratab
    # Find GNU find
    if [ -f /opt/csw/bin/gfind ]; then
      FIND=/opt/csw/bin/gfind
    elif [ -f /opt/sfw/bin/gfind ]; then
      FIND=/opt/sfw/bin/gfind
    elif [ -f /opt/csw/bin/gfind ]; then
      FIND=/opt/csw/bin/gfind
    else
      error_log "[ error ] Could not find suitable FIND executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU cvs
    if [ -f /opt/csw/bin/cvs ]; then
      CVS=/opt/csw/bin/cvs
    elif [ -f /opt/sfw/bin/cvs ]; then
      CVS=/opt/sfw/bin/cvs
    elif [ -f /opt/csw/bin/cvs ]; then
      CVS=/opt/csw/bin/cvs
    else
      error_log "[ error ] Could not find suitable CVS executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU awk
    if [ -f /opt/csw/bin/gawk ]; then
      AWK=/opt/csw/bin/gawk
    elif [ -f /opt/sfw/bin/gawk ]; then
      AWK=/opt/sfw/bin/gawk
    fi

    # Find GNU sed
    if [ -f /opt/csw/bin/gsed ]; then
      SED=/opt/csw/bin/gsed
    elif [ -f /opt/sfw/bin/gsed ]; then
      SED=/opt/sfw/bin/gsed
    fi


    # Find GNU rsync
    if [ -f /opt/csw/bin/rsync ]; then
      RSYNC=/opt/csw/bin/rsync
    elif [ -f /opt/sfw/bin/rsync ]; then
      RSYNC=/opt/sfw/bin/rsync
    elif [ -f /opt/csw/bin/rsync ]; then
      RSYNC=/opt/csw/bin/rsync
    else
      error_log "[ error ] Could not find suitable RSYNC executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU date
    if [ -f /opt/csw/bin/date ]; then
      DATE=/opt/csw/bin/date
    elif [ -f /opt/sfw/bin/date ]; then
      DATE=/opt/sfw/bin/date
    elif [ -f /opt/csw/bin/gdate ]; then
      DATE=/opt/csw/bin/gdate
    elif [ -f /opt/sfw/bin/gdate ]; then
      DATE=/opt/sfw/bin/gdate
    elif [ -f /opt/csw/bin/gdate ]; then
      DATE=/opt/csw/bin/gdate
    else
      error_log "[ error ] Could not find suitable DATE executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # Find GNU grep
    if [ -f /usr/csw/bin/ggrep ]; then
      GREP=/usr/csw/bin/ggrep
    elif [ -f /usr/sfw/bin/ggrep ]; then
      GREP=/usr/sfw/bin/ggrep
    else
      error_log "[ error ] Could not find suitable GREP executable. Exiting. " ${RECIPIENTS}
      exit 1
    fi

    # So far, I find echo and ping from SUN suitable
    ECHO=/usr/bin/echo
    PING=/usr/sbin/ping

    #USERNAME=`who am I | awk '{print $1}'` - does not work from crontab
    # The next line is bizare, but I found no elegant way
    USERNAME=`id | awk -F"(" '{print $2}' |  awk -F")" '{print $1}'`
    MAILCMD=/bin/mailx
    # Checking If I was able to setup the variables

    ;;
  "Linux")
    #echo "I am running on Linux now"
    ORATAB=/etc/oratab
    FIND=/usr/bin/find
    CVS=/usr/bin/cvs
    GREP=/bin/grep
    AWK=/bin/awk
    SED=/bin/sed
    DATE=/bin/date
    #USERNAME=`who am I | awk '{print $1}'` - does not work from crontab
    # The next line is bizare, but I found no elegant way
    USERNAME=`id | awk -F"(" '{print $2}' |  awk -F")" '{print $1}'`
    MAILCMD=mailx
    PING=/bin/ping
    ;;
  "CYGWIN_NT-6.1")
    ORATAB=/etc/oratab
    FIND=/usr/bin/find
    CVS=/usr/bin/cvs
    GREP=/usr/bin/grep
    AWK=/usr/bin/awk
    SED=/usr/bin/sed
    DATE=/usr/bin/date
    #USERNAME=`who am I | awk '{print $1}'` - does not work from crontab
    # The next line is bizare, but I found no elegant way
    USERNAME=`id | awk -F"(" '{print $2}' |  awk -F")" '{print $1}'`
    MAILCMD=/usr/bin/email
    PING=/usr/bin/ping
    ;;
  "Darwin")
    SVN=svn
    ;;
  *)
    echo "Unknown OS: `uname`. Exiting."
    exit 1
    ;;
esac


