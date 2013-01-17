#!/bin/bash
#$Id: oracle_setup.sh,v 1.1 2012-05-07 13:48:38 remik Exp $

LOG_DIR=/var/tmp/oracle_setup_${ORACLE_SID}
mkdir -p $LOG_DIR

(. ./oracle_setup.wrap 2>&1) | tee $LOG_DIR/oracle_setup_log_$1.`date '+%Y-%m-%d--%H:%M:%S'`
