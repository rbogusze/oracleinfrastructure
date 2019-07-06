# coding: utf8
import time
import io
import logging
import Adafruit_DHT as dht

#Set DATA pin for DHT-22
DHT = 26

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.info('This is a log message.')


sleep_time = 1 #in seconds

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
    
    # reading from DHT-22 sensor
    if channel_is_on:
       logging.info("Read Temp and Hum from DHT22")
       h,t = dht.read_retry(dht.DHT22, DHT)
       if h is None:
          logging.warn("Just received garbage for h from dht22. Doing another loop.")
          continue
       if t is None:
          logging.warn("Just received garbage for h from dht22. Doing another loop.")
          continue
          
       #Print Temperature and Humidity on Shell window
       #logging.info('Temp={0:0.1f}*C  Humidity={1:0.1f}%'.format(t,h)) #this was causing some errors?
       logging.info("Storing t value: %s" % (int(t*1000)))
       f1 = open("/tmp/t.txt","w")
       f1.write("%d" % int(t*1000))
       f1.close()
       logging.info("Storing h value: %s" % (int(h*1000)))
       f2 = open("/tmp/h.txt","w")
       f2.write("%d" % int(h*1000))
       f2.close()

    logging.info("Sleeping")
    time.sleep(sleep_time)    

