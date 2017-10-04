#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

msgd "Killing my previous spawned processes"
echo "Please wait untill I kill all the spawned processes"
cd $LOCKFILE_SPAN_DIR
for i in `ls -1 ${LOCKFILE_SPAN}_*.lock`; do
  echo "i: $i"
  # get proccess PID
  PID=`echo $i | awk -F _ '{ print $3 }'`
  echo "Killing PID : ${PID}"
  kill ${PID}
  echo "Removing lock file: $i"
  rm -f $i
done
echo "Done."
