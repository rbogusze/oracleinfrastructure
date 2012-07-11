#!/bin/bash
#$Id: prepare_rrdora.dblist.sh,v 1.2 2012-06-08 13:34:56 orainf Exp $
#
# Prepare the file rrdora.dblist to look like:
# TEST|perfstat|password

V_PASS=`cat $HOME/.credentials | grep V_PASS | awk -F"=" '{print $2}' `

$HOME/scripto/perl/ask_ldap.pl "orainfDbRrdoraMonitoring=TRUE" "['cn', 'orainfDbRrdoraUser']" | awk '{ print $1 "|" $2 "|V_PASS"}' | sed  s/V_PASS/$V_PASS/
