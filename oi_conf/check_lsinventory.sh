#!/bin/bash
# 
# Checks if patchlevel is different 
# 
# Now it just shows recent PSU installed

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

D_CONF=/home/orainf/conf_repo
D_LSINV=/tmp/lsinventory
F_LSINV=$D_LSINV/lsinventory.lst

mkdir -p $D_LSINV
check_directory $D_LSINV

msgd "Find opatch_lsinventory.txt files"
find $D_CONF -name opatch_lsinventory.txt > $F_LSINV
run_command_d "cat $F_LSINV"

msgd "Look and provide summary"
while read LINE
do
  msgd "$LINE"
  echo $LINE | awk -F'/' '{print $5}'
  check_file $LINE
  cat $LINE | grep 'Database Patch Set Update' | grep -v 'Sub-patch'
done < $F_LSINV
