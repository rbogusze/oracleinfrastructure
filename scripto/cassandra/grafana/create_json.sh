#!/bin/bash
#$Id: o,v 1.1 2012-05-07 13:47:27 remik Exp $
#
# Usage:
# $ ./create_json.sh "host1 host2 host3"

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

INFO_MODE=DEBUG
#INFO_MODE=INFO

D_TEMPLATES=~/scripto/cassandra/grafana/templates

A_HOSTS=("$@")
A_HOSTS_COUNT=${#A_HOSTS[@]}

A_REFID=("A" "B" "C" "D" "E" "F" "G" "H" "I" "J")

msgd "A_HOSTS_COUNT: $A_HOSTS_COUNT"

echo "ala ma kota"
#F_OUT=/tmp/dashboard_${RANDOM}.json
#F_OUT=/tmp/dashboard.json
F_OUT=~/Downloads/dashboard.json
rm -f $F_OUT
msgi "Output file: $F_OUT"

msgd "Take header"
F_HEADER=$D_TEMPLATES/header.json
check_file "$F_HEADER"
cat $F_HEADER >> $F_OUT

msgd "Iterate through the actual graphs"
msgd "Get the list of sections"
for i in `find $D_TEMPLATES | grep -v footer.json | grep -v header.json | grep -v foot | grep -v head | grep json`
do
  msgd "$i"
  msgd "Get the filename"
  F_SECTION_MAIN=`basename $i`
  msgd "F_SECTION_MAIN: $F_SECTION_MAIN"
  check_file "$D_TEMPLATES/$F_SECTION_MAIN"
  msgd "Setup head and tail files for sections"
  F_SECTION_HEAD=`echo $F_SECTION_MAIN | awk -F"." '{print $1"_head.json"}'`
  msgd "F_SECTION_HEAD: $F_SECTION_HEAD"
  check_file "$D_TEMPLATES/$F_SECTION_HEAD"
  F_SECTION_FOOT=`echo $F_SECTION_MAIN | awk -F"." '{print $1"_foot.json"}'`
  msgd "F_SECTION_FOOT: $F_SECTION_FOOT"
  check_file "$D_TEMPLATES/$F_SECTION_FOOT"

  msgd "Add head"
  cat $D_TEMPLATES/$F_SECTION_HEAD >> $F_OUT
  msgd "Iterate though the hosts"
 
  CURRENT=0 
  for V_HOST in "${A_HOSTS[@]}"
  do
    echo $V_HOST
    msgd "A_HOSTS: ${A_HOSTS[$CURRENT]}"
    cat $D_TEMPLATES/$F_SECTION_MAIN | sed -e "s/###HOST###/${A_HOSTS[$CURRENT]}/" | sed -e "s/###REFID###/${A_REFID[$CURRENT]}/" >> $F_OUT
    CURRENT=`expr ${CURRENT} + 1`
    if [ $CURRENT -ge $A_HOSTS_COUNT ]; then
      msgd "This is last iteration, no comma"
    else
      msgd "Entering comma after section"
      echo "," >> $F_OUT
    fi
  done
  msgd "Add foot"
  cat $D_TEMPLATES/$F_SECTION_FOOT >> $F_OUT

done


msgd "Take footer"
F_FOOTER=$D_TEMPLATES/footer.json
check_file "$F_FOOTER"
cat $F_FOOTER >> $F_OUT

msgi "Output file: $F_OUT"




