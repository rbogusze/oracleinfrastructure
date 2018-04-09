#!/bin/bash
#$Id$
#
# Generate the statspack and hash reports for the long range of days
#
# Example
# $ ./01_bulk_generate.sh EBSDB4 apps 08:00 16:00 8
# Optionaly add at the end date from which to start
# $ ./01_bulk_generate.sh EBSDB4 apps 08:00 16:00 8 2015-08-12
#
#
# Load usefull functions
V_INTERACTIVE=1

check_parameter()
{
  check_variable "$1" "$2"
}

check_variable()
{
  if [ -z "$1" ]; then
    error_log "[ check_variable ] Provided variable ${2} is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi
}

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

msgd()
{
  if [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[32m'; fi
    echo -n "[debug]    "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[39m\E[49m'; fi
    echo "$1"
  fi
}

msgi()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[32m'; fi
    echo -n "[info]     "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[39m\E[49m'; fi
    echo "$1"
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


INFO_MODE=DEBUG

# Sanity checks
check_parameter $1
check_parameter $2
check_parameter $3
check_parameter $4
check_parameter $5

F_SNAP_FILE=$1
USERNAME=$2
TIME_START=$3
TIME_END=$4
NR_DAYS_BACK=$5
DATE_START=$6

check_file $F_SNAP_FILE

myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  CHECK_FOR_DATE=`date -I -d "$DATE_START $myvar day ago"`
  msgi "#################################################################"
  msgi "Computing fo date: ${CHECK_FOR_DATE}"
  msgi "#################################################################"

  # If this is Sunday or Saturday skip that day
  DAY_OF_WEEK=`date --date=$CHECK_FOR_DATE '+%u'`
  if [ "$DAY_OF_WEEK" == "7" ] || [ "$DAY_OF_WEEK" == "6" ]; then
    echo "This is Sunday or Saturday, skiping statspack report generation"
  else
    echo "Checking file with snaps for date and time"
    cat $F_SNAP_FILE | grep ${CHECK_FOR_DATE}

exit 0


    echo "./awr_reports.sh ${CHECK_FOR_DATE} ${TIME_START} ${TIME_END}"
  fi #if [ "$DAY_OF_WEEK" == "0" ];

  myvar=$(( $myvar + 1 ))
done

echo "Done."

