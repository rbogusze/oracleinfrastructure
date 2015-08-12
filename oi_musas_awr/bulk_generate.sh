#!/bin/bash
#$Id$
#
# Generate the statspack and hash reports for the long range of days
#
# Example
# $ ./bulk_generate.sh 08:00 16:00 8
# $ ./bulk_generate.sh EBSDB4 apps 08:00 16:00 8
#
#
# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG

# Sanity checks
check_parameter $1
check_parameter $2
check_parameter $3
check_parameter $4
check_parameter $5

DB_CN=$1
USERNAME=$2
TIME_START=$3
TIME_END=$4
NR_DAYS_BACK=$5

myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  CHECK_FOR_DATE=`date -I -d "$myvar day ago"`
  msgi "#################################################################"
  msgi "Computing fo date: ${CHECK_FOR_DATE}"
  msgi "#################################################################"

  # If this is Sunday or Saturday skip that day
  DAY_OF_WEEK=`date --date=$CHECK_FOR_DATE '+%u'`
  if [ "$DAY_OF_WEEK" == "7" ] || [ "$DAY_OF_WEEK" == "6" ]; then
    echo "This is Sunday or Saturday, skiping statspack report generation"
  else
    run_command "./awr_reports.sh ${DB_CN} ${USERNAME} ${CHECK_FOR_DATE} ${TIME_START} ${TIME_END}"
  fi #if [ "$DAY_OF_WEEK" == "0" ];

  myvar=$(( $myvar + 1 ))
done

echo "Done."

