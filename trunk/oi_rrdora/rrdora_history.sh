#/bin/bash
# Copy rrdora files from the last 8 hours to create a history
#
#
DIR_NAME=`date -I`
DIR_PATH=/var/www/html/rrdora_history
mkdir -p $DIR_PATH/${DIR_NAME}

# Copy the content of rrdora
cp -r /var/www/html/rrdora/* $DIR_PATH/${DIR_NAME}

# Delete the 2hour and other useless pictures
find $DIR_PATH/${DIR_NAME} -name 2hour* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name 2week* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name 4hour* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name 6month* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name 8hour* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name day* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name month* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name week* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name year* -type f -print -exec rm {} \;
find $DIR_PATH/${DIR_NAME} -name index.html -type f -print -exec rm {} \;
