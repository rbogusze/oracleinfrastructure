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
TMP_LOG_DIR=/tmp/oi_conf


f_do_it()      
{                                 
  msgd "${FUNCNAME[0]} Begin."    
  F_BETWEEN_INIT=$1
  V_FIND_SEARCH=$2
  V_GREP_COND=$3

  msgd "F_BETWEEN_INIT: $F_BETWEEN_INIT"
  check_parameter $F_BETWEEN_INIT
  msgd "V_FIND_SEARCH: $V_FIND_SEARCH"
  check_parameter $V_FIND_SEARCH
  msgd "V_GREP_COND: $V_GREP_COND"
  check_parameter $V_GREP_COND


  msgd "Cleanup for $F_BETWEEN_INIT"
  run_command_e "cd $D_BETWEEN"

  V_VER_FILES=`ls -1 ${F_BETWEEN_INIT}* | tr "\n" " " `
  msgd "V_VER_FILES: $V_VER_FILES"

  run_command_e "rm -f $V_VER_FILES"
  cvs remove $V_VER_FILES
  cvs commit -m "removing $V_CN" $V_VER_FILES
  msgd "To have fresh numbers and no history I need to delete the file from repository"
  run_command "rm -f /home/cvs/conf_repo/between_DBs/Attic/${F_BETWEEN_INIT}_*,v"


  msgi "Look for init files and copy all of them into one file with versioning"
  for i in `find ${D_CONF_REPO} | grep "${V_FIND_SEARCH}" | grep -v "between_DBs"`
  do
    echo $i

    msgd "Figure out the CN from the path"
    V_CN=`echo $i | awk -F'/' '{print $(NF-1)}'`
    msgd "V_CN: $V_CN"

    msgd "Get the appilcation version that will enable us to compare apples with apples and oranges with oranges"
    V_APP_VER=`cat $TMP_LOG_DIR/$V_CN`
    msgd "V_APP_VER: $V_APP_VER"


    msgd "Copy DB init into between init , commit with CN message"  
    run_command_e "cd $D_BETWEEN"
    run_command "echo $V_CN > ${F_BETWEEN_INIT}_${V_APP_VER}"
    run_command "cat $i $V_GREP_COND >> ${F_BETWEEN_INIT}_${V_APP_VER}"
    cvs add ${F_BETWEEN_INIT}_${V_APP_VER}
    cvs commit -m "from $V_CN" ${F_BETWEEN_INIT}_${V_APP_VER}

  done

  msgd "${FUNCNAME[0]} End."  
} #f_do_it

# Just do it
# - name of the file
# - search string for find
f_do_it init.ora "init.*.ora" "| grep -v '^#' | sed 's/^\*\.//' | grep -v '^utl_file_dir' | grep -v 'control_files' | grep -v 'dispatchers' | grep -v 'service_names' | grep -v 'remote_listener' | grep -v 'instance_name' | grep -v 'instance_number' | grep -v '_ncomp_shared_objects_dir' | grep -v 'thread=' | grep -v 'undo_tablespace=' | grep -v 'log_archive_dest=' | sort"


f_do_it SPM.txt SPM.txt "| sort"
f_do_it AD_BUGS.txt AD_BUGS.txt "| sort"



