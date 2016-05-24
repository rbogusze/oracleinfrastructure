#!/bin/bash
#$Id$
#

# Load usefull functions                                                     
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then                         
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "     
  exit 1                                                                     
else                                                                         
  . $HOME/scripto/bash/bash_library.sh                                       
fi                                                                           
                                                                             
#INFO_MODE=DEBUG                                                              

# To set number of days back, just set the last literal

./prepare_exec_cmd.sh | awk '{print "./bulk_generate.sh "$2" "$3" "$5" "$6" 12"}'


