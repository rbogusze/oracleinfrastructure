#!/bin/bash
#$Id: sp_snap.sh,v 1.2 2011/07/27 13:50:04 remikcvs Exp $
#
# Used to create a statspack snap on DB's where pgfDbMusas1xMonitoring=TRUE
#
# Example
# $ ./sp_snap.sh statspack_password
#


# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG

SP_PASS=$1
check_parameter $SP_PASS


SQLPLUS=sqlplus
F_SQLPLUS=`which sqlplus`
msgd "F_SQLPLUS: $F_SQLPLUS"
check_file $F_SQLPLUS

msgd "Generate list of DB's that have pgfDbMusas1xMonitoring=TRUE set"
F_TMP=/tmp/sp_snap_db.tmp

$HOME/scripto/perl/ask_ldap.pl "pgfDbMusas1xMonitoring=TRUE" "['cn']" > $F_TMP

F_SQL_TMP=/tmp/sp_snap_sql.tmp
msgd "Loop through list and execute snapschot"
while read LINE
do
  msgd "Connecting to $LINE"
  $SQLPLUS -s perfstat/${SP_PASS}@$LINE <<EOF > $F_SQL_TMP
show parameter instance_name
select sysdate from dual;
execute statspack.snap;
select sysdate from dual;
EOF
  
  run_command_d "cat $F_SQL_TMP"
  
done < $F_TMP







