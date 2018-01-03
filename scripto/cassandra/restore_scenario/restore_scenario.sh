#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# That script is to be used ONLY on test env
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

LOG_DIR=/var/tmp/restore_scenario
mkdir -p $LOG_DIR

START_TIME=$(date +'%s')
msgi "$0 Start."


F_TMP=/tmp/restore_scenario.tmp

# Functions
# ---------

# cqlsh sanity check
f_cqlsh_sanity_check()
{
  msgb "${FUNCNAME[0]} Beginning."

  msgd "Picking one docker to execute commands"
  V_DOCKER=`echo $V_DOCKER_LIST | awk -F"," '{print $1}'`

  msgd "check if I can properly login to cqlsh"
  msgd "V_DOCKER: $V_DOCKER"
  msgd "V_CQLSHRC: $V_CQLSHRC"
  msgd "E_CQLSH: $E_CQLSH"

  msgd "Construct docker cqlsh executable command based of whether V_CQLSHRC was set"
  if [ -z $V_CQLSHRC ]; then
    msgd "No V_CQLSHRC set"
    E_CQLSH="docker exec $V_DOCKER cqlsh"
  else
    msgd "V_CQLSHRC set, including that in E_CQLSH"
    E_CQLSH="docker exec $V_DOCKER cqlsh --cqlshrc=$V_CQLSHRC"
  fi
  msgd "E_CQLSH: $E_CQLSH"

  check_parameter $V_DOCKER
  check_parameter $E_CQLSH

  V_TEST_RAW=`$E_CQLSH -e "desc keyspaces;"` 
  msgd "V_TEST_RAW: $V_TEST_RAW"
  V_TEST=`echo $V_TEST_RAW | grep system | wc -l`
  msgd "V_TEST: $V_TEST"
  # when it fails it goes like:
  # Connection error: ('Unable to connect to any servers', {'127.0.0.1': error(111, "Tried connecting to [('127.0.0.1', 9042)]. Last error: Connection refused")})
  # when it works it goes like
  # system_auth    remik1  remik4              system_traces system_schema  system  system_distributed

  if [ "$V_TEST" -gt 0 ]; then
    msgd "Connection works"
  else
    msge "Connection does not work."
    msge "$V_TEST_RAW"
    msge "maybe you need to provide --cqlshrc parameter which point to file in docker with credentials. Exiting."
    exit 1
  fi

  msgd "Construct docker cqlsh executable command based of whether V_CQLSHRC was set"
  if [ -z $V_CQLSHRC ]; then
    msgd "No V_CQLSHRC set"
    E_CQLSH="docker exec $V_DOCKER cqlsh"
  else
    msgd "V_CQLSHRC set, including that in E_CQLSH"
    E_CQLSH="docker exec $V_DOCKER cqlsh --cqlshrc=$V_CQLSHRC"
  fi
  msgd "E_CQLSH: $E_CQLSH"

  msgd "Construct docker sh execution command"
  E_DOCKER="docker exec $V_DOCKER"
  msgd "E_DOCKER: $E_DOCKER"


  msgb "${FUNCNAME[0]} Finished."
} #f_cqlsh_sanity_check


# $1 - keyspace name


f_determine_cassandra_version()
{
  msgb "${FUNCNAME[0]} Beginning."
  check_parameter $E_DOCKER
 
  F_TMP_DV=/tmp/restore.wrap.tmp.dw
  run_command_e "$E_DOCKER nodetool version > $F_TMP_DV 2>&1"
  run_command_d "cat $F_TMP_DV"
  V_CASSANDRA_VERSION=`cat $F_TMP_DV | awk '{print $2}' | awk -F"." '{print $1"."$2}'`
  msgd "V_CASSANDRA_VERSION: $V_CASSANDRA_VERSION"

  case $V_CASSANDRA_VERSION in
  "2.1")
    msgd "Cassandra version $V_CASSANDRA_VERSION"
    Q_KEYSPACE_LIST="select keyspace_name from system.schema_keyspaces;"
    Q_KEYSPACE_EXISTS="select keyspace_name from system.schema_keyspaces where keyspace_name" 
    Q_TABLE_EXISTS="select keyspace_name, columnfamily_name from system.schema_columnfamilies where keyspace_name"
    Q_TABLE_EXISTS_AND="and columnfamily_name"
    Q_TABLE_LIST="select columnfamily_name from system.schema_columnfamilies where keyspace_name" 
    V_BACKUP_SCRIPT="~/scripto/docker/test_poc/cassandra_backup_docker2.sh"
    Q_INDEX_LIST="DO ME!"
    ;;
  "3.0")
    msgd "Cassandra version $V_CASSANDRA_VERSION"
    Q_KEYSPACE_LIST="select keyspace_name from system_schema.keyspaces;"
    Q_KEYSPACE_EXISTS="select keyspace_name from system_schema.keyspaces where keyspace_name" 
    Q_TABLE_EXISTS="select keyspace_name, table_name from system_schema.tables where keyspace_name"
    Q_TABLE_EXISTS_AND="and table_name"
    Q_TABLE_LIST="select table_name from system_schema.tables where keyspace_name"
    V_BACKUP_SCRIPT="~/scripto/docker/test_poc/cassandra_backup_docker.sh"
    Q_INDEX_LIST="select keyspace_name, table_name, index_name, kind, options from system_schema.indexes;"
    ;;
  *)
    echo "Unknown cassandra version!!! Exiting."
    exit 1
    ;;
  esac

  msgd "Setting following variables as dependent on cassandra version"
  msgd "Q_KEYSPACE_EXISTS: $Q_KEYSPACE_EXISTS"
  msgd "Q_TABLE_EXISTS: $Q_TABLE_EXISTS"
  msgd "Q_TABLE_EXISTS_AND: $Q_TABLE_EXISTS_AND"

  msgb "${FUNCNAME[0]} Finished."
} #f_determine_cassandra_version

f_execute_file()
{
  msgb "${FUNCNAME[0]} Beginning."
  V_FILE_TO_EXECUTE=$1
  check_parameter $V_FILE_TO_EXECUTE
  check_file $V_FILE_TO_EXECUTE

  msgd "Using global variables"
  msgd "V_DOCKER: $V_DOCKER"

  run_command_d "cat $V_FILE_TO_EXECUTE"

  msgd "Copy file to docker"
  run_command_e "docker cp $V_FILE_TO_EXECUTE $V_DOCKER:/tmp"
  
  msgd "Executing script"
  run_command_e "$E_CQLSH -f /tmp/$V_FILE_TO_EXECUTE"

  msgb "${FUNCNAME[0]} Finished."
} #f_execute_file




f_check_phase()
{
  msgb "${FUNCNAME[0]} Beginning."
  # Using global parameters
  msgd "Q_KEYSPACE_LIST: $Q_KEYSPACE_LIST"
  check_parameter $Q_KEYSPACE_LIST

  # Local variables
  F_CHECK_OUTPUT=$1
  msgd "F_CHECK_OUTPUT: $F_CHECK_OUTPUT"
  check_parameter $F_CHECK_OUTPUT
  F_TMP_CP=/tmp/restore_scenario.tmp.check_phase
  V_COUNT_ROWS="TRUE"


  # Actual execution
  run_command "rm -f $F_CHECK_OUTPUT"

  msgd "Desc of all keyspaces"
  msgd "  - prepare a list of existing keyspaces"
  run_command_e "$E_CQLSH -e '$Q_KEYSPACE_LIST' > $F_TMP_CP"
  run_command_d "cat $F_TMP_CP"
  run_command_e "cat $F_TMP_CP | grep -v 'keyspace_name' | grep -v '\-\-\-' | grep -v 'rows)' | grep -v '^ *$' > $F_TMP_CP.1" 
  run_command_d "cat $F_TMP_CP.1"
  msgd "Loop through all keyspaces and do a describe"
  while read V_KEYSPACE
  do
    msgd "Desc keyspace for: $V_KEYSPACE"
    run_command_e "$E_CQLSH -e 'desc \"${V_KEYSPACE}\";' >> $F_CHECK_OUTPUT"
  done < $F_TMP_CP.1

  echo "Count table rows:" >> $F_CHECK_OUTPUT
  msgd "Counting rows if desired"
  msgd "V_COUNT_ROWS: $V_COUNT_ROWS" 
  if [ "$V_COUNT_ROWS" = "TRUE" ]; then
    msgd "Counting rows"
    echo "| KEYSPACE.TABLENAME | NR_ROWS |" >> $F_CHECK_OUTPUT
    msgd "Loop through all keyspaces and count rows in tables "
    while read V_KEYSPACE <&8
    do
      msgd "Counting rows in tables for keyspace: $V_KEYSPACE"
      msgd "Q_TABLE_LIST: $Q_TABLE_LIST"
      check_parameter $Q_TABLE_LIST
    
      # TMP construct a query
      Q_TABLE_LIST_RUN="$Q_TABLE_LIST = ^${V_KEYSPACE}^;"
      msgd "Q_TABLE_LIST_RUN: $Q_TABLE_LIST_RUN"
      Q_TABLE_LIST_RUN2=`echo $Q_TABLE_LIST_RUN | tr "^" "'"`
      msgd "Q_TABLE_LIST_RUN2: $Q_TABLE_LIST_RUN2"
      $E_CQLSH -e "$Q_TABLE_LIST_RUN2" > $F_TMP_CP.2
      run_command_d "cat $F_TMP_CP.2"
      V_TMP_C=`cat $F_TMP_CP.2 | grep '(0 rows)' | wc -l`
      msgd "V_TMP_C: $V_TMP_C"
      if [ "$V_TMP_C" -eq 1 ]; then
        msgd "There are no tables in this keyspace. Continuing."
        continue
      fi 

      run_command_e "cat $F_TMP_CP.2 | grep -v 'columnfamily_name' | grep -v 'table_name' | grep -v '\-\-\-' | grep -v 'rows)' | grep -v '^ *$' > $F_TMP_CP.3" 
      run_command_d "cat $F_TMP_CP.3"
      msgd "Loop through all the tables in keyspace $V_KEYSPACE" 
      while read V_TABLENAME <&7
      do
        msgd "WIP Checking if it makes sense to count rows"
        
        msgd "Counting rows for $V_KEYSPACE.$V_TABLENAME"
        $E_CQLSH -e "copy \"$V_KEYSPACE\".$V_TABLENAME to '/dev/null'" > $F_TMP_CP.4
        #run_command_d "cat $F_TMP_CP.4"
        #V_TMP_P=`cat $F_TMP_CP.4 | grep "^Processed"`  # this behaves oddly, there are multiple CR with no NL and awk picks the first line
        V_TMP_P=`cat $F_TMP_CP.4 | grep 'rows exported'`
        msgd "V_TMP_P: $V_TMP_P"
        V_NR_ROWS=`echo $V_TMP_P | awk '{print $1}'`
        msgd "V_NR_ROWS: $V_NR_ROWS"

        echo "| $V_KEYSPACE.$V_TABLENAME | $V_NR_ROWS |" >> $F_CHECK_OUTPUT
      done 7< $F_TMP_CP.3
    done 8< $F_TMP_CP.1
    echo "| Done.   |" >> $F_CHECK_OUTPUT
  else
    msgd "Skipping rows count"
  fi  

  msgd "List indexes"
  echo "Indexes:" >> $F_CHECK_OUTPUT
  msgd "Q_INDEX_LIST: $Q_INDEX_LIST"
  check_parameter $Q_INDEX_LIST
  run_command_e "$E_CQLSH -e '$Q_INDEX_LIST' >> $F_CHECK_OUTPUT"
 
   

  msgi "Raw results under: ${F_CHECK_OUTPUT}.raw"
  msgd "Filtering out some of the stats, as this is natural that they fluctuate"
  run_command_e "cp $F_CHECK_OUTPUT ${F_CHECK_OUTPUT}.raw"
  run_command_e "cat ${F_CHECK_OUTPUT}.raw | grep -v '| system.compaction_history' | grep -v '| system.sstable_activity' | grep -v '| system.size_estimates' > $F_CHECK_OUTPUT"
  msgi "Filtered results under: $F_CHECK_OUTPUT"

  msgi "If master results file is provided I check my results with the master"
  if [ ! -z "$F_MASTER_RESULTS" ]; then
    msgd "Master file was provided: $F_MASTER_RESULTS. Doing the comparison" 
    msgd "F_MASTER_RESULTS: $F_MASTER_RESULTS"
    check_file $F_MASTER_RESULTS
    run_command_e "diff $F_MASTER_RESULTS $F_CHECK_OUTPUT"
  else
    msgd "No master results file was provided. Doing no checking."
  fi

  # too much output, even for debug
  #run_command_d "cat $F_CHECK_OUTPUT"
  msgb "${FUNCNAME[0]} Finished."
} #f_check_phase

f_backup_phase()
{
  msgb "${FUNCNAME[0]} Beginning."
  # Using global variables
  check_parameter $V_BACKUP_SCRIPT
  msgd "V_BACKUP_SCRIPT: $V_BACKUP_SCRIPT"

  D_BACKUP="/var/lib/container_data/backup"
  msgd "D_BACKUP: $D_BACKUP"
  check_directory $D_BACKUP

  msgd "Loop through all the nodes and execute backup script depending on the Cassandra version"
  echo $V_DOCKER_LIST | tr "," "\n" > $F_TMP.2
  run_command_d "cat $F_TMP.2"
  while read LINE
  do
    msgi "Running backup for: $LINE"
    V_NODE_STR=`echo $LINE | sed 's/cassandra_//'`
    run_command_e "$V_BACKUP_SCRIPT $V_NODE_STR >> /var/log/cassandra/backup_${V_NODE_STR}.log"
  done < $F_TMP.2

  msgd "Backups should be found under: $D_BACKUP by default"
  msgd "For the lack of any better idea I just pick the latest backups assuming that they were created during this exercise."
  echo $V_DOCKER_LIST | tr "," "\n" > $F_TMP.2
  run_command_d "cat $F_TMP.2"
  V_BACKUP_FILES=""
  while read LINE
  do
    msgi "Finding backup for: $LINE"
    check_directory "$D_BACKUP/$LINE"
    V_TMP=`ls -t $D_BACKUP/$LINE | head -1`
    msgd "V_TMP: $V_TMP"
    check_file "$D_BACKUP/$LINE/$V_TMP"
    V_BACKUP_FILES=${V_BACKUP_FILES},$D_BACKUP/$LINE/$V_TMP
  done < $F_TMP.2
  msgd "V_BACKUP_FILES: $V_BACKUP_FILES"
  msgd "remove leading colon"
  V_TMP=`echo "$V_BACKUP_FILES" | sed 's/^,//'`
  V_BACKUP_FILES=$V_TMP
  msgd "V_BACKUP_FILES: $V_BACKUP_FILES"

  msgb "${FUNCNAME[0]} Finished."
} #f_backup_phase

f_restore_phase()
{
  msgb "${FUNCNAME[0]} Beginning."

  msgd "Using global variables"
  msgd "V_DOCKER: $V_DOCKER"
  msgd "V_BACKUP_FILES: $V_BACKUP_FILES"
  check_parameter $V_BACKUP_FILES

  msgd "Converting backup path to relative from the point of a docker"
  V_BACKUP_FILES_DOCKER=`echo $V_BACKUP_FILES | sed 's/container_data/cassandra/g'`

  run_command_e "cd ~/scripts"
  run_command_e "./cassandra_restore_docker.sh --docker $V_DOCKER --cqlshrc $V_CQLSHRC --keyspace _all_ --backup_files $V_BACKUP_FILES_DOCKER --restore_temp_dir /tmp"

  
# WIP

  msgb "${FUNCNAME[0]} Finished."
} #f_restore_phase

f_compare_checks()
{
  msgb "${FUNCNAME[0]} Beginning."
  F_BEFORE=$1
  F_AFTER=$2

  run_command_e "cat $F_BEFORE | grep -v 'system.compaction_history' | grep -v 'system.sstable_activity' > $F_BEFORE.1 "
  run_command_e "cat $F_AFTER | grep -v 'system.compaction_history' | grep -v 'system.sstable_activity' > $F_AFTER.1 "

  msgd "If there are no differences, then it is good."
  run_command_e "diff $F_BEFORE.1 $F_AFTER.1"

  msgb "${FUNCNAME[0]} Finished."
} #f_compare_checks


f_template()
{
  msgb "${FUNCNAME[0]} Beginning."

  msgb "${FUNCNAME[0]} Finished."
} #b_template


# Validate Input/Environment
# --------------------------
# Great sample getopt implementation by Cosimo Streppone
# https://gist.github.com/cosimo/3760587#file-parse-options-sh
SHORT='hd:r:c:d:p:r:m:'
LONG='help,docker_list:,cqlshrc:,create_phase_file:,destroy_phase_file:,phase:,phase_parameter:,master_results:'
OPTS=$( getopt -o $SHORT --long $LONG -n "$0" -- "$@" )

if [ $? -gt 0 ]; then
    # Exit early if argument parsing failed
    printf "Error parsing command arguments\n" >&2
    exit 1
fi
eval set -- "$OPTS"
while true; do
    case "$1" in
            -h|--help) usage;;
            -d|--docker_list) V_DOCKER_LIST="$2"; shift 2;;
            -r|--cqlshrc) V_CQLSHRC="$2"; shift 2;;
            -c|--create_phase_file) V_CREATE_PHASE_FILE="$2"; shift 2;;
            -d|--destroy_phase_file) V_DESTROY_PHASE_FILE="$2"; shift 2;;
            -p|--phase) V_PHASE="$2"; shift 2;;
            -r|--phase_parameter) V_PHASE_PARAMETER="$2"; shift 2;;
            -m|--master_results) F_MASTER_RESULTS="$2"; shift 2;;
            --) shift; break;;
            *) printf "Error processing command arguments\n" >&2; exit 1;;
    esac
done

# # # Sanity checks

if [ -z "$V_PHASE" ]; then
  msgd "There is no phase parameter provided, executeing all phases"
  V_PHASE=all
else
  msgd "There IS phase parameter provided, executeing just the phase provided."
fi

msgd "V_PHASE: $V_PHASE"
msgd "V_PHASE_PARAMETER: $V_PHASE_PARAMETER"

msgd "Actual execution"
f_cqlsh_sanity_check
f_determine_cassandra_version

case $V_PHASE in
  "all")

    f_execute_file $V_CREATE_PHASE_FILE 
    run_command "sleep 5"
    f_check_phase $F_TMP.check_before
    f_backup_phase
    f_execute_file $V_DESTROY_PHASE_FILE
    f_restore_phase
    f_check_phase $F_TMP.check_after
    f_compare_checks $F_TMP.check_before $F_TMP.check_after

    ;;
  "f_check_phase")
    msgd "V_PHASE_PARAMETER: $V_PHASE_PARAMETER"
    check_parameter V_PHASE_PARAMETER
    f_check_phase $V_PHASE_PARAMETER
    ;;
  *)
    msge "Unknown phase!!! Exiting."
    exit 1
    ;;
esac

msgi "Script took $(($(date +'%s') - $START_TIME)) seconds to run."
msgi "$0 Done."

