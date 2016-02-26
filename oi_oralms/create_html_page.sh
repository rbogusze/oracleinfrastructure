#!/bin/bash
# Create html page with last 1000 lines of alert logs

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

tail -n 200 /tmp/global_alert.log | tac > /tmp/global_alert.log_for_html

V_TABLE=0

cat ~/scripto/html/header.txt
while read LINE
do
  # Make green time stamp
  if [[ "$LINE" =~ "^... ... .. ..:..:.. ... ...." ]] || [[ "$LINE" =~ "^... ... .. ..:..:.. .... ...." ]]; then
    echo "<font color=\"green\">"
  fi

  if [[ "$LINE" =~ "ORA-....." ]] || [[ "$LINE" =~ "terminated" ]] || [[ "$LINE" =~ "Corrupt" ]]; then
    echo "<font color=\"red\">"
  fi

  if [[ "$LINE" =~ "Completed: ALTER DATABASE OPEN" ]] || [[ "$LINE" =~ "Completed: ALTER DATABASE CLOSE NORMAL" ]] || [[ "$LINE" =~ "Completed: ALTER DATABASE DISMOUNT" ]]; then
    echo "<font color=\"yellow\">"
  fi

  if [[ "$LINE" =~ "cannot allocate new log" ]] || [[ "$LINE" =~ "Checkpoint not complete" ]]; then
    echo "<font color=\"magenta\">"
  fi

  if [[ "$LINE" =~ "\#\#\#" ]] || [[ "$LINE" =~ "warning" ]] || [[ "$LINE" =~ "gather_monitor" ]]; then
    echo "<font color=\"cyan\">"
  fi

  if [[ "$LINE" =~ "-------" ]] && [[ "$V_TABLE" -eq 0 ]] ; then
    V_TABLE=1
    echo "<table border=1>"
    continue
  fi

  if [[ "$LINE" =~ "\|" ]]; then
    echo "<tr><td>"
    echo "$LINE" | sed -e 's/|/<\/td><td>/g'
    echo "</td></tr>"
    continue
  fi



  if [[ "$LINE" =~ "-------" ]] && [[ "$V_TABLE" -eq 1 ]] ; then
    V_TABLE=0
    echo "</table>"
    continue
  fi

  echo "$LINE" 
  echo "</font><BR>"
done < /tmp/global_alert.log_for_html
cat ~/scripto/html/footer.txt 

