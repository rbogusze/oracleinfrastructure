#!/bin/bash
#$Id$
#
# Some special cases

# Load usefull functions                                                     
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then                         
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "     
  exit 1                                                                     
else                                                                         
  . $HOME/scripto/bash/bash_library.sh                                       
fi                                                                           

# Secelted CN for the whole day every hour, like
# ./awr_reports_special.sh UAT1 system 2016-09-21 11:00 12:00
# ./awr_reports_special.sh UAT1 system 2016-09-21 12:00 13:00                                                                             
DATE=2016-12-07
#DATE=`date -I`

for i in {1..23}
do
   NOW_DATE=$(date +%H:%M  -d "$DATE + $((i - 1)) hour")
   NEXT_DATE=$(date +%H:%M  -d "$DATE + $i hour")
   echo "./awr_reports_special.sh SITR2 system $DATE $NOW_DATE $NEXT_DATE"
done

