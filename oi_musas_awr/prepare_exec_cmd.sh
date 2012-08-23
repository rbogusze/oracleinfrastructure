#!/bin/bash
#$Id: prepare_exec_cmd.sh,v 1.2 2012-06-08 14:07:21 orainf Exp $
#
# Prepare the command line to look like:
#11 16 * * * . ${HOME}/.bash_profile; ${HOME}/musas_awr/awr_reports.sh KSIPDBP1 `date -I` 08:00 16:00 > /tmp/awr_reports.log
#21 16 * * * . ${HOME}/.bash_profile; ${HOME}/musas_awr/awr_reports.sh KSIPDBS1 `date -I` 08:00 16:00 > /tmp/awr_reports.log
#31 16 * * * . ${HOME}/.bash_profile; ${HOME}/musas_awr/awr_reports.sh KSIPDBD1 `date -I` 08:00 16:00 > /tmp/awr_reports.log


#5 21 * * 1-5 $HOME/scripto/perl/ask_ldap.pl "remikDbMusasMonitoring=TRUE" "['cn', 'remikDbMusasStart', 'remikDbMusasEnd']" | awk '{ print "/home/logwatch/musas/get_statspack.sh "$1 " perfhal `date -I`--" $2 " `date -I`--" $3 " >/dev/null 2>&1"}' > /home/logwatch/musas/musas_commands_from_ldap; sh /home/logwatch/musas/musas_commands_from_ldap

$HOME/scripto/perl/ask_ldap.pl "orainfMusasMonitoring=TRUE" "['cn']" | awk '{ print "${HOME}/musas_awr/awr_reports.sh " $1 " `date -I` 08:00 16:00 > /tmp/awr_reports.log" }' 
