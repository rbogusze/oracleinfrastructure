#!/usr/bin/python
# coding: utf8
# Here I read from two topics: temperature, temperature_outside
# make decision 
# and I send commands to open/close the "lufcik" to 'lufcik_decision_maker' topic

import sys
from time import sleep
from json import loads
from kafka import KafkaConsumer
from ConfigParser import SafeConfigParser

# set the temperature sensor name
print("Reading configuration file")
parser_file = '/etc/lufcik.ini'
parser = SafeConfigParser()
parser.read(parser_file)
temperature_sensor = parser.get('main', 'temperature_sensor')

print(temperature_sensor)

# read just one message from temperature topic
consumer = KafkaConsumer('temperature',
                         bootstrap_servers=['sensu:9092'],
                         enable_auto_commit=False,
			 auto_offset_reset='latest',
                         value_deserializer=lambda x: loads(x.decode('utf-8')))


consumer2 = KafkaConsumer('temperature_outside',
                         bootstrap_servers=['sensu:9092'],
                         enable_auto_commit=False,
			 auto_offset_reset='latest',
                         value_deserializer=lambda x: loads(x.decode('utf-8')))


while True:
    # get current_temp
    for message in consumer:
        message = message.value
        print('Message received: {}'.format(message))
        if temperature_sensor == message["reading_location"]:
            # I have what I need, inside temperature reading. Exiting the loop
            current_temp = message["reading_value"]
            break
    print(current_temp)

    # get outside_temp
    for message2 in consumer2:
        message2 = message2.value
        print('Message received: {}'.format(message2))


    exit()


