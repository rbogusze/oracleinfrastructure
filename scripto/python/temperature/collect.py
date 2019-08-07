# coding: utf8
from json import dumps
import time
import io
import socket
import logging

#Probably you need this installed
# pip install python-dateutil
# pip install kafka-python
# pip install mysql-connector

#Set DATA pin for DHT-22
DHT = 26

#Sleep time after readings are saved in backend
#sleep_time = 1 #in seconds
#sleep_time = 0.1 #in seconds
sleep_time = 0 #in seconds

#Set backend
backend_mysql = True
backend_cassandra = False
backend_kafka = False

mysql_commit_frequency = 0 # 0 means commit every insert

#logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.info('This is a log message.')

if backend_mysql:
   import mysql.connector

   logging.debug("Setup mysql connection")
   cnx = mysql.connector.connect(
#  host="localhost",
     host="mysql",
     user="remik",
     passwd="remik",
     database="temperature",
     charset='ascii'
   )
   cursor = cnx.cursor()


if backend_cassandra:
   from cassandra.cluster import Cluster
   from cassandra.policies import ConstantReconnectionPolicy, DCAwareRoundRobinPolicy

   cluster = Cluster(contact_points=['192.168.1.90'], idle_heartbeat_interval=5,load_balancing_policy=DCAwareRoundRobinPolicy(), reconnection_policy=ConstantReconnectionPolicy(delay=5, max_attempts=50), idle_heartbeat_timeout=5)
   cluster.connect_timeout = 30
   session = cluster.connect('temperature')


if backend_kafka:
   from kafka import KafkaProducer

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
   logging.debug('DHT temp sensor is active')
   import Adafruit_DHT as dht
else:
   logging.debug('DHT temp sensor not found')


# /test

location = socket.gethostname() + "_cpu"
# files that store temp and humid reading gathered by gather_DHT_sensor_data.py
# just creating them the first time, so I do not have to mess with working around what to do if the do not exist
f1 = open("/tmp/t.txt", "w+")
f1.close()
f1 = open("/tmp/t.txt", "r")
f2 = open("/tmp/h.txt", "w+")
f2.close()
f2 = open("/tmp/h.txt", "r")

# running gather_DHT_sensor_data.py in background, but that actually should be done as another service


# main endless loop
tse_start = int(time.time() - 1)  # time since epoch, in seconds to compute average TPS
tps_start = 0
tps_ratio = 0
total_trans = 0
while True:
    
    now = int(time.time()*1000.0) # time since epoch, + miliseconds


    # reading from CPU temp sensor
    f = open("/sys/class/thermal/thermal_zone0/temp", "r")
    temp_cpu = f.readline()[:-1]
    logging.debug("Checking now: %s" % now)
    temp_dict[location] = temp_cpu
    logging.debug("Storing for: %s value: %s" % (location, temp_cpu))

    # reading from DHT-22 sensor
    if channel_is_on:
       logging.debug("Read Temp and Hum from DHT22 from files")
          
       location = socket.gethostname() + "_temp1"
       t1000 = f1.read()
       f1.seek(0)
       if t1000.isdigit():
          logging.debug("Storing for: %s value: %s" % (location, t1000))
          temp_dict[location] = int(t1000)
       else:
          logging.debug("No value read. Removing from temp_dict for: %s " % (location))
          temp_dict.pop(location, None)

       location = socket.gethostname() + "_humid1"
       h1000 = f2.read()
       f2.seek(0)
       if h1000.isdigit():
          logging.info("Storing for: %s value: %s" % (location, h1000))
          temp_dict[location] = int(h1000)
       else:
          logging.info("No value read. Removing from temp_dict for: %s " % (location))
          temp_dict.pop(location, None)
    

    logging.debug("loop through all the elements in temp_dict and insert them to chosen backend(s)")
    for sensor, reading in temp_dict.items():
        logging.debug("For: %s reading: %s" % (sensor, reading))
        tps_ratio += 1
        total_trans += 1

        if backend_mysql:
           logging.debug("Update to mysql with: %s" % str(reading))
           sql = "INSERT INTO temperature.reading (reading_location, reading_date, reading_value) VALUES (%s, FROM_UNIXTIME(%s/1000), %s)"
           val = (sensor, str(now), str(reading))
           cursor.execute(sql, val)
           if mysql_commit_frequency == 0:
              cnx.commit()
           else:
              # commit every mysql_commit_frequency
              if total_trans%mysql_commit_frequency == 0:
                 logging.debug("Total trans: %s and it is time to commit." % str(total_trans))
                 cnx.commit()


   
        if backend_cassandra: 
           cass_insert = "INSERT INTO temperature.reading (reading_location, reading_date, reading_value, reading_note) values ('" + sensor + "', '" \
                  + str(now) + "', " \
                  + str(reading) + ", '" \
                  + "'" \
                  + ");"
           logging.info("cass_insert: %s" % cass_insert)
           cass_return = session.execute(cass_insert)

        if backend_kafka:
           # Now kafka publish
           data = {'reading_location' : sensor, 'reading_date' : str(now), 'reading_value' : str(reading)}
           logging.info("Kafka insert: %s" % data)
           producer.send('temperature', value=data)
    
    if sleep_time > 0:                
       logging.debug("Sleeping for: %s sec" % sleep_time)
       time.sleep(sleep_time)

    tps_end = int(time.time())  # time since epoch, in seconds
    if (tps_end - tps_start) >= 1:
       logging.debug("tps_ratio: %s total_trans: %s tps_end: %s tse_start: %s" % (tps_ratio, total_trans, tps_end, tse_start))
       logging.info("TPS: %s Average TPS: %s" % (tps_ratio, total_trans/(tps_end - tse_start)))
       tps_start = int(time.time())  # time since epoch, in seconds
       tps_ratio = 0
  

session.shutdown()

