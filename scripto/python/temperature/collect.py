# coding: utf8
from cassandra.cluster import Cluster
from cassandra.policies import ConstantReconnectionPolicy, DCAwareRoundRobinPolicy
from json import dumps
from kafka import KafkaProducer
import time
import io
import socket
import logging
import Adafruit_DHT as dht

#Set DATA pin for DHT-22
DHT = 26

#logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
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

# checking is something is connected to PIN ponted by DHT variable (by default 4)
import RPi.GPIO as GPIO

channel = DHT

# Setup your channel
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(channel, GPIO.IN)

# To test the value of a pin use the .input method
channel_is_on = GPIO.input(channel)  # Returns 0 if OFF or 1 if ON

if channel_is_on:
   logging.info('DHT temp sensor is active')
else:
   logging.info('DHT temp sensor not found')


# /test

# main endless loop
while True:
    
    now = int(time.time())  # time since epoch, in seconds
    now = int(time.time()*1000.0) # time since epoch, + miliseconds


    # reading from CPU temp sensor
    location = socket.gethostname() + "_cpu"
    f = open("/sys/class/thermal/thermal_zone0/temp", "r")
    temp_cpu = f.readline()[:-1]
    logging.info("Checking now: %s" % now)
    temp_dict[location] = temp_cpu
    logging.info("Storing for: %s value: %s" % (location, temp_cpu))

    # reading from DHT-22 sensor
    if channel_is_on:
       logging.info("Read Temp and Hum from DHT22")
       h,t = dht.read_retry(dht.DHT22, DHT)
       #Print Temperature and Humidity on Shell window
       #logging.info('Temp={0:0.1f}*C  Humidity={1:0.1f}%'.format(t,h)) #this was causing some errors?
       location = socket.gethostname() + "_temp1"
       logging.info("Storing for: %s value: %s" % (location, int(t*1000)))
       temp_dict[location] = int(t*1000)
       location = socket.gethostname() + "_humid1"
       logging.info("Storing for: %s value: %s" % (location, int(h*1000)))
       temp_dict[location] = int(h*1000)

    

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
                    
    logging.info("Sleeping for: %s sec" % sleep_time)
    time.sleep(sleep_time)



session.shutdown()

