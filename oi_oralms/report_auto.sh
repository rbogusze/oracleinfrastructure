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
  msgd "V_DATE: $V_DATE"
  V_HOUR=`date '+%Y-%m-%d--%H'`
  msgd "V_HOUR: $V_HOUR"
  
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


f_say_how_much_of_event_happened_for_CN()
{
  msgd "${FUNCNAME[0]} Begin."
  V_CN=$1
  msgd "V_CN: $V_CN"
  F_STAT=$2
  msgd "F_STAT: $F_STAT"
  check_file $F_STAT
  V_VALUE=`cat $F_STAT | grep "$V_CN " | awk '{print $2}'`
  printf "%-10s" "$V_VALUE"

  msgd "${FUNCNAME[0]} End."
} #f_report_stats_from_dir


# ---- new now
# this is just reporting on what happened in the last hour, so it is easy to do the counting now
V_TRIG_SUMM=/tmp/triggers_summary
mkdir -p $V_TRIG_SUMM
check_directory $V_TRIG_SUMM
for V_DIR in `ls /tmp/triggers`
do
  msgd "V_DIR: $V_DIR"
  f_report_stats_from_dir "/tmp/triggers/$V_DIR" > $V_TRIG_SUMM/$V_DIR
done

# Get the list of CN that monitor alert log
$HOME/scripto/perl/ask_ldap.pl "(orainfDbAlertLogMonitoring=TRUE)" "['cn']" > /tmp/oralms_report.txt
#run_command_d "cat /tmp/oralms_report.txt"

# Get the stats for every CN - construct header
echo "------------------------------------------------------------------------------------"
echo "        /h | Redo switches | Ses. Killed | mttr too low | TNS12535 | Glob Deadlock |"

printf "%-12s" " "
for V_TARGET in `ls $V_TRIG_SUMM`
do
  printf "%-10s" "$V_TARGET"
done
echo
  

# Get the stats for every CN - actual stats
while read LINE
do
  #msgd "LINE: $LINE"
  printf "%-12s" "$LINE"
  # now I have the system name, I want to see all the info I can get for that target
  for V_TARGET in `ls $V_TRIG_SUMM`
  do
    msgd "LINE: $LINE"
    msgd "V_TARGET: $V_TARGET"
    f_say_how_much_of_event_happened_for_CN "$LINE" "$V_TRIG_SUMM/$V_TARGET" 
  done

  echo ""
done < /tmp/oralms_report.txt

echo "------------------------------------------------------------------------------------"

exit 0

# ---- old below
msgd "Global Enqueue Services Deadlock detected"
f_report_stats_from_dir "/tmp/oralms_global_deadlock" > /tmp/oralms_global_deadlock.txt
run_command_d "cat /tmp/oralms_global_deadlock.txt"



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

