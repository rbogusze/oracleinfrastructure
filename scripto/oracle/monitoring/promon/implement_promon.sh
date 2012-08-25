#!/bin/bash
# Load usefull functions
if [ ! -f ${HOME}/scripto/bash/bash_library.sh ]; then
  echo "[error] ${HOME}/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${HOME}/scripto/bash/bash_library.sh
fi

RECIPIENTS='Remigiusz_Boguszewicz'

check_directory "$HOME/scripto/oracle/create_db_scripts"
cd $HOME/scripto/oracle/create_db_scripts
cvs update -d

check_directory "$HOME/scripto/oracle"
cd $HOME/scripto/oracle
cvs update -d monitoring

check_directory "$HOME/scripto/oracle"
cd $HOME/scripto/oracle
cvs update -d RMAN

check_directory "$HOME/scripto"
cd $HOME/scripto
cvs update -d solaris

check_directory "$HOME/scripto/oracle/monitoring/promon"
cd $HOME/scripto/oracle/monitoring/promon

# Set random time of check start to avoid running everything on the same time
RND_MM=`random_int "0" "60"`
RND_HH=`random_int "14" "19"`

msgi "Checking if promon.sh has alread been implemented"
MSG=`crontab -l | grep -v '^#.*$' | grep "promon.sh"`
if [ ! -z "$MSG" ]; then
  msgi "promon.sh has already been implemented. OK."
else
  msge "promon.sh has NOT been implemented. It should."
  msga "This script will implement the promon.sh procedure to be run on host"
  run_command "cd $HOME/scripto/crontabs"
  run_command "crontab -l > crontab_${USER}_${HOSTNAME}"
  run_command "cvs commit -m 'Before promon.sh implementation' crontab_${USER}_${HOSTNAME}"
  #msga "Removing the current line with promon.sh from crontab if exists"
  #crontab -l | grep -v 'promon.sh' > crontab_${USER}_${HOSTNAME}
  msga "Adding line with promon.sh to crontab_${USER}_${HOSTNAME}"
  echo "$RND_MM $RND_HH * * * (. \$HOME/.profile; cd \$HOME/scripto/oracle/monitoring/promon; ./promon.sh > /dev/null)" >> crontab_${USER}_${HOSTNAME}
  run_command "cvs commit -m 'promon.sh implementation' crontab_${USER}_${HOSTNAME}"
  run_command "crontab crontab_${USER}_${HOSTNAME}"
  run_command "crontab -l"
fi

msga "Running promon NOW on ${USER}@${HOSTNAME}"
cd $HOME/scripto/oracle/monitoring/promon
./promon.sh
