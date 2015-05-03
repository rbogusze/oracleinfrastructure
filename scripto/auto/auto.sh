#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/var/tmp/auto_${USER}
mkdir -p $LOG_DIR
LOG_NAME=$LOG_DIR/auto_log_$1.`date '+%Y-%m-%d--%H:%M:%S'`

(. ./auto.wrap 2>&1) | tee $LOG_NAME
