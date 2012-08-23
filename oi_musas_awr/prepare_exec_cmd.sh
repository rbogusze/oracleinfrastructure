#!/bin/bash
#$Id$
#
# Prepare the command line to look like:
#11 16 * * * . ${HOME}/.bash_profile; ${HOME}/oi_musas_awr/awr_reports.sh TEST `date -I` 08:00 16:00 > /tmp/awr_reports.log
#21 16 * * * . ${HOME}/.bash_profile; ${HOME}/oi_musas_awr/awr_reports.sh TEST2 `date -I` 08:00 16:00 > /tmp/awr_reports.log
#31 16 * * * . ${HOME}/.bash_profile; ${HOME}/oi_musas_awr/awr_reports.sh ZEBRA `date -I` 08:00 16:00 > /tmp/awr_reports.log

$HOME/scripto/perl/ask_ldap.pl "orainfDbMusasMonitoring=TRUE" "['cn']" | awk '{ print "${HOME}/oi_musas_awr/awr_reports.sh " $1 " `date -I` 08:00 16:00 > /tmp/awr_reports.log" }' 
