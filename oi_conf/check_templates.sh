#!/bin/bash
# 
# Checks if init file is in accordace to the template set as 'orainfDbInitTemplate' attribute
# 

INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

CONFIG_FILE=/tmp/check_templates.tmp

# 
$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitTemplate=*)" "['cn', 'orainfDbInitTemplate']" > $CONFIG_FILE

check_file $CONFIG_FILE
run_command_d "cat $CONFIG_FILE"

while read LINE
do
  echo $LINE
  #Sanity checks
  if [[ "$LINE" = \#* ]]; then
    msgd "Line is a comment, skipping"      
    continue
  else
    msgd "Line is NOT a comment. Procceding"
  fi

  if [ -z "$LINE" ]; then
    msgd "Enpty line, skipping."
    continue
  fi

  # variables setup
  CN=`echo ${LINE} | gawk '{ print $1 }'`
  msgd "CN: $CN"
  F_TEMPLATE=`echo ${LINE} | gawk '{ print $2 }'`
  msgd "F_TEMPLATE: $F_TEMPLATE"



done < $CONFIG_FILE

