#!/bin/bash
# Best reboot all the nodes before that

echo "Remove hdfs dir on node1"
rm -Rf /hdfs/tmp/*
echo "Remove hdfs dir on node2"
ssh node2 "rm -Rf /hdfs/tmp/*"
echo "Remove hdfs dir on node3"
ssh node3 "rm -Rf /hdfs/tmp/*"

echo "Format hdfs"
hadoop namenode -format

echo "Launch HDFS and YARN daemons"
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh

echo "Load books2.txt file"
cd ~/tmp/gutenberg
hdfs dfs -copyFromLocal books2.txt /books2.txt




