#!/bin/bash

nohup /opt/kafka_2.11-1.0.0/bin/kafka-mirror-maker.sh --consumer.config sourceCluster1Consumer.config --num.streams 1 --producer.config targetClusterProducer.config --whitelist="mm_test5" > /var/log/mirror_maker/kafka_mirror_mm_test5_`date '+%Y-%m-%d--%H:%M:%S'`.log 2>&1 &
