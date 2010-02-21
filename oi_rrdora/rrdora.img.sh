# rrdora  
# version 1.0
# by Raymond Vermeer
#
# Script : rrdora.img.sh
#
# This script creates images
# from the data captured from the
# Oracle databases in the dblistfile
#
# Load the environment file
. /home/orainf/oi_rrdora/rrdora.env

# Check if the dblistfile is passed 
# as the first parameter
if [ $# != 1 ]
 then
   echo "Error, dblistfile is missing"
   exit 1
else
   DBLIST=$1
fi

# Redirect output to logfile
exec 1>> ${BASE}/logs/rrdora.img.log 2>&1
#exec 1>> /dev/null 2>&1
echo "(`date`) : Start"

# Check if dblistfile contains any data
[ ! -s $DBLIST ] && exit 0

# Here we go.......
IFS=\#
cat $DBLIST|grep -v "^--"|while read DBNAME UN PW AUTO
do
echo "(`date`) : ${DBNAME}"
[ ! -d ${GIF}/${DBNAME} ] && mkdir -p ${GIF}/${DBNAME}

# Get database configuration for showing MAX_PROCESSES
. $BASE/$DBNAME/$DBNAME.cnf

##########################################################################################
echo "(`date`) : .....downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_downtime.gif --start -7200 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_downtime.gif --start -14400 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_downtime.gif --start -28800 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_downtime.gif --start -43200 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_downtime.gif --start -86400 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_downtime.gif --start -604800 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_downtime.gif --start -1314000 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_downtime.gif --start -2628000 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_downtime.gif --start -15768000 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_downtime.gif --start -31536000 \
         --y-grid none \
         --height 20 \
         --no-legend \
         --lower-limit 0 \
         --upper-limit 1 \
         --unit 1 \
         --title="Downtime last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/downtime.rrd:downtime:AVERAGE \
         AREA:A\#FF0000:"Downtime"

##########################################################################################
echo "(`date`) : .....sessions"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_sessions.gif --start -7200 \
         --lower-limit 0 \
         --unit 1 \
         --vertical-label max=$MAXPROC \
         --title="Number of sessions last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_sessions.gif --start -14400 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_sessions.gif --start -28800 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         HRULE:${MAXPROC}\#FF0000:Maximum \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_sessions.gif --start -43200 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_sessions.gif --start -86400 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_sessions.gif --start -604800 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_sessions.gif --start -1314000 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_sessions.gif --start -2628000 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_sessions.gif --start -15768000 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_sessions.gif --start -31536000 \
         --lower-limit 0 \
         --unit 1 \
         --title="Number of sessions (max=$MAXPROC) last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         DEF:A=${BASE}/${DBNAME}/sessions.rrd:system:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/sessions.rrd:active:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/sessions.rrd:inactive:AVERAGE \
         AREA:A\#6699FF:"System" \
         STACK:B\#FF9900:"Active" \
         STACK:C\#330099:"Idle" 

##########################################################################################
echo "(`date`) : .....cpu"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_cpu.gif --start -7200 \
         --lower-limit 0 \
         --title="CPU usage last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_cpu.gif --start -14400 \
         --lower-limit 0 \
         --title="CPU usage last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_cpu.gif --start -28800 \
         --lower-limit 0 \
         --title="CPU usage last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_cpu.gif --start -43200 \
         --lower-limit 0 \
         --title="CPU usage last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_cpu.gif --start -86400 \
         --lower-limit 0 \
         --title="CPU usage last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_cpu.gif --start -604800 \
         --lower-limit 0 \
         --title="CPU usage last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_cpu.gif --start -1314000 \
         --lower-limit 0 \
         --title="CPU usage last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_cpu.gif --start -2628000 \
         --lower-limit 0 \
         --title="CPU usage last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_cpu.gif --start -15768000 \
         --lower-limit 0 \
         --title="CPU usage last 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_cpu.gif --start -31536000 \
         --lower-limit 0 \
         --title="CPU usage last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/cpu.rrd:parse:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/cpu.rrd:recursive:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/cpu.rrd:rest:AVERAGE \
         AREA:A\#6699FF:"Parse" \
         STACK:B\#FF9900:"Recursive" \
         STACK:C\#330099:"Other"

##########################################################################################
echo "(`date`) : .....phys_io"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_pio.gif --start -7200 \
         --lower-limit 0 \
         --title="Physical IO last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_pio.gif --start -14400 \
         --lower-limit 0 \
         --title="Physical IO last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_pio.gif --start -28800 \
         --lower-limit 0 \
         --title="Physical IO last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_pio.gif --start -43200 \
         --lower-limit 0 \
         --title="Physical IO last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_pio.gif --start -86400 \
         --lower-limit 0 \
         --title="Physical IO last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_pio.gif --start -604800 \
         --lower-limit 0 \
         --title="Physical IO last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_pio.gif --start -1314000 \
         --lower-limit 0 \
         --title="Physical IO last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_pio.gif --start -2628000 \
         --lower-limit 0 \
         --title="Physical IO last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_pio.gif --start -15768000 \
         --lower-limit 0 \
         --title="Physical IO last 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_pio.gif --start -31536000 \
         --lower-limit 0 \
         --title="Physical IO last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "IO/sec" \
         DEF:A=${BASE}/${DBNAME}/phys_io.rrd:reads:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/phys_io.rrd:writes:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/phys_io.rrd:redos:AVERAGE \
         LINE2:A\#6699FF:"Datafile reads" \
         LINE2:B\#FF9900:"Datafile writes" \
         LINE2:C\#330099:"Redo writes"

##########################################################################################
echo "(`date`) : .....disk"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_disk.gif --start -7200 \
         --lower-limit 0 \
         --title="Diskspace usage last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_disk.gif --start -14400 \
         --lower-limit 0 \
         --title="Diskspace usage last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_disk.gif --start -28800 \
         --lower-limit 0 \
         --title="Diskspace usage last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_disk.gif --start -43200 \
         --lower-limit 0 \
         --title="Diskspace usage last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_disk.gif --start -86400 \
         --lower-limit 0 \
         --title="Diskspace usage last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free" 
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_disk.gif --start -604800 \
         --lower-limit 0 \
         --title="Diskspace usage last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_disk.gif --start -1314000 \
         --lower-limit 0 \
         --title="Diskspace usage last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_disk.gif --start -2628000 \
         --lower-limit 0 \
         --title="Diskspace usage last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_disk.gif --start -15768000 \
         --lower-limit 0 \
         --title="Diskspace usage last 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_disk.gif --start -31536000 \
         --lower-limit 0 \
         --title="Diskspace usage last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Gigabytes" \
         DEF:A=${BASE}/${DBNAME}/disk.rrd:used:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/disk.rrd:free:AVERAGE \
         AREA:A\#FF9900:"Used" \
         STACK:B\#330099:"Free"

##########################################################################################
echo "(`date`) : .....waits"
$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_waits.gif --start -7200 \
         --lower-limit 0 \
         --title="Wait events last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                " 

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_waits.gif --start -14400 \
         --lower-limit 0 \
         --title="Wait events last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_waits.gif --start -28800 \
         --lower-limit 0 \
         --title="Wait events last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_waits.gif --start -43200 \
         --lower-limit 0 \
         --title="Wait events last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_waits.gif --start -86400 \
         --lower-limit 0 \
         --title="Wait events last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_waits.gif --start -604800 \
         --lower-limit 0 \
         --title="Wait events last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_waits.gif --start -1314000 \
         --lower-limit 0 \
         --title="Wait events last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_waits.gif --start -2628000 \
         --lower-limit 0 \
         --title="Wait events last month (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                " 

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_waits.gif --start -15768000 \
         --lower-limit 0 \
         --title="Wait events last 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                " 

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_waits.gif --start -31536000 \
         --lower-limit 0 \
         --title="Wait events last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "msec" \
         DEF:A=${BASE}/${DBNAME}/waits.rrd:buffer_busy:AVERAGE \
         DEF:B=${BASE}/${DBNAME}/waits.rrd:controlfile_IO:AVERAGE \
         DEF:C=${BASE}/${DBNAME}/waits.rrd:dbf_par_read:AVERAGE \
         DEF:D=${BASE}/${DBNAME}/waits.rrd:dbf_multi_read:AVERAGE \
         DEF:E=${BASE}/${DBNAME}/waits.rrd:dbf_seq_read:AVERAGE \
         DEF:F=${BASE}/${DBNAME}/waits.rrd:dbf_par_write:AVERAGE \
         DEF:G=${BASE}/${DBNAME}/waits.rrd:dbf_single_write:AVERAGE \
         DEF:H=${BASE}/${DBNAME}/waits.rrd:directpath_IO:AVERAGE \
         DEF:I=${BASE}/${DBNAME}/waits.rrd:free_buffer:AVERAGE \
         DEF:J=${BASE}/${DBNAME}/waits.rrd:latch_free:AVERAGE \
         DEF:K=${BASE}/${DBNAME}/waits.rrd:log_buffer_space:AVERAGE \
         DEF:L=${BASE}/${DBNAME}/waits.rrd:lf_par_write:AVERAGE \
         DEF:M=${BASE}/${DBNAME}/waits.rrd:lf_seq_read:AVERAGE \
         DEF:N=${BASE}/${DBNAME}/waits.rrd:lf_single_write:AVERAGE \
         DEF:O=${BASE}/${DBNAME}/waits.rrd:lf_switch:AVERAGE \
         DEF:P=${BASE}/${DBNAME}/waits.rrd:lf_sync:AVERAGE \
         DEF:Q=${BASE}/${DBNAME}/waits.rrd:sqlnet:AVERAGE \
         AREA:A\#0000FF:"Buffer busy waits       " \
         STACK:B\#7FFF00:"Controlfile IO         " \
         STACK:C\#FF4040:"Dbfile parallel read   " \
         STACK:D\#98F5FF:"Dbfile multiblock read " \
         STACK:E\#E317D0:"Dbfile sequential read " \
         STACK:F\#4876FF:"Dbfile parallel write  " \
         STACK:G\#FF9900:"Dbfile single write    " \
         STACK:H\#FFD700:"Directpath IO          " \
         STACK:I\#4B0082:"Free buffer            " \
         STACK:J\#20B2AA:"Latch free             " \
         STACK:K\#C0FF3E:"Log buffer space       " \
         STACK:L\#FFFF00:"Logfile parallel write " \
         STACK:M\#FFE1FF:"Logfile sequential read" \
         STACK:N\#63B8FF:"Logfile single write   " \
         STACK:O\#FF9900:"Logfile switch         " \
         STACK:P\#8E388E:"Logfile sync           " \
         STACK:Q\#191970:"SQL Net                "


##########################################################################################
echo "(`date`) : .....tps"

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2hour_tps.gif --start -7200 \
         --lower-limit 0 --units-exponent 0 \
         --title="tps in last 2 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"

$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/4hour_tps.gif --start -14400 \
         --lower-limit 0 \
         --title="tps in last 4 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/8hour_tps.gif --start -28800 \
         --lower-limit 0 \
         --title="tps in last 8 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/12hour_tps.gif --start -43200 \
         --lower-limit 0 \
         --title="tps in last 12 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/day_tps.gif --start -86400 \
         --lower-limit 0 \
         --title="tps in last 24 hours (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/week_tps.gif --start -604800 \
         --lower-limit 0 \
         --title="tps in last week (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/2week_tps.gif --start -1314000 \
         --lower-limit 0 \
         --title="tps in last 2 weeks (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/month_tps.gif --start -2628000 \
         --lower-limit 0 \
         --title="tps in last mont (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/6month_tps.gif --start -15768000 \
         --lower-limit 0 \
         --title="tps in last 6 months (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"


$RRD/bin/rrdtool graph ${GIF}/${DBNAME}/year_tps.gif --start -31536000 \
         --lower-limit 0 \
         --title="tps in last year (`date '+%d-%m-%Y %H:%M:%S'`)" \
         --vertical-label "Nr" \
         DEF:A=${BASE}/${DBNAME}/tps.rrd:tps:AVERAGE \
         LINE2:A\#330099:"tp5min"

done

echo "(`date`) : End"

exit 0
