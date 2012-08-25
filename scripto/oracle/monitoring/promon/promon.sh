#!/bin/bash
#$Id: promon.sh,v 1.1 2012-05-07 13:48:52 remik Exp $

LOG_DIR=/var/tmp/promon_${ORACLE_SID}
mkdir -p $LOG_DIR

(. ./promon.wrap 2>&1) | tee $LOG_DIR/promon_log_$1.`date '+%Y-%m-%d--%H:%M:%S'`
