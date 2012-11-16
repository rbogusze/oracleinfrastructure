#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Setting oracle environment
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

#INFO_MODE=DEBUG
INFO_MODE=INFO
RECIPIENTS='remigiusz_boguszewicz'
ORATAB=/etc/oratab

# Find dialog
DIALOG=/usr/bin/dialog
msgd "DIALOG: $DIALOG"

if [ -f "$DIALOG" ]; then
  msgd "OK, dialog found"
else
  msge "dialog NOT found. Exiting"
  msge "unable to present nice menu, please do it manually"
  exit 0
fi

msgd "Analiza oratab"
F_TMP=/tmp/dialog.tmp
if [ -f "$ORATAB" ]; then
  # construct dialog parameters
  #V_ORATAB_LINE=`cat $ORATAB | grep -v "^#" | grep -v "+ASM" | sed -e s/\#\ line\ added\ by\ Agent// | awk '{print $0 " "$0}' | tr "\n" " "`
  V_ORATAB_LINE=`cat $ORATAB | grep -v "^#" | grep -v "+ASM" | sed -e s/\#\ line\ added\ by\ Agent// | awk -F":" '{print $1 " "$0}' | tr "\n" " "`
  msgd "V_ORATAB_LINE: $V_ORATAB_LINE"
  run_command_d "cat $ORATAB"
  #dialog --menu "Chose database" 15 65 5 1 "zzz" 2 "bbb" 2> $F_TMP
  #dialog --menu "Chose database" 15 65 5 "bbb" "bbb" 2> $F_TMP
  #dialog --menu "Chose database" 15 65 5 bbb bb 2> $F_TMP
  dialog --menu "Chose database:" 20 75 12 $V_ORATAB_LINE 2> $F_TMP
  V_CHOSEN_MENU=`cat $F_TMP`
  msgd "V_CHOSEN_MENU: $V_CHOSEN_MENU"
  V_CHOSEN_SID=`echo $V_CHOSEN_MENU | awk -F":" '{print $1}'`
  msgd "V_CHOSEN_SID: $V_CHOSEN_SID"

  # Environment set by good old oraenv
  export ORACLE_SID=$V_CHOSEN_SID
  export ORAENV_ASK=NO
  . oraenv
  unset ORAENV_ASK

  # Setting handy aliases
  alias dbs='cd $ORACLE_HOME/dbs'
  alias tns='cd $ORACLE_HOME/network/admin'
  alias udump='cd /ORABIN/diag/$ORACLE_SID/udump'
  alias bdump='cd /ORABIN/diag/$ORACLE_SID/bdump'
  alias atail='tail -f /ORABIN/diag/$ORACLE_SID/bdump/alert_${ORACLE_SID}.log'
  alias ltail='less /ORABIN/diag/$ORACLE_SID/bdump/alert_${ORACLE_SID}.log'
  alias dba='rlwrap sqlplus "/ as sysdba"'

  # Info section
  msgi "ORACLE_SID: $ORACLE_SID"
  msgi "ORACLE_HOME: $ORACLE_HOME"


else
  msge "/etc/oratab NOT found. Exiting"
  exit 1
fi #oratab

