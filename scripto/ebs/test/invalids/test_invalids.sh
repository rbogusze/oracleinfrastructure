#!/bin/bash
#$Id: _base_script_block.sh,v 1.1 2012-05-07 13:47:27 remik Exp $

LOG_DIR=/home/oracle/scripto/ebs/test/invalids/logs
mkdir -p $LOG_DIR
LOG_NAME=test_invalids_log_$1.`date '+%Y-%m-%d--%H:%M:%S'`

(. ./test_invalids.wrap 2>&1) | tee ${LOG_DIR}/${LOG_NAME}

cd $LOG_DIR
svn add ${LOG_NAME}
svn commit -m "auto commit"
