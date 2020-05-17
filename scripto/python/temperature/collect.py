# coding: utf8
# pip install python-dateutil 
from json import dumps
import time
import io
import socket
import logging
import datetime
import argparse

#logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.info('This is a log message.')

parser = argparse.ArgumentParser()
parser.add_argument("--backend", default="kafka")
parser.add_argument("--frequency", default=10)
parser.add_argument("--broker", default="none")
parser.add_argument("--username", default="none")
parser.add_argument("--password", default="none")
parser.add_argument("--dht", default="false")
parser.add_argument("--sleep_time", default=1)
parser.add_argument("--test_time", default=0)
args = parser.parse_args()
if args.backend:
    logging.debug('Backend option provided: %s', args.backend)
if args.frequency:
    logging.debug('frequency option provided: %s', args.frequency)
    mysql_commit_frequency = args.frequency # 0 means commit every insert
if args.broker:
    logging.debug('broker option provided: %s', args.broker)
    broker = args.broker
if args.username:
    logging.debug('username option provided: %s', args.username)
    username = args.username
if args.password:
    logging.debug('password option provided: %s', args.password)
    password = args.password
if args.dht:
    logging.debug('dht option provided: %s', args.dht)
    dht_sensors = args.dht
if args.sleep_time:
    logging.debug('sleep_time option provided: %s', args.sleep_time)
    sleep_time = args.sleep_time
if args.test_time:
    logging.debug('test_time option provided: %s', args.test_time)
    test_time = args.test_time


#Sleep time after readings are saved in backend
#sleep_time = 0 #in seconds
#test_time = 300 #in seconds how long the test will run

#Set backend
backend_mysql = False
backend_cassandra = False
backend_kafka = False
backend_awsiot = False
backend_mqtt = False

if args.backend == "mysql":
    backend_mysql = True
    
if args.backend == "cassandra":
    backend_cassandra = True
    
if args.backend == "kafka":
    backend_kafka = True
    
if args.backend == "awsiot":
    backend_awsiot = True
    logging.debug("Checking if broker is provided")
    if (broker == "none"):
        logging.error("With AWS IoT backend you need to provide --broker parameter. Exiting.")
        exit()
        
if args.backend == "mqtt":
    backend_mqtt = True
    logging.debug("Checking if broker is provided")
    if (broker == "none") or (username == "none") or (password == "none"):
        logging.error("With MQTT backend you need to provide --broker --username --password parameters. Exiting.")
        exit()
        
    
    

logging.debug("Backend options - \n backend_mysql: %s \n backend_cassandra: %s \n backend_kafka: %s \n mysql_commit_frequency: %s \n broker: %s" % (backend_mysql, backend_cassandra, backend_kafka, mysql_commit_frequency, broker))


# pip install mysql-connector
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

   cluster = Cluster(contact_points=['cassandra2'], idle_heartbeat_interval=5,load_balancing_policy=DCAwareRoundRobinPolicy(), reconnection_policy=ConstantReconnectionPolicy(delay=5, max_attempts=50), idle_heartbeat_timeout=5)
   cluster.connect_timeout = 30
   session = cluster.connect('temperature')


# pip install kafka-python
if backend_kafka:
   from kafka import KafkaProducer
   from kafka.errors import KafkaError

   producer = KafkaProducer(bootstrap_servers=['sensu:9092'],
                            acks=-1,
                            value_serializer=lambda x: 
                            dumps(x).encode('utf-8'))

if backend_awsiot:
   import paho.mqtt.client as mqttClient 
   import ssl
   Connected = False #global variable for the state of the connection

   def on_connect(client, userdata, flags, rc):
       if rc == 0:
           print("Connected to broker")
           global Connected                #Use global variable
           Connected = True                #Signal connection 
       else:
           print("Connection failed")
   Connected = False   #global variable for the state of the connection
   client = mqttClient.Client("Python")               #create new instance
   client.tls_set(ca_certs="/home/pi/certs/rootCA.pem", certfile="/home/pi/certs/certificate.pem.crt", keyfile="/home/pi/certs/private.pem.key", cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLSv1_2, ciphers=None)
   client.tls_insecure_set(True)

   client.on_connect= on_connect                      #attach function to callback
   client.connect(broker, 8883, 60)
   client.loop_start()        #start the loop
   while Connected != True:    #Wait for connection
       time.sleep(0.1)

if backend_mqtt:
   import paho.mqtt.client as mqttClient 
   Connected = False #global variable for the state of the connection

   def on_connect(client, userdata, flags, rc):
       if rc == 0:
           print("Connected to broker")
           global Connected                #Use global variable
           Connected = True                #Signal connection 
       else:
           print("Connection failed")
   Connected = False   #global variable for the state of the connection
   client = mqttClient.Client("Python")               #create new instance
   client.username_pw_set(username, password)

   client.on_connect= on_connect                      #attach function to callback
   client.connect(broker, 1883, 60)
   client.loop_start()        #start the loop
   while Connected != True:    #Wait for connection
       time.sleep(0.1)



# dict that will store all the temperatures
temp_dict = {}

# checking is something is connected to PIN ponted by DHT variable (by default 4)
channel_is_on = False
dht_sensors = False
if dht_sensors:
   import RPi.GPIO as GPIO

   #Set DATA pin for DHT-22
   DHT = 26

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

    channel_is_on = False
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
                  + datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3] + "', " \
                  + str(reading) + ", '" \
                  + "'" \
                  + ");"
           logging.debug("cass_insert: %s" % cass_insert)
           cass_return = session.execute(cass_insert)

        if backend_kafka:
           # Now kafka publish
           data = {'reading_location' : sensor, 'reading_date' : str(now), 'reading_value' : str(reading)}
           logging.debug("Kafka insert: %s" % data)
           # async
           #producer.send('temperature', value=data)
           # sync?
           #future = producer.send('temperature', value=data)
           #result = future.get(timeout=60)
           # Block for 'synchronous' sends
           future = producer.send('temperature', value=data)
           try:
               record_metadata = future.get(timeout=10)
           except KafkaError:
               # Decide what to do if produce request failed...
               logging.error("Failure.")
           pass
           logging.debug("Kafka insert debug topic: %s partition %s offset %s" % (record_metadata.topic, record_metadata.partition, record_metadata.offset))
           producer.flush()
       

        if backend_awsiot:
           data = {'reading_location' : sensor, 'reading_date' : str(now), 'reading_value' : str(reading)}
           logging.debug("MQTT insert: %s" % data)
           client.publish("temperature",str(data))
    
        if backend_mqtt:
           data = {'reading_location' : sensor, 'reading_date' : str(now), 'reading_value' : str(reading)}
           logging.debug("MQTT insert: %s" % data)
           client.publish("temperature",str(data))
    
    if sleep_time > 0:                
       logging.debug("Sleeping for: %s sec" % sleep_time)
       time.sleep(sleep_time)

    tse_end = int(time.time())  # time since epoch, in seconds
    if (tse_end - tps_start) >= 1:
       logging.debug("tps_ratio: %s total_trans: %s tse_end: %s tse_start: %s" % (tps_ratio, total_trans, tse_end, tse_start))
       logging.info("TPS: %s Average TPS: %s Total trans: %s" % (tps_ratio, total_trans/(tse_end - tse_start), total_trans))
       tps_start = int(time.time())  # time since epoch, in seconds
       tps_ratio = 0

    logging.debug("Check if it is time to exit the program")
    if test_time > 0:
      if (int(time.time()) - tse_start) >= test_time:
         logging.info("Done.")
         logging.debug("Closing connection.")
         if backend_kafka:
            producer.close()
          
         exit()  

session.shutdown()

