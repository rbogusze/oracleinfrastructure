#!/bin/bash

node=$1

if [ "$2" = "" ]; then
  CONTAINER_NAME=cassandra_$1
else
  CONTAINER_NAME=$2
fi

SNAPSHOT_LABEL=$3

BASE_DIR=/var/lib/container_data

#port where nodetool listen
#no need to specify - nodetool invoked inside docker
#port=$2

cqlshrc="/root/.cassandra/cqlshrc$node"

CASSANDRA_DATAFILES_DIRECTORY=$BASE_DIR/cassandra/$node/data

BACKUP_LOCATION=$BASE_DIR/backup/cassandra_"$node"
NUM_BACKUPS_TO_RETAIN=7
CQLSH="docker exec $CONTAINER_NAME cqlsh"
#CQLSH=cassandra/opt/cassandra/dsc-cassandra-3.0.9/bin/cqlsh

if [ "x$SNAPSHOT_LABEL" = "x" ]; then
    SNAPSHOT_LABEL=`date -u +%Y%m%d_%H%M%S`
fi

echo "*** `date -u` ***"
echo Starting backup with label: $SNAPSHOT_LABEL

echo Backup dir: $BACKUP_LOCATION/$SNAPSHOT_LABEL

if [ -f $BACKUP_LOCATION/$SNAPSHOT_LABEL.tgz ]; then
    echo "Label $SNAPSHOT_LABEL already exists"
    exit 1
fi

#WIP
$CQLSH --cqlshrc=$cqlshrc -e "desc keyspaces;"

mkdir -p $BACKUP_LOCATION/$SNAPSHOT_LABEL

for SCH_NAME in $($CQLSH --cqlshrc=$cqlshrc -e "desc keyspaces;" | sed 's/\s\+/\n/g' | sed '/^$/d'); do $CQLSH --cqlshrc=$cqlshrc -e "desc keyspace $SCH_NAME;" > $BACKUP_LOCATION/$SNAPSHOT_LABEL/$SCH_NAME.cql; done


docker exec cassandra_$node nodetool snapshot -t $SNAPSHOT_LABEL

echo Moving to backup directory...

#find $CASSANDRA_DATAFILES_DIRECTORY -depth \
#    | grep -e "snapshots/$SNAPSHOT_LABEL$" \
#    | awk -F \- -v backup_location=$BACKUP_LOCATION -v snapshot_label=$SNAPSHOT_LABEL '{print "mkdir -p " backup_location "/" snapshot_label $1}' \
#    | sed "s|$CASSANDRA_DATAFILES_DIRECTORY||" \
#    | xargs -r -0 bash -c
#
#find $CASSANDRA_DATAFILES_DIRECTORY -depth \
#    | grep -e "snapshots/$SNAPSHOT_LABEL$" \
#    | awk -F \- -v backup_location=$BACKUP_LOCATION -v snapshot_label=$SNAPSHOT_LABEL '{print "cp " $0 "/* " backup_location "/" snapshot_label $1}' \
#    | sed "s|$CASSANDRA_DATAFILES_DIRECTORY||2" \
#    | xargs -r -0 bash -c

for DIR in $(find $CASSANDRA_DATAFILES_DIRECTORY -depth | grep -e "snapshots/$SNAPSHOT_LABEL$") 
do 
  DEST_DIR=$BACKUP_LOCATION/$SNAPSHOT_LABEL$(echo $DIR | awk -F \- '{print $1}' | sed "s|$CASSANDRA_DATAFILES_DIRECTORY||") 
  mkdir -p $DEST_DIR 
  mv $DIR/* $DEST_DIR 
done

echo Tar...

tar cvzf $BACKUP_LOCATION/$SNAPSHOT_LABEL.tgz -C $BACKUP_LOCATION $SNAPSHOT_LABEL
#sudo openssl smime -encrypt -binary -text -aes256 -in $BACKUP_LOCATION/$SNAPSHOT_LABEL.tgz -out $BACKUP_LOCATION/$SNAPSHOT_LABEL.tgz.enc -outform DER /root/.cassandra/cassdump.pub.pem && rm -rf $BACKUP_LOCATION/$SNAPSHOT_LABEL.tgz
echo Cleaning...
rm -rf $BACKUP_LOCATION/$SNAPSHOT_LABEL


echo Removing snapshot...

docker exec cassandra_$node nodetool clearsnapshot -t $SNAPSHOT_LABEL

echo Removing old backup files...

ls -tr $BACKUP_LOCATION/* | grep -E "/[[:digit:]]{8}\_[[:digit:]]{6}\.tgz" | head -n -$NUM_BACKUPS_TO_RETAIN | xargs rm -f
