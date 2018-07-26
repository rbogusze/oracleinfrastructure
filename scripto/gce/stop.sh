#!/bin/bash

gcloud compute instances list | grep -v PREEMPTIBLE > /tmp/instances.txt
while read LINE
do
  echo $LINE
  V_INSTANCE_NAME=`echo $LINE | awk '{print $1}'`
  echo "Stopping $V_INSTANCE_NAME"
  gcloud compute instances stop $V_INSTANCE_NAME --zone=us-east1-b --async
done < /tmp/instances.txt
