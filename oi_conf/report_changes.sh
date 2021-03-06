#!/bin/bash
# 
# Report what has changed in CVS
# 

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

CVS_DIR=/home/orainf/conf_repo
RECIPIENTS=remigiusz.boguszewicz@gmail.com
D_TMP=/tmp/report_changes
F_TMP=$D_TMP/files

mkdir -p $D_TMP
check_directory $D_TMP

V_MODE=$1
msgd "V_MODE: $V_MODE"
check_parameter $V_MODE

# Compute start day as one week before today
CURRENT_DATE=`date -I`
DELTA_DAYS=7
START_DATE=`date -I -d "$CURRENT_DATE $DELTA_DAYS day ago"`
msgd "START_DATE: $START_DATE"

# Today, end date has to be in the future, then I do not have to mess with exact hours of when the change happened
#END_DATE=`date -I`
END_DATE=`date -I -d "$CURRENT_DATE -1 day ago"`
msgd "END_DATE: $END_DATE"

msgi "Provide diff for $V_MODE"
msgd "Go through the CVS_DIR and search for $V_MODE files"
find $CVS_DIR -name $V_MODE > $F_TMP
check_file $F_TMP
run_command_d "cat $F_TMP"
msgd "Loop through provided files list and give cvs diff"
while read LINE
do
  msgd "LINE: $LINE"
  D_CVS_FILE=`dirname $LINE`
  msgd "D_CVS_FILE: $D_CVS_FILE"
  #run_command "cd $D_CVS_FILE"
  cd $D_CVS_FILE
  F_CVS_FILE=`basename $LINE`
  msgd "F_CVS_FILE: $F_CVS_FILE"
  cvs diff -a -b -B -D $START_DATE -D $END_DATE $F_CVS_FILE | grep -v "cvs server: Diffing" | grep -v "retrieving revision" | grep -v "^diff -a -b -B" 

#exit 0
done < $F_TMP



