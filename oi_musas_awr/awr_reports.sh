#!/bin/bash
# $Header$
#
# ./awr_reports.sh TEST `date -I` 08:00 16:00
#

LOCKFILE=/tmp/awr_reports.lock
#INFO_MODE=DEBUG


# Load usefull functions
D_SCRIPTO_DIR=~/scripto
if [ ! -f $D_SCRIPTO_DIR/bash/bash_library.sh ]; then
  echo "[error] ${D_SCRIPTO_DIR}/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${D_SCRIPTO_DIR}/bash/bash_library.sh
fi

check_lock $LOCKFILE
#touch $LOCKFILE

CN="$1"
V_USER="$2"
CURRENT_DAY="$3"

HOUR_START="$4"
HOUR_STOP="$5"

msgd "HOUR_START: $HOUR_START"
msgd "HOUR_STOP : $HOUR_STOP"

check_parameter $CURRENT_DAY
check_parameter $HOUR_START
check_parameter $HOUR_STOP
check_parameter $CN
check_parameter $V_USER

#LOG=/tmp/awr_reports.log
#exec > $LOG 2>&1

F_CRED_FILE=~/.credentials
PWD_FILE=~/.passwords
V_PASS_SOURCING=hash

if [ ${V_PASS_SOURCING} = "source" ]; then
  msgd "Getting password from sourcing file"
  # Sourcing the password variables
  check_file $F_CRED_FILE
  . $F_CRED_FILE

elif [ ${V_PASS_SOURCING} = "hash" ]; then
  msgd "Getting password from hash"

  INDEX_HASH=`$HOME/scripto/perl/ask_ldap.pl "(cn=$CN)" "['orainfDbRrdoraIndexHash']" 2>/dev/null | grep -v '^ *$' | tr -d '[[:space:]]'`
  msgd "INDEX_HASH: $INDEX_HASH"
  HASH=`echo "$INDEX_HASH" | base64 --decode -i`
  msgd "HASH: $HASH"
  if [ -f "$PWD_FILE" ]; then
    V_PASS=`cat $PWD_FILE | grep $HASH | awk '{print $2}' | base64 --decode -i`
    #msgd "V_PASS: $V_PASS"
  else
    msge "Unable to find the password file. Exiting"
    exit 0
  fi

else
  msge "Unknown method to retrieve password. Exiting"
  exit 0
fi

msgd "V_USER: $V_USER"
#msgd "V_PASS: $V_PASS"
check_variable $V_USER
check_variable $V_PASS

S_SQL_ID_REPORTS=~/oi_musas_awr/sql_id_reports.sh
check_file $S_SQL_ID_REPORTS

IFS="="
msgi "checking for $CN"

testavail=`sqlplus -S /nolog <<EOF
set head off pagesize 0 echo off verify off feedback off heading off
connect $V_USER/$V_PASS@$CN
select trim(1) result from dual;
exit;
EOF`

if [ "$testavail" != "1" ]; then
  msge "DB $CN not available, exiting !!" 
  rm -f $LOCKFILE
  exit 0
else
  msgi "DB $CN available , generating AWR reports" 

run_command "mkdir -p /var/tmp/awr_reports"
check_directory /var/tmp/awr_reports
run_command "cd /var/tmp/awr_reports"

msgd "Checking if I am able to execute DBMS_WORKLOAD_REPOSITORY package"
F_TMP=/tmp/awr_reports_out.tmp
sqlplus /nolog << EOF > $F_TMP
connect $V_USER/$V_PASS@$CN
desc dbms_workload_repository;
EOF

V_TMP=`cat $F_TMP | grep -i "ORA-" | wc -l`
msgd "V_TMP: $V_TMP"
if [ "${V_TMP}" -ne 0 ]; then
  msge "There is some error when trying to access the dbms_workload_repository package:"
  run_command_d "cat $F_TMP"
  msge "Exiting."
  exit 0
else
  run_command_d "cat $F_TMP"
  msgd "OK, I able to access dbms_workload_repository. Continuing."
fi

msgi "Generating AWR report. Please wait"

#sqlplus /nolog << EOF 
sqlplus /nolog << EOF > /dev/null
set head off pagesize 0 echo off verify off feedback off heading off
col fname_txt new_value file_name_txt
col fname_html new_value file_name_html

connect $V_USER/$V_PASS@$CN
var dbid NUMBER
var instid NUMBER
var instname VARCHAR2(50)
var str_day_date VARCHAR2(50)
var begin_date VARCHAR2(50)
var begin_date_fname VARCHAR2(100)
var end_date VARCHAR2(50)
var end_date_fname VARCHAR2(100)
var begin_snap NUMBER
var end_snap NUMBER

begin
Select dbid into :dbid from v\$database;
Select instance_name into :instname from v\$instance;
Select instance_number into :instid from v\$instance;
select '$CURRENT_DAY' into :str_day_date from dual;
select :str_day_date || ' $HOUR_START' into :begin_date from dual;
select :str_day_date || ' $HOUR_STOP' into :end_date from dual;

select :str_day_date || '_' || '$HOUR_START' into :begin_date_fname from dual;
select :str_day_date || '_' || '$HOUR_STOP' into :end_date_fname from dual;

select snap_id into :begin_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:begin_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);
select snap_id into :end_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:end_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);

end;
/

select 'awr_' || :instname || '_' || :begin_date_fname || '_' || :end_date_fname || '.txt' "fname_txt" from dual;
select 'awr_' || :instname || '_' || :begin_date_fname || '_' || :end_date_fname || '.html' "fname_html" from dual;

spool &file_name_txt
SELECT output FROM TABLE(dbms_workload_repository.AWR_REPORT_TEXT(:dbid,:instid,:begin_snap,:end_snap));
spool off
set linesize 400
spool &file_name_html
SELECT output FROM TABLE(dbms_workload_repository.AWR_REPORT_HTML(:dbid,:instid,:begin_snap,:end_snap));
spool off
EOF

msgd "If dummy file is generated then something went wrong"
if [ -f awr___.html ] || [ -f awr___.txt ]; then
  msge "Something went wrong."
  run_command_d "cat awr___.txt"
  msge "Something went wrong."
  msgd "Removing those files, so that the next proper run is not stopped by their existence"
  rm -f awr___.html awr___.txt
  exit 1
fi

msgi "Generating AWR report. Done."
msgd "Generating file names"

####### Co tu Radzio chcial powiedziec? Robi od poczatku zeby okreslic nazwe plikow?

sqlplus -s /nolog << EOF | awk '{ if(NR==1) printf("%s%s\n","FTXT=",$1) ; if(NR==4) printf("%s%s\n","FHTML=",$1) }'  > FNAMES.TXT
set head off pagesize 0 echo off verify off feedback off heading off

connect $V_USER/$V_PASS@$CN
var dbid NUMBER
var instid NUMBER
var instname VARCHAR2(50)
var str_day_date VARCHAR2(50)
var begin_date VARCHAR2(50)
var begin_date_fname VARCHAR2(100)
var end_date VARCHAR2(50)
var end_date_fname VARCHAR2(100)
var begin_snap NUMBER
var end_snap NUMBER
begin
Select dbid into :dbid from v\$database;
Select instance_name into :instname from v\$instance;
Select instance_number into :instid from v\$instance;
select '$CURRENT_DAY' into :str_day_date from dual;
select :str_day_date || ' $HOUR_START' into :begin_date from dual;
select :str_day_date || ' $HOUR_STOP' into :end_date from dual;
select :str_day_date || '_' || '$HOUR_START' into :begin_date_fname from dual;
select :str_day_date || '_' || '$HOUR_STOP' into :end_date_fname from dual;
select snap_id into :begin_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:begin_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);
select snap_id into :end_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:end_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);
end;
/
select  'awr_' || :instname || '_' || :begin_date_fname || '_' || :end_date_fname || '.txt', 1 from dual
union
select  'awr_' || :instname || '_' || :begin_date_fname || '_' || :end_date_fname || '.html', 2 from dual order by 2;
EOF

. ./FNAMES.TXT

msgd "Generating file names. Done."

numlines=$(wc -l $FTXT)
numlines=$(echo $numlines | awk '{ print $1 }')
numlines=$(($numlines - 1))

head -$numlines $FTXT | tail -$(($numlines-1)) > ${FTXT}.tmp
mv ${FTXT}.tmp $FTXT

numlines=$(wc -l $FHTML)
numlines=$(echo $numlines | awk '{ print $1 }')
numlines=$(($numlines - 1))

head -$numlines $FHTML | tail -$(($numlines-1)) > ${FHTML}.tmp
mv ${FHTML}.tmp $FHTML

fi; #Baza $CN dostepna , generuje raporty

# moving the awr reports between the directories
D_TXT_DAY=/var/www/html/awr_reports/$CN/AWR_txt_day
D_HTML_DAY=/var/www/html/awr_reports/$CN/AWR_html_day

msgd "FTXT: $FTXT"
msgd "FHTML: $FHTML"

run_command "mkdir -p $D_TXT_DAY"
check_directory $D_TXT_DAY
run_command "mv $FTXT $D_TXT_DAY"
run_command "mkdir -p $D_HTML_DAY"
check_directory $D_HTML_DAY
run_command "mv $FHTML $D_HTML_DAY"

# generate sql_id reports
msgi "Generating sql_id reports."
check_file `which php`
$S_SQL_ID_REPORTS $D_TXT_DAY/$FTXT $V_USER

msgi "Done awr_reports.sh"

# Remove lock file
rm -f $LOCKFILE

