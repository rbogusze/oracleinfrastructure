#!/bin/bash
#$Id$
#
# Prepare the command line to look like:
#${HOME}/oi_musas_awr/awr_reports.sh TEST perfstat `date -I` 14:00 15:00

# Load usefull functions                                                     
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then                         
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "     
  exit 1                                                                     
else                                                                         
  . $HOME/scripto/bash/bash_library.sh                                       
fi                                                                           
                                                                             
#INFO_MODE=DEBUG                                                              

# Old way, done by nice one-liner
#$HOME/scripto/perl/ask_ldap.pl "(&(orainfDbMusasMonitoring=TRUE)(orainfDbMusasMonitoringMode=awr))" "['cn','orainfDbRrdoraUser','orainfDbMusasStart','orainfDbMusasEnd']" | awk '{ print "${HOME}/oi_musas_awr/awr_reports.sh " $1 " " $2 " `date -I` " $3 " " $4 " > /tmp/awr_reports.log" }' 

# New way that allows multiple start/stop times

msgd "List the CN that are candidates"
$HOME/scripto/perl/ask_ldap.pl "(&(orainfDbMusasMonitoring=TRUE)(orainfDbMusasMonitoringMode=awr))" "['cn']" > /tmp/prepare_exec_cmd_cn.txt
run_command_d "cat /tmp/prepare_exec_cmd_cn.txt"

msgd "Loop through the CNs"
while read CN
do
  msgd "Acting for: $CN"
  TMP_CHK=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbMusasStart']" | tr " " "\n" | grep -v '^ *$' | wc -l` 
  msgd "TMP_CHK: $TMP_CHK"
  if [ "$TMP_CHK" -gt 1 ]; then
    msgd "Multiple runs"
    $HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbMusasStart']" | tr " " "\n" | grep -v '^ *$' > /tmp/prepare_exec_cmd_cn_start.txt
    $HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbMusasEnd']" | tr " " "\n" | grep -v '^ *$' > /tmp/prepare_exec_cmd_cn_end.txt
    run_command_d "cat /tmp/prepare_exec_cmd_cn_start.txt"
    run_command_d "cat /tmp/prepare_exec_cmd_cn_end.txt"

    while read line; do
    if ! read -u 3 line2
    then
      break
    fi
      msgd "$line $line2"
      $HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['cn','orainfDbRrdoraUser']" | awk '{ print "${HOME}/oi_musas_awr/awr_reports.sh " $1 " " $2 " `date -I`" }' > /tmp/prepare_exec_cmd_cn_multi.txt
      run_command_d "cat /tmp/prepare_exec_cmd_cn_multi.txt"
      V_MULTI_RUN=`cat /tmp/prepare_exec_cmd_cn_multi.txt`
      msgd "V_MULTI_RUN: $V_MULTI_RUN"
      echo "$V_MULTI_RUN $line $line2 > /tmp/awr_reports.log"


    done < /tmp/prepare_exec_cmd_cn_start.txt 3< /tmp/prepare_exec_cmd_cn_end.txt
   
  else
    msgd "One time, standard run"
    $HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['cn','orainfDbRrdoraUser','orainfDbMusasStart','orainfDbMusasEnd']" | awk '{ print "${HOME}/oi_musas_awr/awr_reports.sh " $1 " " $2 " `date -I` " $3 " " $4 " > /tmp/awr_reports.log" }' 
  fi
  
done < /tmp/prepare_exec_cmd_cn.txt




