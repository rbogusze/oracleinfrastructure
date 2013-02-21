#!/bin/bash
#$Id: prepare_exec_cmd.sh 308 2013-02-21 16:24:44Z Remigiusz.Boguszewicz $
#
# Prepare the command line to look like:
#${HOME}/oi_musas_statspack/get_statspack.sh DB10203 perfstat 2013-02-21--14:45 2013-02-21--15:00


$HOME/scripto/perl/ask_ldap.pl "(&(orainfDbMusasMonitoring=TRUE)(orainfDbMusasMonitoringMode=statspack))" "['cn','orainfDbRrdoraUser','orainfDbMusasStart','orainfDbMusasEnd']" | awk '{ print "${HOME}/oi_musas_statspack/get_statspack.sh " $1 " " $2 " `date -I`--"$3 " `date -I`--" $4 " > /tmp/statspack_report.log" }' 
