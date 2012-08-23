#!/bin/bash
# $Header:$
#
# ./awr_reports.sh KSIPDBS1 `date -I` 08:00 16:00
#

LOCKFILE=/tmp/awr_reports.lock
INFO_MODE=DEBUG

# Load usefull functions
D_SCRIPTO_DIR=~/scripto
if [ ! -f $D_SCRIPTO_DIR/bash/bash_library.sh ]; then
  echo "[error] ${D_SCRIPTO_DIR}/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${D_SCRIPTO_DIR}/bash/bash_library.sh
fi

check_lock $LOCKFILE
touch $LOCKFILE

CN="$1"
CURRENT_DAY="$2"

HOUR_START="$3"
HOUR_STOP="$4"

echo "HOUR_START: $HOUR_START"
echo "HOUR_STOP : $HOUR_STOP"

check_parameter $CURRENT_DAY
check_parameter $HOUR_START
check_parameter $HOUR_STOP
check_parameter $CN

#LOG=/tmp/awr_reports.log
#exec > $LOG 2>&1

# Sourcing the password variables
F_CRED_FILE=~/musas_awr/.credentials
check_file $F_CRED_FILE
. $F_CRED_FILE

S_SQL_ID_REPORTS=~/musas_awr/sql_id_reports.sh
check_file $S_SQL_ID_REPORTS

IFS="="
#ldapsearch -h smort.pgf.com.pl -b "dc=pgf,dc=com,dc=pl" "&(&(|(remikDbType=RETIREMENT)(remikDbType=ASSIST)(remikDbType=PRODUCTION)))(!(CN=WORKF))" CN | sed '/^$/d' | sed '/dc=/d' | sed '/OMS1/d' | sed '/ADE/d' | sed '/REPO/d' |  while read t1 CN; do

echo "[msg] checking for $CN"

testavail=`sqlplus -S /nolog <<EOF
set head off pagesize 0 echo off verify off feedback off heading off
connect $V_USER/$V_PASS@$CN
select trim(1) result from dual;
exit;
EOF`

if [ "$testavail" != "1" ]; then
  echo "Baza $CN niedostepna , wychodze !!" 
  exit 0
else
  echo "Baza $CN dostepna , generuje raporty AWR" 

run_command "mkdir -p /var/tmp/awr_reports"
run_command "check_directory /var/tmp/awr_reports"
run_command "cd /var/tmp/awr_reports"

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

select 'awr_' || :instname || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.txt' "fname_txt" from dual;
select 'awr_' || :instname || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.html' "fname_html" from dual;

spool &file_name_txt
SELECT output FROM TABLE(dbms_workload_repository.AWR_REPORT_TEXT(:dbid,:instid,:begin_snap,:end_snap));
spool off
set linesize 400
spool &file_name_html
SELECT output FROM TABLE(dbms_workload_repository.AWR_REPORT_HTML(:dbid,:instid,:begin_snap,:end_snap));
spool off
EOF

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
select  'awr_' || :instname || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.txt', 1 from dual
union
select  'awr_' || :instname || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.html', 2 from dual order by 2;
EOF

. ./FNAMES.TXT

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
D_TXT_HOUR=/var/www/html/awr_reports/$CN/AWR_txt_hour/$CURRENT_DAY
D_HTML_HOUR=/var/www/html/awr_reports/$CN/AWR_html_hour/$CURRENT_DAY
D_TXT_DAY=/var/www/html/awr_reports/$CN/AWR_txt_day
D_HTML_DAY=/var/www/html/awr_reports/$CN/AWR_html_day

msgd "FTXT: $FTXT"
msgd "FHTML: $FHTML"
# decide whther the file is an hour or day file
V_TMP=`echo $FTXT | grep "08:00" | grep "16:00" | wc -l`
if [ "${V_TMP}" -eq 1 ]; then
  # mamy plik dzienny
  run_command "mkdir -p $D_TXT_DAY"
  check_directory $D_TXT_DAY
  run_command "mv $FTXT $D_TXT_DAY"
  run_command "mkdir -p $D_HTML_DAY"
  check_directory $D_HTML_DAY
  run_command "mv $FHTML $D_HTML_DAY"

  # generate sql_id reports
  msga "This is dayly AWR report, generating sql_id reports."
  $S_SQL_ID_REPORTS $D_TXT_DAY/$FTXT  

else 
  # mamy plik godzinowy
  run_command "mkdir -p $D_TXT_HOUR"
  check_directory $D_TXT_HOUR
  run_command "mv $FTXT $D_TXT_HOUR"
  run_command "mkdir -p $D_HTML_HOUR"
  check_directory $D_HTML_HOUR
  run_command "mv $FHTML $D_HTML_HOUR"

  # generate sql_id reports, perhaps it is too much to generate the sql reports every hour?
#  msgi "This is hourly AWR report, SKIPPING sql_id report generation"
#  msgi "This is hourly AWR report, generating sql_id report but it can be too costly. Disable it if there are any perf problems encoutered."
#  $S_SQL_ID_REPORTS $D_TXT_HOUR/$FTXT  
fi

msgi "Done awr_reports.sh"

# Remove lock file
rm -f $LOCKFILE

