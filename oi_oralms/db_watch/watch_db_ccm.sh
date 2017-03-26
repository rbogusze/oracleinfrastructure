#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/tmp/watch_db_ccm
mkdir -p $LOG_DIR

(. ./watch_db_ccm.wrap 2>&1) | tee $LOG_DIR/watch_db_ccm_log_`date '+%Y-%m-%d--%H:%M:%S'`
