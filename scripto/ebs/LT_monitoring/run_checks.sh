#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/var/tmp/LT_monitoring
mkdir -p $LOG_DIR

V_DATE=`date '+%Y%m%d_%H%M%S'`

(. ./run_checks.wrap 2>&1) | tee $LOG_DIR/run_checks_log_$1.${V_DATE} /var/www/html/dokuwiki/data/pages/run_checks_log_${V_DATE}.txt

echo "[[run_checks_log_${V_DATE}]]\\\\" >> /var/www/html/dokuwiki/data/pages/start.txt
