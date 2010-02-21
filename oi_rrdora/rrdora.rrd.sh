# rrdora
# version 1.0
# by Raymond Vermeer
#
# Script : rrdora.rrd.sh
#
# This script creates the rrdfiles
# for the data captured from the
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
exec 1>> $BASE/logs/rrdora.rrd.log 2>&1
echo "(`date`) : Start"

# Generate a new index.html file 
mkdir -p ${GIF}
cat ${BASE}/html/head.html > ${GIF}/index.html
cat ${BASE}/html/head2.html > ${GIF}/index2.html

# Check if dblistfile contains any data
[ ! -s $DBLIST ] && exit 0

# Here we go.......
TABLE_ROW_COUNTER=0
IFS=#
cat $DBLIST|grep -v "^--"|while read DBNAME UN PW AUTO
do
[ ! -d $BASE/$DBNAME ] && mkdir -p $BASE/$DBNAME

# Create the rddfile for storing downtime information
if [ ! -f $BASE/$DBNAME/downtime.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/downtime.rrd --step 60\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:downtime:GAUGE:650:0:1
fi

# Create the rddfile for storing session information
if [ ! -f $BASE/$DBNAME/sessions.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/sessions.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:system:GAUGE:650:0:U                                                    \
  DS:active:GAUGE:650:0:U                                                    \
  DS:inactive:GAUGE:650:0:U
fi

# Create the rddfile for storing cpu information
if [ ! -f $BASE/$DBNAME/cpu.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/cpu.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:parse:DERIVE:650:0:U                                                   \
  DS:recursive:DERIVE:650:0:U                                               \
  DS:rest:DERIVE:650:0:U
fi

# Create the rddfile for storing physical i/o information
if [ ! -f $BASE/$DBNAME/phys_io.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/phys_io.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:reads:DERIVE:650:0:U                                                   \
  DS:writes:DERIVE:650:0:U                                                  \
  DS:redos:DERIVE:650:0:U
fi

# Create the rddfile for storing diskspace information
if [ ! -f $BASE/$DBNAME/disk.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/disk.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:used:GAUGE:650:0:U                                                      \
  DS:free:GAUGE:650:0:U
fi

# Create the rddfile for storing waits information
if [ ! -f $BASE/$DBNAME/waits.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/waits.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:buffer_busy:DERIVE:650:0:U                                             \
  DS:controlfile_IO:DERIVE:650:0:U                                          \
  DS:dbf_par_read:DERIVE:650:0:U                                            \
  DS:dbf_multi_read:DERIVE:650:0:U                                          \
  DS:dbf_seq_read:DERIVE:650:0:U                                            \
  DS:dbf_par_write:DERIVE:650:0:U                                           \
  DS:dbf_single_write:DERIVE:650:0:U                                        \
  DS:directpath_IO:DERIVE:650:0:U                                           \
  DS:free_buffer:DERIVE:650:0:U                                             \
  DS:latch_free:DERIVE:650:0:U                                              \
  DS:log_buffer_space:DERIVE:650:0:U                                        \
  DS:lf_par_write:DERIVE:650:0:U                                            \
  DS:lf_seq_read:DERIVE:650:0:U                                             \
  DS:lf_single_write:DERIVE:650:0:U                                         \
  DS:lf_switch:DERIVE:650:0:U                                               \
  DS:lf_sync:DERIVE:650:0:U                                                 \
  DS:sqlnet:DERIVE:650:0:U
fi


# Create the rddfile for storing tpm information
if [ ! -f $BASE/$DBNAME/tpm.rrd ]
 then
  $RRD/bin/rrdtool create $BASE/$DBNAME/tpm.rrd --step 60	\
  RRA:AVERAGE:0.5:1:600                                                      \
  RRA:AVERAGE:0.5:6:700                                                      \
  RRA:AVERAGE:0.5:24:775                                                     \
  RRA:AVERAGE:0.5:288:797                                                    \
  RRA:MAX:0.5:1:600                                                          \
  RRA:MAX:0.5:6:700                                                          \
  RRA:MAX:0.5:24:775                                                         \
  RRA:MAX:0.5:288:797                                                        \
  RRA:MIN:0.5:1:600                                                          \
  RRA:MIN:0.5:6:700                                                          \
  RRA:MIN:0.5:24:775                                                         \
  RRA:MIN:0.5:288:797                                                        \
  DS:tpm:DERIVE:650:0:U                                                   
fi

  #DS:tpm:DERIVE:650:0:U                                                   
  #DS:tpm:GAUGE:650:0:U                                                   
# Create the rddfile for storing physical i/o information


# Put rrdora.dblist in index.html 
echo "    <option value=${DBNAME}>${DBNAME}</option>" >> ${GIF}/index.html

# Put rrdora.dblist in index2.html
echo "    <td>${DBNAME}<br><img src=\"${DBNAME}\" name=${DBNAME}></td>"  >> ${GIF}/index2_mid1.html
if [ ${TABLE_ROW_COUNTER} -eq 1 ]; then
  echo "</tr><tr>" >> ${GIF}/index2_mid1.html
  TABLE_ROW_COUNTER=0
else
  TABLE_ROW_COUNTER=1
fi

echo "  var fname = \"${DBNAME}\" + \"/\" + document.frm.period.options[document.frm.period.selectedIndex].value + \"_\" + document.frm.statname.options[document.frm.statname.selectedIndex].value + \".gif\"" >> ${GIF}/index2_mid2.html
echo "  document.${DBNAME}.src = fname" >> ${GIF}/index2_mid2.html

done

# Finalize the index.html file 
cat ${BASE}/html/tail.html >> ${GIF}/index.html

# Finalize the index2.html file
cat ${GIF}/index2_mid1.html >> ${GIF}/index2.html
cat ${BASE}/html/mid2.html >> ${GIF}/index2.html
cat ${GIF}/index2_mid2.html >> ${GIF}/index2.html
cat ${BASE}/html/tail2.html >> ${GIF}/index2.html

rm -f ${GIF}/index2_mid1.html
rm -f ${GIF}/index2_mid2.html

echo "(`date`) : End"

exit 0
