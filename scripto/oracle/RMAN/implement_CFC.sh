#!/bin/bash
# Load usefull functions
if [ ! -f ${HOME}/scripto/bash/bash_library.sh ]; then
  echo "[error] ${HOME}/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${HOME}/scripto/bash/bash_library.sh
fi

B_PAR=$1 # Check if script was run with parameter

# Set random time of check start to avoid running everything on the same time
RND_MM=`random_int "0" "60"`
RND_HH=`random_int "8" "19"`

msgi "Checking if we are consiously excluding this host from RMAN corruption checking"
if [ -f /var/tmp/RMAN_exclude_from_corruption_checking ]; then
  msgi "This host has file /var/tmp/RMAN_exclude_from_corruption_checking and is excluded from RMAN corruption checking"
  exit 0
else
  msgi "No flag /var/tmp/RMAN_exclude_from_corruption_checking found, continuing checking"
fi

msgi "Checking if check_for_corruption.sh has alread been implemented"
MSG=`crontab -l | grep -v "^#" | grep "check_for_corruption.sh"`
if [ ! -z "$MSG" ]; then
  msgi "check_for_corruption.sh has already been implemented. OK. Refreshing it. "
else
  msge "check_for_corruption.sh has NOT been implemented. It should."
  msge "this can be fixed by: $ cd ~/scripto/oracle/RMAN; ./implement_CFC.sh"
fi

# If script was run with CHECK parameter I exit now, before any permanent actions are done
if [ "$B_PAR" = "CHECK" ]; then
  exit 0
fi

msga "This script will implement the check_for_corruption.sh procedure to be run on host"
run_command "cd $HOME/scripto/crontabs"
run_command "crontab -l > crontab_${USER}_${HOSTNAME}"
run_command "cvs commit -m 'Before check_for_corruption.sh implementation' crontab_${USER}_${HOSTNAME}"
msga "Removing the current line with check_for_corruption.sh from crontab if exists"
crontab -l | grep -v 'check_for_corruption.sh' > crontab_${USER}_${HOSTNAME}
msga "Adding line with check_for_corruption.sh to crontab_${USER}_${HOSTNAME}"
echo "$RND_MM $RND_HH * * 0 (. \$HOME/.profile; cd \$HOME/scripto/oracle/RMAN; ./check_for_corruption.sh )" >> crontab_${USER}_${HOSTNAME}
run_command "cvs commit -m 'check_for_corruption.sh implementation' crontab_${USER}_${HOSTNAME}"
run_command "crontab crontab_${USER}_${HOSTNAME}"
run_command "crontab -l"

