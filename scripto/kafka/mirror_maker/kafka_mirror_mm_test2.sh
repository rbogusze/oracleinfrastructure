#!/bin/bash

/opt/kafka_2.11-1.0.0/bin/kafka-mirror-maker.sh --consumer.config sourceCluster1Consumer.config --num.streams 1 --producer.config targetClusterProducer.config --whitelist="mm_test1" > kafka_mirror_mm_test1.log 2>&1
