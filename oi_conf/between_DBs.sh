#!/bin/bash
# 

INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

D_CONF_REPO=$HOME/conf_repo
D_BETWEEN=$HOME/conf_repo/between_DBs
F_BETWEEN_INIT=init.ora

msgi "Look for init files and copy all of them into one file with versioning"
for i in `find ${D_CONF_REPO} | grep "init.*.ora" | grep -v "between_DBs"`
do
  echo $i
  msgd "Figure out the CN from the path"
  V_CN=`echo $i | awk -F'/' '{print $(NF-1)}'`
  msgd "V_CN: $V_CN"

  msgd "Copy DB init into between init , commit with CN message"  
  run_command_e "cd $D_BETWEEN"
  run_command "cat $i > $F_BETWEEN_INIT"
  cvs add $F_BETWEEN_INIT
  cvs commit -m "from $V_CN" $F_BETWEEN_INIT

#exit 0

done
