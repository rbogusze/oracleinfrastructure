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

cat ~/scripto/html/header.txt
while read LINE
do
  echo "$LINE" 
  echo "<BR>"
done < /tmp/global_alert.log_for_html
cat ~/scripto/html/footer.txt 

