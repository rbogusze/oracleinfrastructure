#!/bin/bash
# $Header: /CVS/cvsadmin/cvsrepository/admin/scripto/oracle/replay/replay.sh,v 1.11 2009/03/26 12:12:43 remikcvs Exp $
#
# !!!! D A N G E R !!!
#
# This script is very powerfull and as such very dangerous. 
# Use with utmost caution
#
mkdir -p log
(. ./replay.wrap 2>&1) | tee log/replay.`date '+%Y-%m-%d--%H:%M:%S'`
