#!/bin/bash
#$Id$
#
# Prepare the command line to look like:
#${HOME}/oi_musas_awr/awr_reports.sh TEST perfstat `date -I` 14:00 15:00

$HOME/scripto/perl/ask_ldap.pl "orainfDbMusasMonitoring=TRUE" "['cn','orainfDbRrdoraUser','orainfDbMusasStart','orainfDbMusasEnd']" | awk '{ print "${HOME}/oi_musas_awr/awr_reports.sh " $1 " " $2 " `date -I` " $3 " " $4 " > /tmp/awr_reports.log" }' 
