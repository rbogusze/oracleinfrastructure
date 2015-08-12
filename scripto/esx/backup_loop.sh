#!/bin/bash
#$Id: backup_loop.sh,v 1.9 2013-05-13 11:27:11 remik Exp $
#
# Prepare the backup_list.txt file eg like this:
# on ESX
# # vim-cmd vmsvc/getallvms | awk '{print $2}' | sort | grep -v "^Name$"
#
#
# Assumptions:
# - ability to login passwordless to ESX host
#
# Sample usage: 
# $ ./backup_loop.sh
#
# *** Start of Configuration section ***
LOG_DIR=/var/tmp/backup_esx
LOG_NAME=backup.log
RECIPIENTS="remigiusz.boguszewicz@gmail.com"

# *** End of Configuration section ***
# Load usefull functions
if [ ! -f ~/scripto/bash/bash_library.sh ]; then
  echo "[error] ~/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ~/scripto/bash/bash_library.sh
fi

# Sanity checks
mkdir -p $LOG_DIR
check_directory $LOG_DIR

LOG=${LOG_DIR}/${LOG_NAME}.`date '+%Y-%m-%d--%H:%M:%S'`
#exec > $LOG 2>&1
F_SH_CMND=/tmp/backup_loop.tmp.F_SH_CMND

INFO_MODE=DEBUG
#INFO_MODE=INFO


D_BACKUP_LIST=~/scripto/esx/backup_list.txt
D_BACKUP_DIR=/SYNOLOGY_NFS

check_file $D_BACKUP_LIST

run_command_e "touch $D_BACKUP_DIR/testing_if_writable"
run_command "rm -f $D_BACKUP_DIR/testing_if_writable"

msgi "List of the ESX vms I will backup:"
while read VM_TO_BACKUP
do
  msgi "##########################"
  msgi "Backup routine for: $VM_TO_BACKUP"
  VM_TO_BACKUP_BCK_DIR=$D_BACKUP_DIR/${VM_TO_BACKUP}_`date -I`
  msgd "VM_TO_BACKUP_BCK_DIR: $VM_TO_BACKUP_BCK_DIR"
  VM_TO_BACKUP_BCK_NAME=${VM_TO_BACKUP}_`date -I`
  msgd "VM_TO_BACKUP_BCK_NAME: $VM_TO_BACKUP_BCK_NAME"
  
  cat > $F_SH_CMND << EOF
uname -a;
date;
esxcli vm process list
EOF
  run_command_d "cat $F_SH_CMND"

  f_run_sh_on_remote_host root esx $F_SH_CMND > /tmp/backup_loop.tmp.output
  run_command_d "cat /tmp/backup_loop.tmp.output"
  msgd "Searching for World ID:"
  VM_TO_BACKUP_WORLDID=`cat /tmp/backup_loop.tmp.output | grep -A 1 "$VM_TO_BACKUP" | grep 'World ID:' | awk -F":" '{print $2}' | tr -d ' ' `
  msgd "VM_TO_BACKUP_WORLDID: $VM_TO_BACKUP_WORLDID"

  msgi "Searching for VMID"
  cat > $F_SH_CMND << EOF
vim-cmd vmsvc/getallvms;
EOF
  f_run_sh_on_remote_host root esx $F_SH_CMND > /tmp/backup_loop.tmp.output
  run_command_d "cat /tmp/backup_loop.tmp.output"
  VM_TO_BACKUP_VMID=`cat /tmp/backup_loop.tmp.output | grep "$VM_TO_BACKUP" | awk '{print $1}' `
  msgd "VM_TO_BACKUP_VMID: $VM_TO_BACKUP_VMID"
  VM_TO_BACKUP_PATH=`cat /tmp/backup_loop.tmp.output | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' | grep "^${VM_TO_BACKUP}" | awk '{print $2"/" $3 }' | tr -d "[]" | awk '{print "/vmfs/volumes/" $0}'`
  VM_TO_BACKUP_PATH=`dirname $VM_TO_BACKUP_PATH`
  msgd "VM_TO_BACKUP_PATH: $VM_TO_BACKUP_PATH"
  check_parameter $VM_TO_BACKUP_PATH


  msgi "Get the current status of the vm"
  cat > $F_SH_CMND << EOF
vim-cmd vmsvc/power.getstate $VM_TO_BACKUP_VMID
EOF
  f_run_sh_on_remote_host root esx $F_SH_CMND > /tmp/backup_loop.tmp.output
  run_command_d "cat /tmp/backup_loop.tmp.output"
  VM_TO_BACKUP_STATUS=`cat /tmp/backup_loop.tmp.output | grep -v "Retrieved runtime info"`
  msgd "VM_TO_BACKUP_STATUS: $VM_TO_BACKUP_STATUS"


  msgi "Shutdown the VM if it is up"
  if [ "$VM_TO_BACKUP_STATUS" = "Powered on" ]; then
    msgi "VM is rinning, I will shut it down NOW."
    cat > $F_SH_CMND << EOF
esxcli vm process kill --type=soft --world-id=$VM_TO_BACKUP_WORLDID
EOF
    f_run_sh_on_remote_host root esx $F_SH_CMND > /tmp/backup_loop.tmp.output
    run_command_d "cat /tmp/backup_loop.tmp.output"
  else
    msgi "VM is not running."
  fi


  msgi "Doing the actuall backup"
  run_command_e "mkdir -p $VM_TO_BACKUP_BCK_DIR" 
  run_command_e "cd $VM_TO_BACKUP_BCK_DIR"
  run_command_e "pwd"
  run_command_e "scp -r root@esx:$VM_TO_BACKUP_PATH ."

  msgi "Starting the VM if it was up."
  if [ "$VM_TO_BACKUP_STATUS" = "Powered on" ]; then
    msgi "VM was rinning, I will start it up NOW."
    cat > $F_SH_CMND << EOF
vim-cmd vmsvc/power.on $VM_TO_BACKUP_VMID
EOF
    f_run_sh_on_remote_host root esx $F_SH_CMND > /tmp/backup_loop.tmp.output
    run_command_d "cat /tmp/backup_loop.tmp.output"
  else
    msgi "VM was not running. Doing nothing."
  fi

  msgi "Taring and gziping the backup"
  msgd "VM_TO_BACKUP_BCK_DIR: $VM_TO_BACKUP_BCK_DIR" 
  check_directory $VM_TO_BACKUP_BCK_DIR
  run_command_e "cd $D_BACKUP_DIR"
  run_command_e "pwd"
  run_command_e "tar cvzf ${VM_TO_BACKUP_BCK_NAME}.tar.gz $VM_TO_BACKUP_BCK_DIR"
  msgi "Done with this VM: $VM_TO_BACKUP"

  msgi "Removing the $VM_TO_BACKUP_BCK_DIR"
  run_command "rm -Rf $VM_TO_BACKUP_BCK_DIR"

done < $D_BACKUP_LIST

msgi "Done."
