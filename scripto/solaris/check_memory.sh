#!/bin/sh

/usr/bin/printf "%-6s %-9s %s\n" "PID" "Total" "Command"
/usr/bin/printf "%-6s %-9s %s\n" "---" "-----" "-------"

for PID in `/usr/bin/ps -e | /usr/bin/awk '$1 ~ /[0-9]+/ { print $1 }'`
do
   CMD=`/usr/bin/ps -o comm -p $PID | /usr/bin/tail -1`
   # Avoid "pmap: cannot examine 0: system process"-type errors
   # by redirecting STDERR to /dev/null
   TOTAL=`/usr/bin/pmap $PID 2>/dev/null | /usr/bin/tail -1 | \
/usr/bin/awk '{ print $2 }'`
   [ -n "$TOTAL" ] && /usr/bin/printf "%-6s %-9s %s\n" "$PID" "$TOTAL" "$CMD"
done | /usr/bin/sort -n -k2
