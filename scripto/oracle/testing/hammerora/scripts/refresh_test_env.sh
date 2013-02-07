#!/bin/ksh
#$Id: refresh_test_env.sh,v 1.5 2009/11/25 12:42:36 remikcvs Exp $
#

if [ -z "$1" ]; then
  echo "Provide the import file name as parameter. Exiting. " 
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "file does not exists. Exiting. " 
  exit 1
fi

sqlplus <<EOF
connect / as sysdba
DROP USER "TPCC" CASCADE;
CREATE USER "TPCC"  PROFILE "DEFAULT" 
    IDENTIFIED BY "tpcc" DEFAULT TABLESPACE "TPCCTAB" 
    TEMPORARY TABLESPACE "TEMP" 
    ACCOUNT UNLOCK;
GRANT UNLIMITED TABLESPACE TO "TPCC";
GRANT "CONNECT" TO "TPCC";
GRANT "RESOURCE" TO "TPCC";
grant read, write on directory dmpdir to tpcc;
EOF

echo "[info] If this is standurd exp dump it should have extention .dmp"
echo "[info] If this is a data pump dump it should have extention .dp"

V_EXTENTION=`echo $1 | awk -F"." '{ print $NF }'`
case $V_EXTENTION in
  "dmp")
    echo "[info] This is standurd exp dump"
    time imp tpcc/tpcc file=$1 log=tpcc.ilog FEEDBACK=1000000 BUFFER=5000000
    ;;
  "dp")
    echo "[info] This is a data pump dump"
    echo "[info] Directory named dmpdir should point to current directory"
    time impdp tpcc/tpcc DUMPFILE=$1 DIRECTORY=dmpdir parallel=10
    ;;
  *)
    echo "Unknown dump. Exiting"
    exit 1
    ;;
esac



sqlplus <<EOF
connect / as sysdba
alter system switch logfile;
alter system checkpoint;
connect perfstat/perfhal
execute statspack.snap;
EOF


#exec dbms_stats.gather_schema_stats(ownname=> 'TPCC', estimate_percent=> 90, cascade=> TRUE );
#exec dbms_stats.gather_schema_stats('TPCC');

