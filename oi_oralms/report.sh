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
  
  check_directory $TMP_LOG_DIR

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
echo "--------------------------------------------"
echo "Hourly redo switches"
f_report_stats_from_dir "/tmp/oralms_redo"

echo ""

echo "Hourly killed sessions"
f_report_stats_from_dir "/tmp/oralms_sess_killed"

echo "--------------------------------------------"
