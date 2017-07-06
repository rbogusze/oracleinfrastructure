#!/bin/bash

echo "Updating ubu2"
ssh ubu2 "cd /etc/cassandra; svn update"
echo "Updating ubu3"
ssh ubu3 "cd /etc/cassandra; svn update"

