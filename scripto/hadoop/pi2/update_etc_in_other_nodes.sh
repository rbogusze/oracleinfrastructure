#!/bin/bash

ssh node2 "cd /opt/hadoop/etc/hadoop; svn update"
ssh node3 "cd /opt/hadoop/etc/hadoop; svn update"

