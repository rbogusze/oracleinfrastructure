#!/bin/sh

# Just create a file with date where the switch occured

TAG=`echo $1 | tr -d "[]"`

TMP_LOG_DIR=/tmp/oralms_tns12535
mkdir -p $TMP_LOG_DIR

echo "$TAG `date '+%Y-%m-%d--%H:%M:%S'`" >> $TMP_LOG_DIR/${TAG}_`date -I`.txt
