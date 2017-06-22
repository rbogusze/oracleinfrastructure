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
  echo "SELECT * FROM (select task.task_number tasknumber, task.task_name, task_details taskdetails, task.task_id taskid, task.billable_flag, task.project_id, task.start_date, task.completion_date, task.chargeable_flag, proj.project_number, proj.project_details from pa_online_tasks_v task ,pa_online_projects_v proj where proj.project_id = task.project_id) QRSLT WHERE (TaskId = $V_P1 and project_id = $V_P2) ORDER BY tasknumber;" >> $OUTFILE

  CURRENT=`expr ${CURRENT} + ${STEP}`
done

msgi "Output file can be found in $OUTFILE"
run_command_d "cat $OUTFILE"
