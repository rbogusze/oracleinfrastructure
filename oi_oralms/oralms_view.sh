#!/bin/bash
# $Header: /home/remik/cvs_root_kgp/oralms/oralms_view.sh,v 1.2 2012-05-25 11:52:39 orainf Exp $

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

check_file `which ack`


# Make it more colorfull and add action to selected events
cd /tmp
tail -f global_alert.log | ack --flush --passthru --color --color-match=red "ORA-.....|terminated|Corrupt" \
| ack --flush --passthru --color --color-match=yellow "Completed: ALTER DATABASE OPEN|Completed: ALTER DATABASE CLOSE NORMAL|Completed: ALTER DATABASE DISMOUNT" \
| ack --flush --passthru --color --color-match=magenta "cannot allocate new log|Checkpoint not complete" \
| ack --flush --passthru --color --color-match=cyan "###|warning|free_space_tablespaces|gather_monitor|free_space_filesystems|tremor error" \
| ack --flush --passthru --color --color-match=green "^... ... .. ..:..:.. .... ....|^... ... .. ..:..:.. ... ...."

