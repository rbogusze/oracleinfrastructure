#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./stresser.sh scott tiger DB 

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

USER=$1
PASS=$2
DB=$3

msgd "USER: $USER"
check_parameter $USER
msgd "PASS: $PASS"
check_parameter $PASS
msgd "DB: $DB"
check_parameter $DB

SQLPLUS=$ORACLE_HOME/bin/sqlplus
check_file $SQLPLUS

STARTTIME=$(date +%s%3N)
echo "Start: `date`"


while [ 1 ]
do
  msgd "Connecting to $DB"
  $SQLPLUS -S "$USER/$PASS@$DB" <<EOF 
set heading off
set linesize 200
select * from dual;
!sleep 1
EOF
done

ENDTIME=$(date +%s%3N)

V_ELA=`expr ${ENDTIME} - ${STARTTIME}`
echo "End: `date`"
echo "$V_ELA"


