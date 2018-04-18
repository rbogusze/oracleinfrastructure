#!/bin/bash
#$Id$
#
#  Usage: $ ./cleanup_rman_backup_manually.sh /u01/backup
#

# Load usefull functions
V_INTERACTIVE=1
RECIPIENTS=""
INFO_MODE="DEBUG"
RM_OLDER_THAN=14

V_DIR_TO_CLEANUP=$1

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

check_directory()
{
  if [ -z "$1" ]; then
    error_log "[ check_variable ] Provided variable is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi

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

error_log()
{
  echo "[ error ]["`hostname`"]""["$0"]" $1
  MSG=$1
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

#
#  Actual execution
#


check_parameter $V_DIR_TO_CLEANUP
check_directory $V_DIR_TO_CLEANUP

msgi "What I want to delete"
run_command_e "find $V_DIR_TO_CLEANUP -type f -mtime +$RM_OLDER_THAN -name "o1_mf*.bkp" -print"

msgi "Actual delete"
#run_command_e "find $V_DIR_TO_CLEANUP -type f -mtime +$RM_OLDER_THAN -name "o1_mf*.bkp" -print -exec rm -f {} \;"

msgi "Deleting directories that should be empty now"
#run_command_e "find $V_DIR_TO_CLEANUP -type d -mtime +$RM_OLDER_THAN -print -exec rmdir {} \;"

msgi "Done."

