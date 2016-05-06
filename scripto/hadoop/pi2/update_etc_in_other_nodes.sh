#!/bin/bash

echo "Updating node2"
ssh node2 "cd /opt/hadoop/etc/hadoop; svn update"
echo "Updating node3"
ssh node3 "cd /opt/hadoop/etc/hadoop; svn update"

