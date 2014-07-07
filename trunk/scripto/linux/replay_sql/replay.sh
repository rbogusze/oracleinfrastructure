#!/bin/bash
# $Header: /home/remik/osobiste/cvs_repo/scripto/oracle/replay/replay.sh,v 1.1 2012-05-07 13:49:15 remik Exp $
#
# !!!! D A N G E R !!!
#
# This script is very powerfull and as such very dangerous. 
# Use with utmost caution
#
mkdir -p log
(. ./replay.wrap 2>&1) | tee log/replay.`date '+%Y-%m-%d--%H:%M:%S'`
