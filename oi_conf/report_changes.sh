#!/bin/bash
# 
# Report what has changed in CVS
# 

INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

CVS_DIR=/home/orainf/conf_repo
RECIPIENTS=remigiusz.boguszewicz@gmail.com

V_MODE=$1
msgd "V_MODE: $V_MODE"
check_parameter $V_MODE

# Compute start day as one week before today
CURRENT_DATE=`date -I`
START_DATE=$(date -I -d "$(date -d $CURRENT_DATE +%Y)-$(date -d $CURRENT_DATE +%m)-$(expr $(date -d $CURRENT_DATE +%d) - 7)")

# Today
END_DATE=`date -I`

case $V_MODE in
  "dbinit.txt")
    echo "Provide diff for $V_MODE"
    ;;
  "all")
    echo "Generating raport from $START_DATE to $END_DATE"
    cd $CVS_DIR
    #cvs diff -a -b -B -D $START_DATE -D $END_DATE | grep -v "cvs server: Diffing" | grep -v "retrieving revision" | grep -v "^diff -a -b -B" | mail -s "Orifm weekly changes report" $RECIPIENTS
    cvs diff -a -b -B -D $START_DATE -D $END_DATE | grep -v "cvs server: Diffing" | grep -v "retrieving revision" | grep -v "^diff -a -b -B" 
    ;;
  *)
    echo "Unknown mode! Exiting."
    exit 1
    ;;
esac


