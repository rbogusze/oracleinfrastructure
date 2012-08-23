#!/bin/bash
#$Header$

# Load usefull functions
D_SCRIPTO_DIR=~/scripto
if [ ! -f $D_SCRIPTO_DIR/bash/bash_library.sh ]; then
  echo "[error] ${D_SCRIPTO_DIR}/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${D_SCRIPTO_DIR}/bash/bash_library.sh
fi

# Sourcing the password variables
F_CRED_FILE=~/.credentials
check_file $F_CRED_FILE
. $F_CRED_FILE

msgi "ala ma kota"
INFO_MODE=DEBUG

F_RAPORT_FILE=$1
check_file $F_RAPORT_FILE
F_HASH=/tmp/hash_reports.tmp

S_RETREIVE_HASH=/home/orainf/oi_musas_awr/retreive_hashes.php
check_file $S_RETREIVE_HASH

check_file `which php`
check_file `which lynx`

msgd "Retreive hashes from statspack report"
rm -f $F_HASH
run_command "php $S_RETREIVE_HASH $F_RAPORT_FILE $F_HASH > /dev/null 2>&1"
check_file $F_HASH

msgi "Prepare directory for hash reports"
D_HASH_HISTORY=`dirname $F_RAPORT_FILE`/hash_history/
run_command_e "mkdir -p $D_HASH_HISTORY"
run_command_e "cd $D_HASH_HISTORY"

msgd "V_USER: $V_USER"
#msgd "V_PASS: $V_PASS"

# Extract the Service name from file name. Not elegent, not the first time...
msgd "F_RAPORT_FILE: $F_RAPORT_FILE"
V_CN=`dirname $F_RAPORT_FILE | awk -F"/" '{print $6}'`
msgd "V_CN: $V_CN"
HOUR_START=`basename $F_RAPORT_FILE | grep -o "....-..-.._..:.._....-..-.._..:.." | sed s/^....-..-.._// | sed s/_....-..-.._/\|/ | awk -F"|" '{print $1}'`
msgd "HOUR_START: $HOUR_START"
HOUR_STOP=`basename $F_RAPORT_FILE | grep -o "....-..-.._..:.._....-..-.._..:.." | sed s/^....-..-.._// | sed s/_....-..-.._/\|/ | awk -F"|" '{print $2}'`
msgd "HOUR_STOP: $HOUR_STOP"
CURRENT_DAY=`basename $F_RAPORT_FILE | grep -o "....-..-.." | tr "\n" "|" | awk -F"|" '{print $1}' `
msgd "CURRENT_DAY: $CURRENT_DAY"

# Loop through the hash list and extract the hash report from database
while read V_LINE
do
  msgd "Extract the report for hash V_LINE: $V_LINE"
  #sqlplus /nolog << EOF 
  sqlplus /nolog << EOF > /dev/null
set head off pagesize 0 echo off verify off feedback off heading off
col fname_txt new_value file_name_txt
col fname_html new_value file_name_html

connect $V_USER/$V_PASS@$V_CN
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
var sqlid VARCHAR2(13)

begin
Select dbid into :dbid from v\$database;
Select instance_name into :instname from v\$instance;
Select instance_number into :instid from v\$instance;
select '$CURRENT_DAY' into :str_day_date from dual;
select :str_day_date || ' $HOUR_START' into :begin_date from dual;
select :str_day_date || ' $HOUR_STOP' into :end_date from dual;
select '$V_LINE' into :sqlid from dual;

select :str_day_date || '_' || '$HOUR_START' into :begin_date_fname from dual;
select :str_day_date || '_' || '$HOUR_STOP' into :end_date_fname from dual;

select snap_id into :begin_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:begin_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);
select snap_id into :end_snap from dba_hist_snapshot where DBID=:dbid and INSTANCE_NUMBER=:instid and
(to_date(:end_date,'YYYY-MM-DD HH24:MI') between begin_interval_time and end_interval_time);

end;
/

select 'awr_' || :instname || '_' || :sqlid || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.txt' "fname_txt" from dual;
select 'awr_' || :instname || '_' || :sqlid || '_' || :begin_snap || '_' || :end_snap || '_' || :begin_date_fname || '_' || :end_date_fname || '.html' "fname_html" from dual;

spool &file_name_txt
SELECT output FROM TABLE(dbms_workload_repository.AWR_SQL_REPORT_TEXT(:dbid,:instid,:begin_snap,:end_snap,:sqlid));
spool off

set linesize 400
spool &file_name_html
SELECT output FROM TABLE(dbms_workload_repository.AWR_SQL_REPORT_HTML(:dbid,:instid,:begin_snap,:end_snap,:sqlid));
spool off

EOF

done < $F_HASH

msgi "Because of Oracle bug in 10.2.0.4 that causes in txt reports many '##########'"
msgi "I am turning the html files into txt ones."
mkdir -p /tmp/org_hash
for i in `ls *.html`
do
  #echo $i
  F_TMP_NAME=`echo $i | sed s/html$/txt/`
  #echo "new filename: $F_TMP_NAME"
  mv $F_TMP_NAME /tmp/org_hash
  lynx -dump http://logwatch/awr_reports/$V_CN/AWR_txt_day/hash_history/$i > $F_TMP_NAME
done


msgi "Move all the .html files to AWR_html dir"
msgd "D_HASH_HISTORY: $D_HASH_HISTORY"
D_HASH_HISTORY_HTML=`echo $D_HASH_HISTORY | sed s/AWR_txt/AWR_html/`
msgd "D_HASH_HISTORY_HTML: $D_HASH_HISTORY_HTML"
run_command_e "mkdir -p $D_HASH_HISTORY_HTML"
run_command "mv *.html $D_HASH_HISTORY_HTML/"
msgi "Done. sql_id_reports.sh"

