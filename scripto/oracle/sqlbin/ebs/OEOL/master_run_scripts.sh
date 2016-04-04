#!/bin/ksh
##############################################################################################################################
#
# Created gverma 22nd Feb 2007 
# 
# This is the master script which calls other scripts. This script asks for apps password once and passes it to 
# other scripts being called internally.
#
##############################################################################################################################

scripts_dir=$1
logfile=master_run_scripts.log

if [ "$scripts_dir" == "" ]; then
  echo "Please specify the directory where the all the scripts have been unzipped or untarred..."
  echo "Usage: $ master_run_scripts.sh <directory>"
  exit 1
fi

if [ "$APPLPTMP" == "" ]; then
   echo "It seems that your environment variable $APPLPTMP is not set... Please source your environment right."
   exit 1
fi

cd $APPLPTMP; 
#
# decided against removing any previous logfiles for keeping history of runs
#[ -f $logfile ] && rm $logfile;

echo "----------------- Starting master_run_scripts.sh at `date`--------------------------------------------------" | tee -a $logfile
echo "The current directory is `pwd` " | tee -a $logfile
echo " Please type in your Apps database password now ..it will not be logged but the value will be visible on the screen: "   | tee -a $logfile
read pwd

echo "Creating auxiliary pl/sql functions now...." | tee -a $logfile
sqlplus apps/$pwd @${scripts_dir}/create_auxiliary_functions.sql ${scripts_dir}

echo "Creating stage 1 WF aggregate data for external tables now..." | tee -a $logfile
${scripts_dir}/run_stage1_wf_data_scripts.sh ${scripts_dir} $pwd 

echo "Creating external tables based on stage 1 WF aggregate flat files ..." | tee -a $logfile
sqlplus apps/$pwd @${scripts_dir}/create_ont_wias_external_tables.sql $APPLPTMP | tee -a $logfile

echo "Creating stage 2 merged OM and WF data for external tables now..." | tee -a $logfile
${scripts_dir}/run_stage2_merge_data_scripts.sh ${scripts_dir} $pwd 

echo "Creating external tables based on stage 2 OM and WF merged flat files ..." | tee -a $logfile
sqlplus apps/$pwd @${scripts_dir}/create_merged_oeoh_oeol_wf_external_table.sql | tee -a $logfile

echo "Updating the Aggregate information in unique_orders..." | tee -a $logfile
sqlplus apps/$pwd @${scripts_dir}/gather_order_aggregate_information.sql | tee -a $logfile

echo "Checking if all the required tables got made right?..." | tee -a $logfile
sqlplus apps/$pwd @${scripts_dir}/do_post_sanity_check.sql | tee -a $logfile
echo "----------------- Done running master_run_scripts.sh at `date`--------------------------------------------------" | tee -a $logfile
