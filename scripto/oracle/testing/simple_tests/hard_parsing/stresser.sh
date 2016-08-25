#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./counter scott tiger DB

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

msgi "ala"
V_PREVIOUS=0
while [ 1 ]
do

  STARTTIME=$(date +%s%3N)
  f_user_execute_sql "SELECT * FROM (select task.task_number tasknumber, task.task_name, task_details taskdetails, task.task_id taskid, task.billable_flag, task.project_id, task.start_date, task.completion_date, task.chargeable_flag, proj.project_number, proj.project_details from pa_online_tasks_v task ,pa_online_projects_v proj where proj.project_id = task.project_id) QRSLT WHERE (TaskId = 164539 and project_id = 43065) ORDER BY tasknumber;" "$USER/$PASS@$DB"
  msgd "$V_EXECUTE_SQL" 
  ENDTIME=$(date +%s%3N)

  V_ELA=`expr ${ENDTIME} - ${STARTTIME}`
  echo "$V_ELA"
  exit 0
done


