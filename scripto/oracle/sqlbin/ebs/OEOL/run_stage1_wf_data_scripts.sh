#!/bin/ksh
##############################################################################################################################
#
# Created gverma 22nd Feb 2007 
# 
# Run the scripts oeoh_oeol_wias_h_open_closed.sql and oeoh_oeol_wias_open_closed.sql at the same time and put them
# in background. These scripts take time to run. For me, it took 1.5 hrs for them to run simultaneously at the same time
# on a test instance. The timings will vary and are specific to the load running on your instance. It is highly recommended
# to run these scripts first on a recent clone of your PRODUCTION box.
#
##############################################################################################################################

scripts_dir=$1
pwd=$2
logfile=run_stage1_wf_data_scripts.log

if [ "$scripts_dir" == "" ] || [ "$pwd" == "" ] ; then
  echo "Usage: $ run_stage1_wf_data_scripts.sh <directory> <password>"
  exit 1
fi

if [ "$APPLPTMP" == "" ]; then
   echo "Are you in the right directory  on the Database server which is part of the value in utl_file_dir init parameter?"
   exit 1
fi

cd $APPLPTMP; [ -f $logfile ] && rm $logfile;

echo "The current directory is `pwd`" | tee -a $logfile

echo "The time is `date` now. Running oeoh_oeol_wias_h_open_closed.sql and oeoh_oeol_wias_open_closed.sql now.." | tee -a $logfile

sqlplus apps/$pwd @${scripts_dir}/oeoh_oeol_wias_h_open_closed &
sqlplus apps/$pwd @${scripts_dir}/oeoh_oeol_wias_open_closed &
wait

echo "The time is `date` now. DONE Running oeoh_oeol_wias_h_open_closed.sql and oeoh_oeol_wias_open_closed.sql now.."  | tee -a $logfile

echo "The time is `date` now. Paring down oeoh_oeol_wias_h_open_closed.lst and oeoh_oeol_wias_open_closed.lst now.."  | tee -a $logfile

grep OEOL oeoh_oeol_wias_h_open_closed.lst > temp.lst ; mv temp.lst oeoh_oeol_wias_h_open_closed.lst
grep OEOL oeoh_oeol_wias_open_closed.lst > temp.lst ; mv temp.lst oeoh_oeol_wias_open_closed.lst

echo "The time is `date` now. The data files oeoh_oeol_wias_h_open_closed.lst and oeoh_oeol_wias_open_closed.lst are available now.."  | tee -a $logfile

ls -l oeoh_oeol_wias_h_open_closed.lst  | tee -a $logfile
ls -l oeoh_oeol_wias_open_closed.lst  | tee -a $logfile
