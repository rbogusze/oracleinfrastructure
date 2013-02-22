#!/bin/bash
#$Id: check_password.sh,v 1.1 2012-05-07 13:32:52 remik Exp $
#
# This script will check for trivial passwords used to autenticate OS users
# 

# Load usefull functions
if [ ! -f $HOME/scripto/bash/bash_library.sh ]; then
  echo "[error] $HOME/scripto/bash/bash_library.sh not found. Exiting. "
  exit 1
else
  . $HOME/scripto/bash/bash_library.sh
fi

#INFO_MODE=DEBUG
F_PASSWORDS=$HOME/scripto/solaris/check_password/easy_passwords.txt
check_file $F_PASSWORDS
F_USERS=/tmp/check_password_${USERNAME}_${ORACLE_SID}.txt
F_TMP=/tmp/check_password_${USERNAME}_${ORACLE_SID}.tmp
msgd "F_USERS: $F_USERS"

#
# Running commands
#
msgd "Checking for expect binaries"
if [ -f /opt/csw/bin/expect ]; then
  msgd "Expect binaries found. OK."
  F_EXPECT_SCRIPT=check_password_csw.exp
elif [ -f /opt/sfw/bin/expect ]; then
  msgd "Expect binaries found. OK."
  F_EXPECT_SCRIPT=check_password_sfw.exp
else
  msge "Expect binaries NOT found. Exiting."
  exit 1
fi
msgd "F_EXPECT_SCRIPT: $F_EXPECT_SCRIPT"

msgd "Checking if user aaa exists"
TMP_CHK=`cat /etc/passwd | grep ^aaa:`
if [ "${TMP_CHK}" ]; then
  msge "User aaa exists, should be deleted."
else
  msgd "User aaa does not exists. OK"
fi

msgd "Preparing list of OS userd that will be challenged for easy passwords"
cat /etc/passwd | $GREP -v '/bin/false' | $GREP -e '/bin/bash' -e '/sbin/sh' > $F_USERS

msgd "Loop through users and try trivial passwords"
exec 4<> $F_USERS
while read V_USERS <&4
do
  msgd "V_USERS: $V_USERS"
  V_USERS=`echo $V_USERS | awk -F":" '{ print $1 }'`
  msgd "V_USERS: $V_USERS"
  exec 3<> $F_PASSWORDS
  while read V_PASSWORD  <&3
  do 
  {
    msgd "V_PASSWORD: $V_PASSWORD"
    msgd "Running $F_EXPECT_SCRIPT $V_USERS $V_PASSWORD"
    ./$F_EXPECT_SCRIPT $V_USERS $V_PASSWORD > $F_TMP 2>&1
    V_TMP=`cat $F_TMP | wc -l`
    msgd "V_TMP: $V_TMP"
    if [ "${V_TMP}" -gt 6 ]; then
      msgd "ERROR, looks like I am able to run ps -ef when I switch the user, which means I can log in"
      msge "I am able to login to user: $V_USERS using trivial password: $V_PASSWORD which should not happen"
    else
      msgd "OK, less than 5 rows returned, not able to log in"
    fi
  }  
  done #$F_PASSWORDS
done  #$F_USERS





