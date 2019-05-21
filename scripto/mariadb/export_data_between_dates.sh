#!/bin/bash
#$Id: _base_script_block.wrap,v 1.1 2012-05-07 13:47:27 remik Exp $
#

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

START_DATE=$1
END_DATE=$2


INFO_MODE=DEBUG
#INFO_MODE=INFO

check_parameter $MYSQL_USERNAME
check_parameter $MYSQL_PASSWORD

check_parameter $START_DATE
check_parameter $END_DATE

CSV_EXPORT_DIR="/home/csv_export"
check_directory $CSV_EXPORT_DIR

# exp filename
CSV_FILENAME=`echo "${START_DATE}_${END_DATE}" | tr -d " " | tr -d ":"`
msgd "CSV_FILENAME: $CSV_FILENAME"


msgi "Exporting data to $CSV_EXPORT_DIR"
#mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h localhost -P 4306 sensors -e "select count(*) from sensors.temperature;"
mysql -u $MYSQL_USERNAME -p$MYSQL_PASSWORD -h localhost -P 4306 sensors -e "select * from sensors.temperature where reading_date > '$START_DATE' and reading_date < '$END_DATE' INTO OUTFILE '$CSV_EXPORT_DIR/temperature_${CSV_FILENAME}.csv' FIELDS TERMINATED BY ',' ENCLOSED BY '\"' LINES TERMINATED BY '\n';"



