#!/bin/bash
# $Header: /home/remik/cvs_root_kgp/oralms/send_ORA_err.sh,v 1.1 2012-05-25 11:52:26 orainf Exp $

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

#RECIPIENTS='Remigiusz_Boguszewicz@notes.pgf.com.pl'
RECIPIENTS='dba@notes.pgf.com.pl'
F_ERROR_FILE=/tmp/oralms_ORA.err
D_ARCH_DIR=/tmp/oralms_ORA_arch

mkdir -p $D_ARCH_DIR
check_directory $D_ARCH_DIR

echo "" >> ${F_ERROR_FILE}
echo "---Disclaimer---" >> ${F_ERROR_FILE}
echo "Please note, reported errors are not the only ORA- errors found in alert log. I filter some of the out (found in filter_all.conf) not to bother us with the usuall ones. This can pottentially lead to important errors that are not spotted." >> ${F_ERROR_FILE}
if [ -f "${F_ERROR_FILE}" ]; then
  msgd "Found ${F_ERROR_FILE}, sending its contents"
  cat ${F_ERROR_FILE} | sort | mailx -s "[ 24h of ORA- ]" $RECIPIENTS
fi

#
mv ${F_ERROR_FILE} $D_ARCH_DIR/send_on_`date '+%Y-%m-%d--%H:%M:%S'`

