#!/bin/bash
# This script just adds timestamp to the log file every 15min
watch -n 900 'date >> /tmp/global_alert_raw.log' &
