#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/var/tmp/cassandra-docker-restore
mkdir -p $LOG_DIR

(. ./restore.wrap 2>&1) | tee $LOG_DIR/restore_log_`date '+%Y-%m-%d--%H:%M:%S'`
