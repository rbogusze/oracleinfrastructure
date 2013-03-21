#!/bin/bash

export ORACLE_HOME=/u01/app/oracle/product/10.2.0/db_1
export ORACLE_SID=TEST10

RET=1

case $1 in 
'start') 
  $ORACLE_HOME/bin/sqlplus /nolog <<EOF
connect / as sysdba 
startup 
EOF
RET=0 
;; 
'stop') 
$ORACLE_HOME/bin/sqlplus /nolog <<EOF 
connect / as sysdba 
shutdown immediate 
EOF
RET=0 
;;
'clean') 
$ORACLE_HOME/bin/sqlplus /nolog <<EOF 
connect / as sysdba 
shutdown abort 
##for i in `ps -ef | grep -i $ORACLE_SID | awk '{print $2}' ` ;do kill -9 $i; done 
EOF
RET=0 
;; 
'check') 
ok=`ps -ef | grep smon | grep $ORACLE_SID | wc -l` 
if [ $ok = 0 ]; then 
RET=1 
else 
RET=0 
fi 
;; 
'*') 
RET=0 
;; 
esac

if [ $RET -eq 0 ]; then 
  exit 0 
else 
  exit 1
fi

