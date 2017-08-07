#!/bin/sh

# Just create a file with date where the switch occured

TAG=`echo $2 | tr -d "[]"`

TMP_LOG_DIR=/tmp/triggers/$1
mkdir -p $TMP_LOG_DIR

echo "$TAG `date '+%Y-%m-%d--%H:%M:%S'`" >> $TMP_LOG_DIR/${TAG}_`date -I`.txt
