# coding: utf8
import time
import io
import socket
import csv

# $ sudo pip install python-dateutil

with open('/home/pi/test.csv') as fp:
    for line in fp:
#        print line
        csv = line.split(",")
        fixed_timestamp = ((int(csv[1]) + 600042015) * 1000) + 1547540000000
#        print csv[0] + "," + str(fixed_timestamp) + "," + csv[2] + "," + csv[3]
        print "INSERT INTO temperature.reading (reading_location, reading_date, reading_value, reading_note) values ('" + csv[0] + "', '" + str(fixed_timestamp) + "', " + csv[3].rstrip() + ",'" + csv[2] + "');"

                                                
#        exit(0)
    
    






