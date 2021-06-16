#!/bin/bash

INFO_MODE='INFO'

# Runs the command provided as parameter.
# Does exit if the command fails.
# Sends error message if the command fails.

run_command_e()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    msg "\"$1\""
  fi

  # Determining if we are running in a debug mode. If so wait for any key before eval
  if [ -n "$DEBUG_MODE" ]; then
    if [ "$DEBUG_MODE" -eq "1" ] ; then
      echo "[debug wait] Press any key if ready to run the printed command"
      read
    fi
  fi

  eval $1
  if [ $? -ne 0 ]; then
    msg "[critical] An error occured during: \"$1\". Exiting NOW."
    exit 1
  fi
  return 0
} #run_command_e

msg()
{
  echo "| `/bin/date '+%Y%m%d %H:%M:%S'` $1"
}

check_variable()
{
  if [ -z "$1" ]; then
    msg "[ check_variable ] Provided variable ${2} is empty. Exiting. " ${RECIPIENTS}
    exit 1
  fi
}

# Checking if script was run from terminal - then I use colors
#   or is it run from crontab, where those colors create just weird characters
if [ -t 0 ]; then
    V_INTERACTIVE=1
else
    V_INTERACTIVE=0
fi

msgi()
{
  if [ "$INFO_MODE" = "INFO" ] || [ "$INFO_MODE" = "DEBUG" ] ; then
    echo -n "| `/bin/date '+%Y%m%d %H:%M:%S'` "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[32m'; fi
    echo -n "[info]     "
    if [ "$V_INTERACTIVE" -eq 1 ]; then echo -e -n '\E[39m\E[49m'; fi
    echo "$1"
  fi
}


run_command_e "ls -ld ~/sre-bigdata/redis"
check_variable "$R_PORT"
check_variable "$R_MASTER_NAME"
check_variable "$R_SENTINEL_PORT"
check_variable "$R_VERSION"
check_variable "$R_PASS"
check_variable "$R_SHUTDOWN_COMMAND"
check_variable "$R_MASTER_IP"
check_variable "$R_MAXMEMORY"

msgi "Prepare etc directory"
run_command_e "sudo mkdir -p /etc/redis/${R_VERSION}_${R_MASTER_NAME}"

msgi "Populate Redis configuration from template"
run_command_e "sed -e \"s/R_MASTER_NAME/$R_MASTER_NAME/g\" -e \"s/R_PORT/$R_PORT/g\" -e \"s/R_SENTINEL_PORT/$R_SENTINEL_PORT/g\" -e \"s/R_VERSION/$R_VERSION/g\" -e \"s/R_PASS/$R_PASS/g\" -e \"s/R_SHUTDOWN_COMMAND/$R_SHUTDOWN_COMMAND/g\" -e \"s/R_MAXMEMORY/$R_MAXMEMORY/g\" ~/sre-bigdata/redis/templates/${R_VERSION}/redis.conf | sudo tee /etc/redis/${R_VERSION}_${R_MASTER_NAME}/${R_PORT}.conf"

msgi "Populate Sentinel configuration from template"
run_command_e "sed -e \"s/R_MASTER_NAME/$R_MASTER_NAME/g\" -e \"s/R_PORT/$R_PORT/g\" -e \"s/R_SENTINEL_PORT/$R_SENTINEL_PORT/g\" -e \"s/R_VERSION/$R_VERSION/g\" -e \"s/R_PASS/$R_PASS/g\" -e \"s/R_MASTER_IP/$R_MASTER_IP/g\" ~/sre-bigdata/redis/templates/${R_VERSION}/sentinel.conf | sudo tee /etc/redis/${R_VERSION}_${R_MASTER_NAME}/sentinel_${R_SENTINEL_PORT}.conf"

msgi "Populate Redis init.d start/stop script from template"
run_command_e "sed -e \"s/R_MASTER_NAME/$R_MASTER_NAME/g\" -e \"s/R_PORT/$R_PORT/g\" -e \"s/R_VERSION/$R_VERSION/g\" -e \"s/R_PASS/$R_PASS/g\" -e \"s/R_SHUTDOWN_COMMAND/$R_SHUTDOWN_COMMAND/g\" ~/sre-bigdata/redis/templates/${R_VERSION}/init_redis | sudo tee /etc/init.d/redis_${R_PORT}"

msgi "Populate Sentinel init.d start/stop script from template"
run_command_e "sed -e \"s/R_MASTER_NAME/$R_MASTER_NAME/g\" -e \"s/R_SENTINEL_PORT/$R_SENTINEL_PORT/g\" -e \"s/R_VERSION/$R_VERSION/g\" -e \"s/R_PASS/$R_PASS/g\" -e \"s/R_SHUTDOWN_COMMAND/$R_SHUTDOWN_COMMAND/g\" ~/sre-bigdata/redis/templates/${R_VERSION}/init_sentinel | sudo tee /etc/init.d/sentinel_${R_SENTINEL_PORT}"

msgi "Make init scripts executable"
run_command_e "sudo chmod 755 /etc/init.d/redis_${R_PORT}"
run_command_e "sudo chmod 755 /etc/init.d/sentinel_${R_SENTINEL_PORT}"

msgi "Prepare working directory"
run_command_e "sudo mkdir -p /apps/redis/${R_VERSION}_${R_MASTER_NAME}/log/"
run_command_e "sudo mkdir -p /apps/redis/${R_VERSION}_${R_MASTER_NAME}/${R_PORT}/"
run_command_e "sudo mkdir -p /apps/redis/${R_VERSION}_${R_MASTER_NAME}/${R_SENTINEL_PORT}/"

msgi "Please continue with documentation form: Make init scripts auto-executed on OS boot"
