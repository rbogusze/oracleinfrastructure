#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./generate_test_data_bind.sh 1000

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
INFO_MODE=INFO

OUTFILE=/tmp/test_literals.sql

END=$1
check_parameter $END

msgi "Generating test data"
CURRENT=0
STEP=1

rm -f $OUTFILE

while [ ${CURRENT} -ne ${END} ]
do
  V_P1=$RANDOM
  V_P2=$RANDOM
  # random
  echo "INSERT INTO table2 (id, name, temperature) values ($CURRENT, 'Zosia_${V_P1}', $V_P2);" >> $OUTFILE
  # all with the same temp.
  #echo "INSERT INTO table1 (id, name, temperature) values ($CURRENT, 'Zosia_${V_P1}', 36.6);" >> $OUTFILE

  CURRENT=`expr ${CURRENT} + ${STEP}`
done

msgi "Output file can be found in $OUTFILE"
run_command_d "cat $OUTFILE"
