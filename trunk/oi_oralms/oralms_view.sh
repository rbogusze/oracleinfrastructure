#!/bin/bash
# $Header: /home/remik/cvs_root_kgp/oralms/oralms_view.sh,v 1.2 2012-05-25 11:52:39 orainf Exp $

#set -x

LOGMON_CONFIG=/home/orainf/oralms/logmon_global_alert.conf

# Make it more colorfull and add action to selected events
cd /tmp
logmon -f $LOGMON_CONFIG global_alert.log

