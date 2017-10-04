#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/var/tmp/remote_tail
mkdir -p $LOG_DIR

(. ./spawn_tail.wrap 2>&1) | tee $LOG_DIR/remote_tail_log_$1.`date '+%Y-%m-%d--%H:%M:%S'`
