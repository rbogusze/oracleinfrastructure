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

# read from dates file two lines
while read -r DATE1 && read -r DATE2
do 
  echo "DATE1=$DATE1 and DATE2=$DATE2"; 
  sed -n "/$DATE1/,/$DATE2/p" $FILE_SLOWLOG | wc -l
done </tmp/slowlog.tmp1
