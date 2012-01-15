#!/bin/bash

echo "Current Active Users Sessions"
echo
echo "Columns description:"
echo
echo "USERNAME - connected user name "
echo "STATUS - status of session (possible values: ACTIVE, INACTIVE, KILLED)"
echo "SEC_SINCE_SESS_INACTIVE - number of seconds since session became INACTIVE"

sqlplus -s /nolog << EOF
connect / as sysdba
set linesize 300 pagesize 300 echo off
set linesize 300
select USERNAME, STATUS, DECODE(STATUS,'ACTIVE','0','INACTIVE',LAST_CALL_ET) SEC_SINCE_SESS_INACTIVE from v\$session where 
STATUS != 'KILLED' and USERNAME is not null order by USERNAME;
EOF

echo -n "Enter USERNAME to KILL ! : "
read user

echo "Commands to run: "
sqlplus -s /nolog << EOF
connect / as sysdba
set linesize 300 pagesize 300 heading off echo off
spool /tmp/userkill.sql
select 'ALTER SYSTEM KILL SESSION ''' || SID || ',' || SERIAL# || ''';' from v\$session where USERNAME='$user';
spool off
EOF

echo -n "Should I run this commands ? [Y/N]: "

until [ "$ANSWER" = "Y" -o "$ANSWER" = "N" ]; do 
read ANSWER

case "$ANSWER" in 
"Y") 
  /tmp/userkill.sql 
  rm /tmp/userkill.sql
  ;;
"N")
  rm /tmp/userkill.sql
  exit 0
 ;;
*)
 echo "running else"
 echo "Please enter Y or N";
 ;;
esac

done;


echo "Enter 'q' to exit:"

until [ "$SU" = "q" ]; do 

sqlplus -s /nolog << EOF
connect / as sysdba
set linesize 300 pagesize 300 heading off echo off
select USERNAME, STATUS from v\$session where USERNAME='$user'; 
EOF

echo -n "Enter 'q' to exit : "
read SU

done;
