# coding: utf8
from cassandra.cluster import Cluster
from cassandra.policies import ConstantReconnectionPolicy, DCAwareRoundRobinPolicy
from json import dumps
from kafka import KafkaProducer
import time
import io
import socket
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.info('This is a log message.')


# pip install python-dateutil

cluster = Cluster(contact_points=['192.168.1.233','192.168.1.77','192.168.1.27'], idle_heartbeat_interval=5,load_balancing_policy=DCAwareRoundRobinPolicy(), reconnection_policy=ConstantReconnectionPolicy(delay=5, max_attempts=50), idle_heartbeat_timeout=5)
cluster.connect_timeout = 30
session = cluster.connect('temperature')

sleep_time = 1 #in seconds

# pip install kafka-python
producer = KafkaProducer(bootstrap_servers=['192.168.1.167:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))


# dict that will store all the temperatures
temp_dict = {}

# test

# /test

# main endless loop
while True:
    
    now = int(time.time())  # time since epoch, in seconds
    now = int(time.time()*1000.0) # time since epoch, + miliseconds

    logging.info("Checking now: %s" % now)

    # that should be gone
    location = socket.gethostname() + "_cpu"

    # reading from CPU temp sensor
    f = open("/sys/class/thermal/thermal_zone0/temp", "r")
    temp_cpu = f.readline()[:-1]
    temp_dict[socket.gethostname() + "_cpu"] = temp_cpu

    logging.info("loop through all the elements in temp_dict and insert them to DB/Kafka")
    for sensor, reading in temp_dict.items():
        logging.info("For: %s reading: %s" % (sensor, reading))
    
        cass_insert = "INSERT INTO temperature.reading (reading_location, reading_date, reading_value, reading_note) values ('" + sensor + "', '" \
                  + str(now) + "', " \
                  + str(reading) + ", '" \
                  + "'" \
                  + ");"
        logging.info("cass_insert: %s" % cass_insert)
        cass_return = session.execute(cass_insert)

        # Now kafka publish
        data = {'reading_location' : sensor, 'reading_date' : str(now), 'reading_value' : str(reading)}
        logging.info("Kafka insert: %s" % data)
        producer.send('temperature', value=data)
                    
    time.sleep(sleep_time)

    exit()


session.shutdown()

