#!/usr/bin/python
# coding: utf8
from time import sleep
from json import loads
from kafka import KafkaConsumer
from ConfigParser import SafeConfigParser

print("Reading configuration file")
parser = SafeConfigParser()
parser.read('/etc/lufcik.ini')

kafka_topic = parser.get('main', 'kafka_topic')
open_max = parser.get('main', 'open_max')

print("Read from config file \n\t kafka_topic: {} \n\t open_max: {}").format(kafka_topic, open_max)

consumer = KafkaConsumer(kafka_topic,
                         bootstrap_servers=['sensu:9092'],
                         auto_offset_reset='latest',
                         enable_auto_commit=True,
                         group_id='lufcik_decision_maker',
                         )

def read_open_level():
    return a

def set_open_level():
    return a




def f_open():
    print("opening")

def f_close():
    print("Closing")

print("Will read from kafka topic: {}").format(kafka_topic)
for message in consumer:
    message = message.value
    print('Message received: {}'.format(message))

    if message == "open":
        f_open()

    if message == "close":
        f_close()

    sleep(1)
