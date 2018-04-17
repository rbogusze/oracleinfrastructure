#!/bin/bash
#$Id$
#

# Load usefull functions
V_INTERACTIVE=1

V_DIR=$1

check_parameter()
{
  check_variable "$1" "$2"
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



echo "What I want to delete"
find 



