#!/bin/bash
# Load usefull functions
if [ ! -f ${HOME}/scripto/bash/bash_library.sh ]; then
  echo "[error] ${HOME}/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . ${HOME}/scripto/bash/bash_library.sh
fi


