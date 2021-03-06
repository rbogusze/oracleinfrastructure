#!/bin/bash
echo "Slowlog summary"

FILE_SLOWLOG=$1
if [ -f "$FILE_SLOWLOG" ]; then
  echo "FILE_SLOWLOG: $FILE_SLOWLOG"
else
  echo "Please provide slowlog file as first parameter. Exiting"
  exit 1
fi


# read first line to check for date
DATE_TO_GREP=`head -1 $FILE_SLOWLOG | awk '{print $1" " $2" " $3}'`
echo "DATE_TO_GREP: $DATE_TO_GREP"

cat $FILE_SLOWLOG | grep "$DATE_TO_GREP" > /tmp/slowlog.tmp1

DATE0=`head -1 $FILE_SLOWLOG`
# read from dates file two lines
while read -r DATE1 && read -r DATE2
do 
  #echo "DATE1=$DATE1 and DATE2=$DATE2"; 
  LINES_BETWEEN=`sed -n "/$DATE0/,/$DATE1/p" $FILE_SLOWLOG | wc -l`
  echo "$DATE0 | $LINES_BETWEEN"
  LINES_BETWEEN=`sed -n "/$DATE1/,/$DATE2/p" $FILE_SLOWLOG | wc -l`
  echo "$DATE1 | $LINES_BETWEEN"
  DATE0=$DATE2
done </tmp/slowlog.tmp1
