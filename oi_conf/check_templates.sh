#!/bin/bash
# 
# Checks if init file is in accordace to the template set as 'orainfDbInitTemplate' attribute
# 

#INFO_MODE=DEBUG

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

CONFIG_FILE=/tmp/check_templates.tmp
D_TEMPLATE=/home/orainf/oi_conf/templates
D_INITFILE=/home/orainf/conf_repo
D_TMP=/tmp

# 
$HOME/scripto/perl/ask_ldap.pl "(orainfDbInitTemplate=*)" "['cn', 'orainfDbInitTemplate']" > $CONFIG_FILE

check_file $CONFIG_FILE
run_command_d "cat $CONFIG_FILE"

check_directory $D_TEMPLATE
check_directory $D_INITFILE

# Removing temporary files
rm -f $D_TMP/oracle_infra_OK.txt
rm -f $D_TMP/oracle_infra_ERROR.txt
rm -f $D_TMP/oracle_infra_CHANGE.txt


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

  V_TEMPLATE=$D_TEMPLATE/$F_TEMPLATE
  msgd "V_TEMPLATE: $V_TEMPLATE"
  check_file $V_TEMPLATE

  V_INITFILE=$D_INITFILE/$CN/dbinit.txt
  msgd "V_INITFILE: $V_INITFILE"
  check_file $V_INITFILE

  #filter init file and remove leading *.
  cat $V_INITFILE | sed 's/^[^.]*\.//' > $D_TMP/init.tmp
  V_INITFILE=$D_TMP/init.tmp
  msgd "V_INITFILE: $V_INITFILE"
  check_file $V_INITFILE


  msgd "Checking if all the parameters that should have value are set"
  # To do that I scan the template in search for check_if_* parameters and make sure that they are set in init
  # I do not check their values, but only the existence
  while read TEMPLATE_LINE
  do
    #echo -n "."
    msgri "."
    TEMPLATE_ACTION=`echo $TEMPLATE_LINE | awk -F":" '{ print $1 }'`
    TEMPLATE_PAR=`echo $TEMPLATE_LINE | awk -F":" '{ print $2 }'`
    TEMPLATE_VALUE=`echo $TEMPLATE_LINE | awk -F":" '{ print $3 }'`
    msgd "TEMPLATE_LINE: $TEMPLATE_LINE"
    msgd "TEMPLATE_ACTION: $TEMPLATE_ACTION"
    if [ `echo $TEMPLATE_ACTION | grep check_if_ | wc -l` -gt 0 ]; then
      if [ `cat $V_INITFILE | grep "^${TEMPLATE_PAR}=" | wc -l` -lt 1 ]; then
        echo "parameter should be set: $TEMPLATE_PAR" >> $D_TMP/oracle_infra_ERROR.txt
        msgd "Parameter should be set: $TEMPLATE_PAR"
        # I make the $TEMPLATE_VALUE uppercase to be consisten with how Oracle shows then
        #  during show parameter
        TEMPLATE_VALUE=`echo $TEMPLATE_VALUE | tr '[a-z]' '[A-Z]'`
        echo "alter system set $TEMPLATE_PAR=$TEMPLATE_VALUE scope=spfile sid='*';" >> $D_TMP/oracle_infra_CHANGE.txt
      else
        msgd "Parameter is set in the init, this is all I wanted to check."
      fi
    fi

  done < $V_TEMPLATE


  echo
  msgd "Loop through the init file and analyse the contents"
  while read INIT_LINE
  do
    #echo -n "."
    msgri "."
    # Get init parameter from $INIT_LINE
    INIT_PAR=`echo $INIT_LINE | awk -F"=" '{ print $1 }' | awk -F"." '{print $2}'`
    INIT_VALUE=`echo $INIT_LINE | awk -F"=" '{ print $2 }' | awk -F"#" '{print $1}' | tr '[A-Z]' '[a-z]' `
    #echo $INIT_PAR; echo $INIT_VALUE
    msgd "INIT_PAR: $INIT_PAR"
    msgd "INIT_VALUE: $INIT_VALUE"

    # Search the template for instructions
    # Make sure there is 1 or 0 lines with instructions
    TEMPLATE_CHECK=`cat $V_TEMPLATE | grep ":$INIT_PAR:" | wc -l`
    if [ "$TEMPLATE_CHECK" -gt 1 ]; then
      msge "There are two instructions or more in template regarding the same init parameter."
      msge "It should not happen. Exiting."
      cat $V_TEMPLATE | grep ":$INIT_PAR:"
      exit 1
    fi

    TEMPLATE_LINE=`cat $V_TEMPLATE | grep ":$INIT_PAR:"`
    TEMPLATE_ACTION=`echo $TEMPLATE_LINE | awk -F":" '{ print $1 }'`
    TEMPLATE_PAR=`echo $TEMPLATE_LINE | awk -F":" '{ print $2 }'`
    TEMPLATE_VALUE=`echo $TEMPLATE_LINE | awk -F":" '{ print $3 }'`
    TEMPLATE_COMMENT=`echo $TEMPLATE_LINE | awk -F":" '{ print $4 }'`
    #echo $TEMPLATE_LINE; echo $TEMPLATE_ACTION; echo $TEMPLATE_PAR; echo $TEMPLATE_VALUE; echo $TEMPLATE_COMMENT
    msgd "TEMPLATE_ACTION: $TEMPLATE_ACTION"

    case $TEMPLATE_ACTION in
    "ignore")
      #echo "OK. Ignoring parameter $INIT_PAR"
      echo "ignoring: $INIT_LINE" >> $D_TMP/oracle_infra_OK.txt
      ;;
    "check_if_equal")
      if [ ! "$INIT_VALUE" = "$TEMPLATE_VALUE" ]; then
        echo "value not equal: $INIT_LINE, should be: $TEMPLATE_VALUE" >> $D_TMP/oracle_infra_ERROR.txt
        echo "alter system set $INIT_PAR=$TEMPLATE_VALUE scope=spfile sid='*';" >> $D_TMP/oracle_infra_CHANGE.txt
      else
        echo "value equal: $INIT_LINE" >> $D_TMP/oracle_infra_OK.txt
      fi 
      ;;
    "check_if_less")
      if [ "$INIT_VALUE" -gt "$TEMPLATE_VALUE" ]; then
        echo "value too large: $INIT_LINE, should be: $TEMPLATE_VALUE" >> $D_TMP/oracle_infra_ERROR.txt
        echo "alter system set $INIT_PAR=$TEMPLATE_VALUE scope=spfile sid='*';" >> $D_TMP/oracle_infra_CHANGE.txt
      else
        echo "value correct: $INIT_LINE" >> $D_TMP/oracle_infra_OK.txt
      fi 
      ;;
    "check_if_more")
      if [ "$INIT_VALUE" -lt "$TEMPLATE_VALUE" ]; then
        echo "value too small: $INIT_LINE, should be: $TEMPLATE_VALUE" >> $D_TMP/oracle_infra_ERROR.txt
        echo "alter system set $INIT_PAR=$TEMPLATE_VALUE scope=spfile sid='*';" >> $D_TMP/oracle_infra_CHANGE.txt
      else
        echo "value correct: $INIT_LINE" >> $D_TMP/oracle_infra_OK.txt
      fi 
      ;;
    "check_if_set")
      echo "value set: $INIT_LINE" >> $D_TMP/oracle_infra_OK.txt
      ;;
    "do_not_set")
      echo "parameter should not be set: $INIT_LINE" >> $D_TMP/oracle_infra_ERROR.txt
      echo "alter system reset $INIT_PAR scope=spfile sid='*';" >> $D_TMP/oracle_infra_CHANGE.txt
      ;;
    *)
      echo "Unknown parameter for template: $INIT_PAR"
      exit 0
      ;;
   esac

  done < $V_INITFILE

  #echo ""

  if [ -f $D_TMP/oracle_infra_ERROR.txt ]; then
    msgi "You are on $USERNAME at `uname -n`"
    msge "Parameters with wrong values or that should not be set for DB: $ORACLE_SID"
    cat $D_TMP/oracle_infra_ERROR.txt | sort
  fi

  if [ -f $D_TMP/oracle_infra_CHANGE.txt ]; then
    msgi "To change the configuration according to template you can issue:"
    # for hidden parameters include them into "" to work
    while read LINE
    do
      if [ `echo "$LINE" | awk '{ print $4 }' | grep '^_'` ]; then
        echo "$LINE" | awk '{ print $1 " " $2 " " $3 " \"" $4 "\" " $5 " " $6 }'
      else
        echo $LINE
      fi
    done < $D_TMP/oracle_infra_CHANGE.txt
    #cat $D_TMP/oracle_infra_CHANGE.txt | sort
  fi
  msgi "Done"


done < $CONFIG_FILE

