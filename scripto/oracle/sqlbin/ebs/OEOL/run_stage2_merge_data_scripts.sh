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
logfile=run_stage2_merge_data_scripts.log

if [ "$scripts_dir" == "" ] || [ "$pwd" == "" ] ; then
  echo "Usage: $ run_stage2_merge_data_scripts.sh <directory> <password>"
  exit 1
fi

if [ "$APPLPTMP" == "" ]; then
   echo "Are you in the right directory  on the Database server which is part of the value in utl_file_dir init parameter?"
   exit 1
fi

cd $APPLPTMP; [ -f $logfile ] && rm $logfile;

if [ "$APPLPTMP" == "" ]; then
   echo "Are you in the right directory  on the Database server which is part of the value in utl_file_dir init parameter?"
   exit 1
fi

cd $APPLPTMP
echo "The current directory is `pwd` " | tee -a $logfile

echo "The time is `date` now. Running merge_oeoh_oeol_wf.sql now.."  | tee -a  $logfile

sqlplus apps/$pwd @${scripts_dir}/merge_oeoh_oeol_wf.sql &
wait

echo "The time is `date` now. DONE Running  merge_oeoh_oeol_wf.sql now.."  | tee -a   $logfile

echo "The time is `date` now. Paring down  merge_oeoh_oeol_wf.lst now.."  | tee -a   $logfile

grep OEOL merge_oeoh_oeol_wf.lst > temp.lst ; mv temp.lst merge_oeoh_oeol_wf.lst

echo "The time is `date` now. The data file  merge_oeoh_oeol_wf.lst is available now.."  | tee -a   $logfile

ls -l merge_oeoh_oeol_wf.lst  | tee -a   $logfile
