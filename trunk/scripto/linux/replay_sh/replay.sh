#!/bin/bash
# $Header: /home/remik/osobiste/cvs_repo/scripto/oracle/replay_sh/replay.sh,v 1.1 2012-05-07 13:49:15 remik Exp $
#
# !!!! D A N G E R !!!
#
# This script is very powerfull and as such very dangerous. 
# Use with utmost caution
#
LOG_DIR=log
LOG_NAME=replay_log
LOG=${LOG_DIR}/${LOG_NAME}.`date '+%Y-%m-%d--%H:%M:%S'`

mkdir -p $LOG_DIR
(. ./replay.wrap 2>&1) | tee $LOG
