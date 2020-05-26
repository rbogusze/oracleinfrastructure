#!/usr/bin/python
# coding: utf8
# Here I read from two topics: temperature, temperature_outside
# make decision 
# and I send commands to open/close the "lufcik" to 'lufcik' topic that will be read by 
#     lufcik_decision_maker.py script

import sys
from time import sleep
from json import loads,dumps
from kafka import KafkaConsumer
from kafka import KafkaProducer
from ConfigParser import SafeConfigParser

# set the temperature sensor name
print("Reading configuration file")
parser_file = '/etc/lufcik.ini'
parser = SafeConfigParser()
parser.read(parser_file)
temperature_sensor = parser.get('main', 'temperature_sensor')
desired_temp = float(parser.get('main', 'desired_temp'))
kafka_topic = parser.get('main', 'kafka_topic')

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

producer = KafkaProducer(bootstrap_servers=['sensu:9092'])

while True:
    # get current_temp
    for message in consumer:
        message = message.value
        print('Message received: {}'.format(message))
        if temperature_sensor == message["reading_location"]:
            # I have what I need, inside temperature reading. Exiting the loop
            current_temp = float(message["reading_value"]) / 1000
            break
    print(current_temp)

    # get outside_temp
    for message in consumer2:
        message = message.value
        print('Message received: {}'.format(message))
        outside_temp = float(message["temp_outside"])
        break
    print(outside_temp)

    # now the logic of opening "lufcik"
    print ("current_temp: {} \t desired_temp: {} \t outside_temp: {}").format(current_temp, desired_temp, outside_temp)
    if current_temp == desired_temp:
        print("Perfect. Doing nothing.")
    else:
        if current_temp > desired_temp:
            print("it is just too warm")
            if outside_temp < current_temp:
                print("ok, it is colder outside, we can ACTION open")
                producer.send(kafka_topic, value="open")
                producer.flush()
            else:
                print("bad, it is warmer outside so no point to open, ACTION close")
                producer.send(kafka_topic, value="close")
                producer.flush()
           
        else:
            print("it is colder than it should be, the only ACTION is to close the lufcik and wait")
            producer.send(kafka_topic, value="close")
            producer.flush()
            


