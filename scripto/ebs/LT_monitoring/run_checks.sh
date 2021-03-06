#!/bin/bash
# This script loops through the initial_checks dir, executes the tasks and compares it to expected results
# The SID of the DB to connect to is stored in ~/.LT_SID

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

# Results directory
V_DATE=`date '+%Y%m%d_%H%M%S'`
LOG_DIR=/var/tmp/LT_monitoring/$V_DATE
mkdir -p $LOG_DIR
F_WIKI_SUMMARY=$LOG_DIR/00_wiki_summary.txt

# Assuming connections as apps to DB stored in ~/.LT_SID
f_LT_execute_sql()
{
  msgd "${FUNCNAME[0]} Begin."

  # file name with instructions
  F_LT=$1
  msgd "F_LT: $F_LT" 
  run_command_d "cat $F_LT"

  V_INFO=`cat $F_LT | grep ^INFO | sed -e 's/^INFO:\ //'`
  msgd "V_INFO: $V_INFO"

  V_DETAILS=`cat $F_LT | grep ^DETAILS | sed -e 's/^DETAILS:\ //'`
  msgd "V_DETAILS: $V_DETAILS"

  # Get the SQL to be executed
  V_SQL=`cat $F_LT | grep ^SQL | sed -e 's/^SQL:\ //'`
  msgd "V_SQL: $V_SQL"

  # Check if autotrace is expected
  V_AUTOTRACE=`cat $F_LT | grep ^AUTOTRACE: | sed -e 's/^AUTOTRACE:\ //'`
  msgd "V_AUTOTRACE: $V_AUTOTRACE"

  # Get the execution expected attributes
  # time elapsed
  V_ELAPSED_LT=`cat $F_LT | grep ^ELAPSED_LT: | sed -e 's/^ELAPSED_LT:\ //'`
  msgd "V_ELAPSED_LT: $V_ELAPSED_LT"

  V_GETS_LT=`cat $F_LT | grep ^GETS_LT: | sed -e 's/^GETS_LT:\ //'`
  msgd "V_GETS_LT: $V_GETS_LT"

  V_RESULT_LT=`cat $F_LT | grep ^RESULT_LT: | sed -e 's/^RESULT_LT:\ //'`
  msgd "V_RESULT_LT: $V_RESULT_LT"

  V_RESULT_LE=`cat $F_LT | grep ^RESULT_LE: | sed -e 's/^RESULT_LE:\ //'`
  msgd "V_RESULT_LE: $V_RESULT_LE"

  V_RESULT_EQ=`cat $F_LT | grep ^RESULT_EQ: | sed -e 's/^RESULT_EQ:\ //'`
  msgd "V_RESULT_EQ: $V_RESULT_EQ"

  V_RESULT_GE=`cat $F_LT | grep ^RESULT_GE: | sed -e 's/^RESULT_GE:\ //'`
  msgd "V_RESULT_GE: $V_RESULT_GE"

  V_RESULT_GT=`cat $F_LT | grep ^RESULT_GT: | sed -e 's/^RESULT_GT:\ //'`
  msgd "V_RESULT_GT: $V_RESULT_GT"

  V_RESULT_STR=`cat $F_LT | grep ^RESULT_STR: | sed -e 's/^RESULT_STR:\ //'`
  msgd "V_RESULT_STR: $V_RESULT_STR"

#exit 0


  F_TMP=/tmp/run_initial_checks_execute.txt
  if [ ! -z $V_AUTOTRACE ]; then
    msgd "Run with autotrace on"
    sqlplus -s /nolog << EOF > $F_TMP
    set head off pagesize 0 echo off verify off feedback off heading off
    set linesize 200
    connect $V_USER/$V_PASS@$CN
    set timing on
    set autotrace on
    $V_SQL
EOF

  # Saving the received values 
  run_command_d "cat $F_TMP"
  V_LT_RESULT_ELAPSED=`cat $F_TMP | grep "^Elapsed:" | sed -e 's/Elapsed:\ //'`
  msgd "V_LT_RESULT_ELAPSED: $V_LT_RESULT_ELAPSED"
  V_LT_RESULT_GETS=`cat $F_TMP | grep "consistent gets" | awk '{print $1}' `
  msgd "V_LT_RESULT_GETS: $V_LT_RESULT_GETS"
  #why so complicated? V_LT_RESULT=`cat $F_TMP | head -1 | awk '{print $1}' `
  # just remove multiple spaces between the columns
  # | head -1 - because with autotrace on we have explain plan and stats, that is why only first line
  V_LT_RESULT=`cat $F_TMP | head -1 | tr -d "\t" | tr -s '[:blank:]' | sed -e 's/^[[:space:]]*//'`
  
  else
    msgd "Run with autotrace off"
    sqlplus -s /nolog << EOF > $F_TMP
    set head off pagesize 0 echo off verify off feedback off heading off
    set linesize 200
    connect $V_USER/$V_PASS@$CN
    $V_SQL
EOF

  V_LT_RESULT=`cat $F_TMP | tr -d "\t" | tr -s '[:blank:]' | sed -e 's/^[[:space:]]*//'`
  
  fi #if [ ! -z $V_AUTOTRACE
  
 
  msgd "V_LT_RESULT: $V_LT_RESULT"

  # Comparing the received values with expected
  msgd "Time elapsed less than"
  if [ ! -z $V_ELAPSED_LT ]; then
    V_TMP1=`echo $V_ELAPSED_LT | sed -e 's/://g'`
    msgd "V_TMP1: $V_TMP1"
    V_TMP2=`echo $V_LT_RESULT_ELAPSED | awk -F"." '{print $1}' | sed -e 's/://g'`
    msgd "V_TMP2: $V_TMP2"

    if [ "$V_TMP2" -lt "$V_TMP1" ]; then
      V_ELAPSED_LT_OK="OK, execution time less than expected. Actual: $V_LT_RESULT_ELAPSED Expected: $V_ELAPSED_LT"
    else
      V_ELAPSED_LT_BAD="BAD, execution took longer than expected. Actual: $V_LT_RESULT_ELAPSED Expected: $V_ELAPSED_LT"
    fi
  else
    msgd "No check requested"
  fi

  msgd "Gets less than"
  if [ ! -z $V_GETS_LT ]; then
    if [ "$V_LT_RESULT_GETS" -lt "$V_GETS_LT" ]; then
      V_GETS_LT_OK="OK, nr of gets time less than expected. Actual: $V_LT_RESULT_GETS Expected: $V_GETS_LT"
    else
      V_GETS_LT_BAD="BAD, nr of gets larger than expected. Actual: $V_LT_RESULT_GETS Expected: $V_GETS_LT"
    fi
  else
    msgd "No check requested"
  fi

  msgd "Result less than"
  if [ ! -z $V_RESULT_LT ]; then
    if [ "$V_LT_RESULT" -lt "$V_RESULT_LT" ]; then
      V_RESULT_LT_OK="OK, result less than expected. Actual: $V_LT_RESULT Expected: $V_RESULT_LT"
    else
      V_RESULT_LT_BAD="BAD, result larger than expected. Actual: $V_LT_RESULT Expected: $V_RESULT_LT"
    fi
  else
    msgd "No check requested"
  fi

  msgd "Result less or equal than"
  if [ ! -z $V_RESULT_LE ]; then
    if [ "$V_LT_RESULT" -le "$V_RESULT_LE" ]; then
      V_RESULT_LE_OK="OK, result less or equal than expected. Actual: $V_LT_RESULT Expected: $V_RESULT_LE"
    else
      V_RESULT_LE_BAD="BAD, result larger than expected. Actual: $V_LT_RESULT Expected: $V_RESULT_LE"
    fi
  else
    msgd "No check requested"
  fi



  msgd "Result equal to"
  if [ ! -z $V_RESULT_EQ ]; then
    if [ $V_LT_RESULT -eq $V_RESULT_EQ ]; then
      V_RESULT_EQ_OK="OK, result equal. Actual: $V_LT_RESULT Expected: $V_RESULT_EQ"
    else
      V_RESULT_EQ_BAD="BAD, result not equal. Actual: $V_LT_RESULT Expected: $V_RESULT_EQ"
    fi
  else
    msgd "No check requested"
  fi

  msgd "Result greater or equal to"
  if [ ! -z $V_RESULT_GE ]; then
    if [ $V_LT_RESULT -ge $V_RESULT_GE ]; then
      V_RESULT_GE_OK="OK, result greater or equal to. Actual: $V_LT_RESULT Expected: $V_RESULT_GE"
    else
      V_RESULT_GE_BAD="BAD, result not greater or equal. Actual: $V_LT_RESULT Expected: $V_RESULT_GE"
    fi
  else
    msgd "No check requested"
  fi

  msgd "Result greater"
  if [ ! -z $V_RESULT_GT ]; then
    if [ $V_LT_RESULT -gt $V_RESULT_GT ]; then
      V_RESULT_GT_OK="OK, result greater. Actual: $V_LT_RESULT Expected: $V_RESULT_GT"
    else
      V_RESULT_GT_BAD="BAD, result not greater. Actual: $V_LT_RESULT Expected: $V_RESULT_GT"
    fi
  else
    msgd "No check requested"
  fi



  msgd "Result equal to string"
  if [ ! -z "$V_RESULT_STR" ]; then
    if [ "$V_LT_RESULT" = "$V_RESULT_STR" ]; then
      V_RESULT_STR_OK="OK, result equal. Actual: $V_LT_RESULT Expected: $V_RESULT_STR"
    else
      V_RESULT_STR_BAD="BAD, result not equal. Actual: $V_LT_RESULT Expected: $V_RESULT_STR"
    fi
  else
    msgd "No check requested"
  fi


  # OK, now I have all the required input, time to construct result info

  # If any of the checks failed I mark it on header
  if [ -n "$V_ELAPSED_LT_BAD" ] || [ -n "$V_RESULT_EQ_BAD" ] || [ -n "$V_RESULT_STR_BAD" ] || [ -n "$V_GETS_LT_BAD" ] || [ -n "$V_RESULT_LT_BAD" ] || [ -n "$V_RESULT_LE_BAD" ] || [ -n "$V_RESULT_EQ_BAD" ] || [ -n "$V_RESULT_GE_BAD" ] || [ -n "$V_RESULT_GT_BAD" ] ; then
    msgd "Some checks failed"
    V_HEAD_PREFIX=''
    V_HEAD_SUFFIX=''
    V_RETURN=1
  else
    msgd "All checks are fine"
    V_HEAD_PREFIX=''
    V_HEAD_SUFFIX=''
    V_RETURN=0
  fi

  echo "==== $V_HEAD_PREFIX `basename $F_LT` $V_HEAD_SUFFIX ===="
  echo "$V_INFO $V_DETAILS"
  echo "<hidden Raw test output>"
  echo "<code sql>"
  echo "$V_SQL"
  echo
  cat $F_TMP
  echo "</code>"
  echo "</hidden>"

  V_OK_PREFIX=''
  V_OK_SUFFIX='\\'
  #V_BAD_PREFIX='<html><span style="color:red">'
  #V_BAD_SUFFIX='</span></html>\\'
  V_BAD_PREFIX=':!:'
  V_BAD_SUFFIX='\\'

  if [ -n "$V_ELAPSED_LT_OK" ]; then echo "$V_OK_PREFIX $V_ELAPSED_LT_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_ELAPSED_LT_BAD" ]; then echo "$V_BAD_PREFIX $V_ELAPSED_LT_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_GETS_LT_OK" ]; then echo "$V_OK_PREFIX $V_GETS_LT_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_GETS_LT_BAD" ]; then echo "$V_BAD_PREFIX $V_GETS_LT_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_LT_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_LT_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_LT_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_LT_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_LE_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_LE_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_LE_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_LE_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_EQ_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_EQ_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_EQ_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_EQ_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_GE_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_GE_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_GE_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_GE_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_GT_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_GT_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_GT_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_GT_BAD $V_BAD_SUFFIX"; fi

  if [ -n "$V_RESULT_STR_OK" ]; then echo "$V_OK_PREFIX $V_RESULT_STR_OK $V_OK_SUFFIX"; fi
  if [ -n "$V_RESULT_STR_BAD" ]; then echo "$V_BAD_PREFIX $V_RESULT_STR_BAD $V_BAD_SUFFIX"; fi

  unset V_ELAPSED_LT_OK V_ELAPSED_LT_BAD V_GETS_LT_OK V_GETS_LT_BAD V_RESULT_LT_OK V_RESULT_LT_BAD V_RESULT_LE_OK V_RESULT_LE_BAD V_RESULT_GE_OK V_RESULT_GE_BAD V_RESULT_GT_OK V_RESULT_GT_BAD V_RESULT_STR_OK V_RESULT_STR_BAD V_RESULT_EQ_OK V_RESULT_EQ_BAD

  msgd "${FUNCNAME[0]} End."

  return $V_RETURN
} #f_LT_execute_sql


# Report on section progress
f_section_progress()
{
  msgd "${FUNCNAME[0]} Begin."
  V_SECTION_NAME=$1
  V_TASKS_IN_SECTION=$2
  V_TASK_RESULT=$3  

  exec 1>&3 2>&4
  msgd "V_SECTION_NAME: $V_SECTION_NAME"
  msgd "V_TASKS_IN_SECTION: $V_TASKS_IN_SECTION"
  msgd "V_TASK_RESULT: $V_TASK_RESULT"

  if [ ! -n "$V_TASK_RESULT" ]; then
    msgd "OK, empty V_TASK_RESULT so this is the beginning of the section. Reseting the counter." 
    #echo
    V_TASK_COUNT=0
    V_TASK_FAILED=0
    V_TASK_FAILED_MSG=''
  else
    V_TASK_COUNT=$[V_TASK_COUNT + 1]
    # check the task result, if it failed increase the result counter
    if [ "$V_TASK_RESULT" -eq 1 ]; then
      V_TASK_FAILED=$[V_TASK_FAILED + 1]
      V_TASK_FAILED_MSG="Failed: $V_TASK_FAILED"
    fi
  fi

  echo -ne "$V_SECTION_NAME $V_TASK_COUNT / $V_TASKS_IN_SECTION $V_TASK_FAILED_MSG"\\r
  msgd "LOG: $LOG"
  exec 3>&1 4>&2 1>>$LOG 2>&1

  # Prepare summary for wiki
  if [ "$V_TASK_COUNT" -eq "$V_TASKS_IN_SECTION" ]; then
    if [ "$V_TASK_FAILED" -gt 0 ]; then
      echo "| [[#${V_SECTION_NAME}]] | $V_TASK_COUNT / $V_TASKS_IN_SECTION | [[#${V_SECTION_NAME}|{{wiki:danger.png}}]] $V_TASK_FAILED_MSG |" >> $F_WIKI_SUMMARY
    else 
      echo "| [[#${V_SECTION_NAME}]] | $V_TASK_COUNT / $V_TASKS_IN_SECTION | [[#${V_SECTION_NAME}|{{wiki:success.png}}]] |" >> $F_WIKI_SUMMARY
    fi
  fi


  msgd "${FUNCNAME[0]} End."
} #f_section_progress


# Actual run
# Loop through the initial_checks dir, executes the tasks and compares it to expected results
D_BASE=~/scripto/ebs/LT_monitoring
D_INITIAL_CHECKS=$D_BASE/R12_checks

check_directory $D_INITIAL_CHECKS
CN=`cat ~/.LT_SID`
msgd "Running tests on: $CN"

msgd "Determining $CN availability"
CN=`cat ~/.LT_SID`  
msgd "CN: $CN"

tnsping ${CN} > /tmp/run_initial_checks_tnsping.txt
if [ $? -eq 0 ]; then
  msgd "OK, tnsping works"
else
  msge "Error, tnsping $CN does not work. Exiting"
  run_command_d "cat /tmp/run_initial_checks_tnsping.txt"
  exit 1
fi

msgd "Determining DB username and password"
V_USER=apps
msgd "V_USER: $V_USER"
  msgd "Getting password from hash"
 
  PWD_FILE=~/.passwords
  INDEX_HASH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbRrdoraIndexHash']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
  msgd "INDEX_HASH: $INDEX_HASH"
  if [ -z "$INDEX_HASH" ]; then
    msgd "INDEX_HASH is empty, what means we do not have password stored in password file"
    echo -n "[wait] Provide the password for user $V_USER: "
    read -s V_PASS
    echo
    if [ -z "$V_PASS" ]; then 
      msge "Empty password provided. Exiting."
      exit 1
    fi
  else 
    HASH=`echo "$INDEX_HASH" | base64 --decode -i`
    msgd "HASH: $HASH"
    if [ -f "$PWD_FILE" ]; then
      V_PASS=`cat $PWD_FILE | grep $HASH | awk '{print $2}' | base64 --decode -i`
      #msgd "V_PASS: $V_PASS"
    else
      msge "Unable to find the password file. Exiting"
      exit 0
    fi
  fi

  msgd "OK, I have username, password and the database, it is time to test the connection"
  testavail=`sqlplus -S /nolog <<EOF
set head off pagesize 0 echo off verify off feedback off heading off
connect $V_USER/$V_PASS@$CN
select trim(1) result from dual;
exit;
EOF`

  if [ "$testavail" != "1" ]; then
    msge "DB $CN not available, exiting !!"
    exit 0
  fi

#WIP


echo "====== Checking: $CN on: `date`======" >> $F_WIKI_SUMMARY
echo '~~NOTOC~~' >> $F_WIKI_SUMMARY

#for F_IC in `ls -1t ${D_INITIAL_CHECKS}`
for F_IC in `ls ${D_INITIAL_CHECKS} | grep -v "99_attic"`
do

  #F_IC=02_MV_refreshed_fast
  #F_IC=06_init_settings
  #F_IC=07_result_cache
  #F_IC=09_profile_options
  #F_IC=08_FND_CONCURRENT_REQUESTS
  #F_IC=09_cache_size_2_processes
  #F_IC=10d_prevent_SGA_dynamic_resize
  #F_IC=14_custom_indexes
  #F_IC=15_SQL_performance
  #F_IC=13_invalids

  #echo "Section: $F_IC"
  LOG="$LOG_DIR/$F_IC"
  msgd "LOG: $LOG"
  exec 3>&1 4>&2 1>>$LOG 2>&1
  echo "===== $F_IC ====="

  V_NR_CHECKS_IN_SECTION=`find ${D_INITIAL_CHECKS}/${F_IC} -type f | grep -v '.svn' | grep -v '.swp' | wc -l`
  msgd "Section dir: ${D_INITIAL_CHECKS}/${F_IC}"

  f_section_progress "$F_IC" "$V_NR_CHECKS_IN_SECTION"


  for F_ICF in `ls ${D_INITIAL_CHECKS}/${F_IC}`
  do

    msgd "Sub check: $F_ICF"

    IC_ACTION=`head -1 ${D_INITIAL_CHECKS}/${F_IC}/${F_ICF}`
    msgd "IC_ACTION: $IC_ACTION"
    case $IC_ACTION in
    "execute_sql")
      msgd "execute_sql"
      f_LT_execute_sql ${D_INITIAL_CHECKS}/${F_IC}/${F_ICF}

      # report current progress  
      f_section_progress "$F_IC" "$V_NR_CHECKS_IN_SECTION" "$?"
      ;;
    "ignore")
      msgd "ignore"
      ;;
    *)
      echo "Unknown action!!! Exiting."
      exit 1
      ;;
    esac
  done

#exit 0
  # Done with one section
  exec 1>&3 2>&4
  echo >&2
  
done
echo

# CN in lowercase
CN_LC=`echo ${CN} | tr '[A-Z]' '[a-z]'`

echo "Check $LOG_DIR for details."
echo "or check wiki"
echo "http://3.62.80.7/dokuwiki/doku.php?id=run_checks_log_${CN_LC}"

# Prepare the last run wiki paga
F_WIKI_PAGE="/var/www/html/dokuwiki/data/pages/run_checks_log_${CN_LC}.txt"

# Clean the last run page
echo "" > $F_WIKI_PAGE

for FILE in `ls ${LOG_DIR}`
do
  cat ${LOG_DIR}/$FILE >> $F_WIKI_PAGE
done


read -p "[wait] Do you want to store the results in wiki? (yes/any)" V_ANSWER
if [ "$V_ANSWER" = "yes" ]; then
  # Create link on main page
  echo "[[run_checks_log_${V_DATE}]]\\\\" >> /var/www/html/dokuwiki/data/pages/lt_checks_${CN_LC}.txt

  # Copy the last run page to permanent one
  cp $F_WIKI_PAGE "/var/www/html/dokuwiki/data/pages/run_checks_log_${V_DATE}.txt"
  echo "Stored permanently under"
  echo "http://3.62.80.7/dokuwiki/doku.php?id=run_checks_log_${V_DATE}"
else
  echo "Not storing the results permanently, you can check it anyway on the last run page"

fi


