#!/bin/bash
# 

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

D_CONF_REPO=$HOME/conf_repo
D_BETWEEN=$HOME/conf_repo/between_DBs

#################### init.ora ############################
F_BETWEEN_INIT=init.ora

msgd "Cleanup for $F_BETWEEN_INIT"
run_command_e "cd $D_BETWEEN"
run_command_e "rm -f $F_BETWEEN_INIT"
cvs remove $F_BETWEEN_INIT
cvs commit -m "removing $V_CN" $F_BETWEEN_INIT
msgd "To have fresh numbers and no history I need to delete the file from repository"
run_command "rm -f /home/cvs/conf_repo/between_DBs/Attic/init.ora,v"

msgi "Look for init files and copy all of them into one file with versioning"
for i in `find ${D_CONF_REPO} | grep "init.*.ora" | grep -v "between_DBs"`
do
  echo $i
  msgd "Figure out the CN from the path"
  V_CN=`echo $i | awk -F'/' '{print $(NF-1)}'`
  msgd "V_CN: $V_CN"


  msgd "Copy DB init into between init , commit with CN message"  
  run_command_e "cd $D_BETWEEN"
  run_command "echo $V_CN > $F_BETWEEN_INIT"
  run_command "cat $i | grep -v '^#' | sed 's/^\*\.//' | grep -v '^utl_file_dir' | grep -v 'control_files' | grep -v 'dispatchers' | grep -v 'service_names' | grep -v 'remote_listener' | grep -v 'instance_name' | grep -v 'instance_number' | grep -v '_ncomp_shared_objects_dir' | grep -v 'thread=' | grep -v 'undo_tablespace=' | grep -v 'log_archive_dest=' | sort >> $F_BETWEEN_INIT"
  cvs add $F_BETWEEN_INIT
  cvs commit -m "from $V_CN" $F_BETWEEN_INIT

done


#################### SPM.txt ############################
F_BETWEEN_INIT=SPM.txt

msgd "Cleanup for $F_BETWEEN_INIT"
run_command_e "cd $D_BETWEEN"
run_command_e "rm -f $F_BETWEEN_INIT"
cvs remove $F_BETWEEN_INIT
cvs commit -m "removing $V_CN" $F_BETWEEN_INIT
msgd "To have fresh numbers and no history I need to delete the file from repository"
run_command "rm -f /home/cvs/conf_repo/between_DBs/Attic/${F_BETWEEN_INIT},v"

msgi "Look for init files and copy all of them into one file with versioning"
for i in `find ${D_CONF_REPO} | grep "${F_BETWEEN_INIT}" | grep -v "between_DBs"`
do
  echo $i
  msgd "Figure out the CN from the path"
  V_CN=`echo $i | awk -F'/' '{print $(NF-1)}'`
  msgd "V_CN: $V_CN"


  msgd "Copy DB init into between init , commit with CN message"  
  run_command_e "cd $D_BETWEEN"
  run_command "echo $V_CN > $F_BETWEEN_INIT"
  run_command "cat $i | sort >> $F_BETWEEN_INIT"
  cvs add $F_BETWEEN_INIT
  cvs commit -m "from $V_CN" $F_BETWEEN_INIT

done


#################### AD_BUGS.txt ############################
F_BETWEEN_INIT=AD_BUGS.txt

msgd "Cleanup for $F_BETWEEN_INIT"
run_command_e "cd $D_BETWEEN"
run_command_e "rm -f $F_BETWEEN_INIT"
cvs remove $F_BETWEEN_INIT
cvs commit -m "removing $V_CN" $F_BETWEEN_INIT
msgd "To have fresh numbers and no history I need to delete the file from repository"
run_command "rm -f /home/cvs/conf_repo/between_DBs/Attic/${F_BETWEEN_INIT},v"

msgi "Look for init files and copy all of them into one file with versioning"
for i in `find ${D_CONF_REPO} | grep "${F_BETWEEN_INIT}" | grep -v "between_DBs"`
do
  echo $i
  msgd "Figure out the CN from the path"
  V_CN=`echo $i | awk -F'/' '{print $(NF-1)}'`
  msgd "V_CN: $V_CN"


  msgd "Copy DB init into between init , commit with CN message"  
  run_command_e "cd $D_BETWEEN"
  run_command "echo $V_CN > $F_BETWEEN_INIT"
  run_command "cat $i | sort >> $F_BETWEEN_INIT"
  cvs add $F_BETWEEN_INIT
  cvs commit -m "from $V_CN" $F_BETWEEN_INIT

done


