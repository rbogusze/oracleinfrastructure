#!/bin/bash
for n in $(kubectl get -o=name pvc,configmap,ingress,service,secret,deployment,statefulset,hpa,job,cronjob | grep -v 'secrets/default-token')
do
    kubectl get -o=yaml --export $n > $(dirname $n)_$(basename $n).yaml
done
