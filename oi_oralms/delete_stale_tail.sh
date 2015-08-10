#!/bin/bash
# $Header: /home/remik/cvs_root_kgp/oralms/oralms_view.sh,v 1.2 2012-05-25 11:52:39 orainf Exp $

#set -x

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

D_ORALMS=/tmp/oralms/
F_LIMIT=/tmp/oralms_limit.tmp

# store file reference with timestamp older than 1h
touch -d '-3 hour' $F_LIMIT

# loop through the tail directory
for F_TAIL in `ls ${D_ORALMS}`
do
  msgd "################## $F_TAIL #################"
  if [ ${F_LIMIT} -nt ${D_ORALMS}/${F_TAIL} ]; then
    msgd "tail file has not been touched in the last 3h"
    # checking if ssh session exists
    # get the hostname from the F_TAIL
    V_HOSTNAME=`echo ${F_TAIL} | awk -F"_" '{print $2}'`
    msgd "V_HOSTNAME: $V_HOSTNAME"

    if [ -z "$V_HOSTNAME" ]; then
      msge "Unable to extract hostname from filename. Something is wrong. Skiping this tail."
      continue
    fi

    V_KILL_PID=`ps -ef | grep ssh | grep "$V_HOSTNAME" | head -n 1 | awk '{print $2}'`
    msgd "V_KILL_PID: $V_KILL_PID"
    if [ -z "$V_KILL_PID" ]; then
      run_command "kill -9 $V_KILL_PID"
    else
      msgd "There is nothing to kill"
    fi    

  else
    msgd "tail file looks fresh"
  fi
  
done
