#!/bin/bash
#
# This will just execute bunch of script to report on changes in the last week
#
cd ${HOME}/oi_conf 
./prepare_for_gather_data.sh
./prepare_for_gather_data_sql.sh
./gather_data.sh > /tmp/gather_data.log
./gather_data_sql.sh > /tmp/gather_data_sql.log
./report_changes.sh dbinit.txt > /tmp/report_changes.log
./report_changes.sh opatch_lsinventory.txt >> /tmp/report_changes.log
cat /tmp/report_changes.log | mail -s "basic env changes at `date -I`" remigiusz.boguszewicz@gmail.com
