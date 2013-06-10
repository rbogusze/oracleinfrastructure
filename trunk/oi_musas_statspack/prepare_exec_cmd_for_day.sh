#!/bin/bash
#$Id: prepare_exec_cmd.sh 308 2013-02-21 16:24:44Z Remigiusz.Boguszewicz $
#
# Prepare the command line to look like:
# ./get_statspack.sh RAC1 perfstat 2013-06-03--16:00 2013-06-03--18:00
# ./get_statspack.sh RAC1 perfstat 2013-06-03--18:00 2013-06-03--20:00

STEP=1   # How much to increase the version retreived

CURRENT=00
END=23
while [ ${CURRENT} -lt ${END} ]
do
  OLD=${CURRENT}
  CURRENT=`expr ${CURRENT} + ${STEP}`
  echo ${CURRENT}

  #have 0 at the beginning, when it is one number
  TMP_CHK=`echo ${CURRENT} | wc -m`
  echo "TMP_CHK: $TMP_CHK"
  if [ $TMP_CHK -lt 3 ]; then
    CURRENT="0${CURRENT}"
  fi

  echo ${CURRENT}
  echo $OLD
  

  echo "./get_statspack.sh RAC1 perfstat 2013-06-03--$OLD:00 2013-06-03--${CURRENT}:00 > /dev/null 2>&1" 
done
