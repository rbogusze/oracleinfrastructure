#!/bin/bash
#$Id: bulk_generate.sh,v 1.3 2011/07/27 13:30:20 remikcvs Exp $
#
# Generate the statspack and hash reports for the long range of days
#
# Example
# $ ./bulk_generate.sh HAL_POZNAN perfhal 08:17 22:17 30
#
# Assumptions:
# - we are taking snapshots from the same day
#
# Load usefull functions

if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

RECIPIENTS='Remigiusz_Boguszewicz'
INFO_MODE=DEBUG

# Sanity checks
check_parameter $1
check_parameter $2
check_parameter $3
check_parameter $4
check_parameter $5

SERVICE_NAME=$1
USER_PASSWORD=$2
TIME_START=$3
TIME_END=$4
NR_DAYS_BACK=$5

myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  CHECK_FOR_DATE=`date -I -d "$myvar day ago"`

  msgd "Computing fo date: ${CHECK_FOR_DATE}"

  # If this is Sunday or Saturday skip that day
  DAY_OF_WEEK=`date --date=$CHECK_FOR_DATE '+%u'`
  if [ "$DAY_OF_WEEK" == "7" ] || [ "$DAY_OF_WEEK" == "6" ]; then
    echo "This is Sunday or Saturday, skiping statspack report generation"
  else
    # run report with computed date
    msgd "Run report with: " ${SERVICE_NAME} ${USER_PASSWORD} ${CHECK_FOR_DATE}--${TIME_START} ${CHECK_FOR_DATE}--${TIME_END}
    run_command "./get_statspack.sh ${SERVICE_NAME} ${USER_PASSWORD} ${CHECK_FOR_DATE}--${TIME_START} ${CHECK_FOR_DATE}--${TIME_END}"
  fi #if [ "$DAY_OF_WEEK" == "0" ];

  myvar=$(( $myvar + 1 ))
done

echo "Done."

