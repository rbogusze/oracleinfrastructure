#/bin/bash
# Copy rrdora files from the last 8 hours to create a history
#
#
DIR_NAME=`date -I`
mkdir -p /var/www/rrdora_history/${DIR_NAME}

# Copy the content of rrdora
cp -r /var/www/rrdora/* /var/www/rrdora_history/${DIR_NAME}

# Delete the 2hour and other useless pictures
find /var/www/rrdora_history/${DIR_NAME} -name 2hour* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name 2week* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name 4hour* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name 6month* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name 8hour* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name day* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name month* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name week* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name year* -type f -print -exec rm {} \;
find /var/www/rrdora_history/${DIR_NAME} -name index.html -type f -print -exec rm {} \;
