#!/usr/bin/python
# coding: utf8
import sys
from time import sleep
from json import loads
from kafka import KafkaConsumer
from ConfigParser import SafeConfigParser

print("Reading configuration file")
parser_file = '/etc/lufcik.ini'

parser = SafeConfigParser()
parser.read(parser_file)

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
    return 0

def set_open_level(level):
    parser.set('main', 'open_current', str(level))
    #parser.write(sys.stdout)
    with open(parser_file, 'w') as configfile:
        parser.write(configfile)
    return 0

def f_open():
    print("opening")

def f_close():
    print("Closing")

set_open_level(2)
sleep(10)
set_open_level(20)

print("Will read from kafka topic: {}").format(kafka_topic)
for message in consumer:
    message = message.value
    print('Message received: {}'.format(message))

    if message == "open":
        f_open()

    if message == "close":
        f_close()

    sleep(1)
