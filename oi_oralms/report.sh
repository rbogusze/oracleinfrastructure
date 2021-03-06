#!/bin/bash
# This script should be run from crontab and regulari report about some DB statistics like redo switches and sessions killed

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

f_report_stats_from_dir()
{
  msgd "${FUNCNAME[0]} Begin."
  TMP_LOG_DIR=$1
  V_DATE=`date -I`
  V_HOUR=`date '+%Y-%m-%d--%H'`
  
  if [ ! -d $TMP_LOG_DIR ]; then
    msgd "No dir. Continue"
    return 0
  fi

  for FILE in `ls $TMP_LOG_DIR | grep $V_DATE`
  do
    msgd "FILE: $FILE"
    V_COUNT=`cat $TMP_LOG_DIR/$FILE | grep $V_HOUR | wc -l`
    msgd "V_COUNT: $V_COUNT"
    V_SHORT_FILE=`echo $FILE | awk -F"_" '{print $1}'`
    msgd "V_SHORT_FILE: $V_SHORT_FILE"
    #echo "$V_SHORT_FILE | $V_COUNT" 

    printf "%-10s" "$V_SHORT_FILE"
    echo " $V_COUNT" 
#exit 0

  done


  msgd "${FUNCNAME[0]} End."
} #f_report_stats_from_dir


# Actual run
msgd "Compute Hourly redo switches"
f_report_stats_from_dir "/tmp/oralms_redo" > /tmp/oralms_redo.txt
run_command_d "cat /tmp/oralms_redo.txt"

msgd "Compute Hourly killed sessions"
f_report_stats_from_dir "/tmp/oralms_sess_killed" > /tmp/oralms_sess_killed.txt
run_command_d "cat /tmp/oralms_sess_killed.txt"

msgd "Compute Hourly fast_start_mttr_target 480 is set too low messages"
f_report_stats_from_dir "/tmp/oralms_mttr" > /tmp/oralms_mttr.txt
run_command_d "cat /tmp/oralms_mttr.txt"

msgd "TNS-12535: TNS:operation timed out"
f_report_stats_from_dir "/tmp/oralms_tns12535" > /tmp/oralms_tns12535.txt
run_command_d "cat /tmp/oralms_tns12535.txt"

msgd "Global Enqueue Services Deadlock detected"
f_report_stats_from_dir "/tmp/oralms_global_deadlock" > /tmp/oralms_global_deadlock.txt
run_command_d "cat /tmp/oralms_global_deadlock.txt"


# Get the list of CN that monitor alert log
$HOME/scripto/perl/ask_ldap.pl "(orainfDbAlertLogMonitoring=TRUE)" "['cn']" > /tmp/oralms_report.txt
run_command_d "cat /tmp/oralms_report.txt"

# Get the stats for every report I want to include
echo "------------------------------------------------------------------------------------"
echo "        /h | Redo switches | Ses. Killed | mttr too low | TNS12535 | Glob Deadlock |"
while read LINE
do
  #echo $LINE
  V_REDO=`cat /tmp/oralms_redo.txt | grep "$LINE " | awk '{print $2}'`
  msgd "V_REDO: $V_REDO"

  V_KILL=`cat /tmp/oralms_sess_killed.txt | grep "$LINE " | awk '{print $2}'`
  msgd "V_KILL: $V_KILL"

  V_MTTR=`cat /tmp/oralms_mttr.txt | grep "$LINE " | awk '{print $2}'`
  msgd "V_MTTR: $V_MTTR"

  V_TNS12535=`cat /tmp/oralms_tns12535.txt | grep "$LINE " | awk '{print $2}'`
  msgd "V_TNS12535: $V_TNS12535"

  V_GLOBAL_DEADLOCK=`cat /tmp/oralms_global_deadlock.txt | grep "$LINE " | awk '{print $2}'`
  msgd "V_GLOBAL_DEADLOCK: $V_GLOBAL_DEADLOCK"

  #echo "$LINE $V_REDO $V_KILL"
  #printf "%-10s" "$LINE"
  #echo "$V_REDO $V_KILL"
  #echo "---------"
  #printf "%-10s | %-13s | %-10s" "$LINE" "$V_REDO" "$V_KILL"
  printf "%-10s | %-13s | %-10s  | %-12s | %-8s | %-13s |" "$LINE" "$V_REDO" "$V_KILL" "$V_MTTR" "$V_TNS12535" "$V_GLOBAL_DEADLOCK"
  echo ""
done < /tmp/oralms_report.txt

echo "------------------------------------------------------------------------------------"






