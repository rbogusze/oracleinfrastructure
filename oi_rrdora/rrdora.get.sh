# rrdora
# version 1.0
# by Raymond Vermeer
#
# Script : rrdora.get.sh
#
# This script creates the rrdfiles
# for the data captured from the
# Oracle databases in the dblistfile
#
# Load the environment file
. /home/orainf/rrdora/rrdora.env

# Check for already running instance
LOCKFILE=/tmp/rrdora.get.sh.lock

# Sanity check
if [ -f $LOCKFILE ]; then
  echo "[alert] $LOCKFILE found, another instance of $0 is already running. Exiting. " >> $BASE/logs/rrdora.get.log
exit 1
fi

# Set lock file
touch $LOCKFILE


# Redirect output to logfile
#exec 1>> $BASE/logs/rrdora.get.log 2>&1
exec 1>> /dev/null 2>&1
echo "(`date`) : Start"

# Check if the dblistfile is passed
# as the first parameter
if [ $# != 1 ]
 then
   echo "Error, dblistfile is missing"
   exit 1
else
   DBLIST=$1
fi

# Check if dblistfile contains any data
[ ! -s $DBLIST ] && exit 0

# Here we go.......
IFS='|'
cat $DBLIST|grep -v "^--"|while read DBNAME UN PW AUTO
do

echo "(`date`) : $DBNAME"
echo "(`date`) : .....up"

#echo "DBNAME: $DBNAME"
#echo "UN: $UN"
#echo "PW: $PW"


# Try to tnsping the server first before launching sqlplus queries
tnsping ${DBNAME}

if [ $? -eq 0 ]; then
  echo "[info] ${DBNAME} found (tnsping). Continuing."
else
  echo "[error] Host ${DBNAME} not found (tnsping). Skiping this host"
  continue
fi

STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/downtime.sql
EOF`

echo "(`date`) : .....Up or down"
if [ "${STRING}" = 'UP' ]
 then
   STRING="N:0"
else
   STRING="N:1"
fi

$RRD/bin/rrdtool update $BASE/$DBNAME/downtime.rrd "$STRING"
echo "(`date`) : ${STRING}"

echo "(`date`) : .....sessions"
STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/sessions.sql
EOF`
echo "$STRING"|grep "^N:" >/dev/null 2>&1
if [ $? = 0 ]
 then
   $RRD/bin/rrdtool update $BASE/$DBNAME/sessions.rrd "$STRING"
   echo "(`date`) : ${STRING}"
else
   echo "${STRING}"
fi

echo "(`date`) : .....cpu"
STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/cpu.sql
EOF`
echo "$STRING"|grep "^N:" >/dev/null 2>&1
if [ $? = 0 ]
 then
   $RRD/bin/rrdtool update $BASE/$DBNAME/cpu.rrd "$STRING"
else
   echo "${STRING}"
fi
echo "(`date`) : ${STRING}"

echo "(`date`) : .....phys_io"
STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/phys_io.sql
EOF`
echo "$STRING"|grep "^N:" >/dev/null 2>&1
if [ $? = 0 ]
 then
   $RRD/bin/rrdtool update $BASE/$DBNAME/phys_io.rrd "$STRING"
else
   echo "${STRING}"
fi
echo "(`date`) : ${STRING}"

echo "(`date`) : .....disk"
echo "skipping, takes too much resources"
#STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
#   @$BASE/sql/disk.sql
#EOF`
#echo "$STRING"|grep "^N:" >/dev/null 2>&1
#if [ $? = 0 ]
# then
#   $RRD/bin/rrdtool update $BASE/$DBNAME/disk.rrd "$STRING"
#else
#   echo "${STRING}"
#fi
#echo "(`date`) : ${STRING}"

echo "(`date`) : .....waits"
STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/waits.sql
EOF`
echo "$STRING"|grep "^N:" >/dev/null 2>&1
if [ $? = 0 ]
 then
   $RRD/bin/rrdtool update $BASE/$DBNAME/waits.rrd "$STRING"
else
   echo "${STRING}"
fi
echo "(`date`) : ${STRING}"

echo "(`date`) : .....tpm"
STRING=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   @$BASE/sql/tpm.sql
EOF`
echo "$STRING"|grep "^N:" >/dev/null 2>&1
if [ $? = 0 ]
 then
   $RRD/bin/rrdtool update $BASE/$DBNAME/tpm.rrd "$STRING"
else
   echo "${STRING}"
fi
echo "(`date`) : ${STRING}"

# Get parameter max_processes and store this in the cnf-file
MAXPROC=`sqlplus -s $UN/$PW@$DBNAME <<EOF
   set pages 0
   set feedback off
   select value from v\\$parameter where name = 'processes';
EOF`
echo "MAXPROC=$MAXPROC" > $BASE/$DBNAME/$DBNAME.cnf
chmod u+x $BASE/$DBNAME/$DBNAME.cnf

done

echo "(`date`) : End"

# Remove lock file
rm -f $LOCKFILE

exit 0
