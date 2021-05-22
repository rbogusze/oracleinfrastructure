#!/bin/bash


while [ 1 ]
do
    /home/pi/tmp/redis/redis-3.2.0/src/redis-cli -h 192.168.1.152 keys "*" | wc -l
done

