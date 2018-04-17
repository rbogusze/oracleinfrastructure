#!/bin/bash
#$Id$
#

V_DIR=/u01/backup

echo "Cheate fake directories with .bck files and timestamps through last month"
echo "  under: $V_DIR"

DATE_START=`date -I`
NR_DAYS_BACK=30
myvar=0
while [ $myvar -ne $NR_DAYS_BACK ]
do

  CHECK_FOR_DATE=`date -I -d "$DATE_START $myvar day ago"`
  echo "Creating fo date: ${CHECK_FOR_DATE}"

  mkdir -p $V_DIR/${CHECK_FOR_DATE}

  V_FILE_NAME=$RANDOM
  echo $RANDOM > $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck
  touch -d "$myvar days ago" $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck

  V_FILE_NAME=$RANDOM
  echo $RANDOM > $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck
  touch -d "$myvar days ago" $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck

  V_FILE_NAME=$RANDOM
  echo $RANDOM > $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck
  touch -d "$myvar days ago" $V_DIR/${CHECK_FOR_DATE}/${V_FILE_NAME}.bck

  touch -d "$myvar days ago" $V_DIR/${CHECK_FOR_DATE}

  myvar=$(( $myvar + 1 ))
done
