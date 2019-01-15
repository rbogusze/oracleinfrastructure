# coding: utf8
from cassandra.cluster import Cluster
from cassandra.policies import ConstantReconnectionPolicy, DCAwareRoundRobinPolicy
import time
import io
import socket

# $ sudo pip install python-dateutil

# main endless loop

cluster = Cluster(contact_points=['192.168.1.233','192.168.1.236','192.168.1.27'], idle_heartbeat_interval=5,load_balancing_policy=DCAwareRoundRobinPolicy(), reconnection_policy=ConstantReconnectionPolicy(delay=5, max_attempts=50), idle_heartbeat_timeout=5)
cluster.connect_timeout = 30
session = cluster.connect('temperature')

sleep_time = 1 #in seconds

# test

# /test

while True:
    
    now = int(time.time())  # time since epoch, in seconds
    now = int(time.time()*1000.0) # time since epoch, + miliseconds

    print "Checking now: %s" % now

    location = socket.gethostname() + "_cpu"

    f = open("/sys/class/thermal/thermal_zone0/temp", "r")
    temp_cpu = f.readline()[:-1]
    
    
    cass_insert = "INSERT INTO temperature.reading (reading_location, reading_date, reading_value, reading_note) values ('" + location + "', '" \
                  + str(now) + "', " \
                  + str(temp_cpu) + ", '" \
                  + "'" \
                  + ");"
    #print "cass_insert: %s" % cass_insert
    cass_return = session.execute(cass_insert)
                    
    time.sleep(sleep_time)


session.shutdown()





