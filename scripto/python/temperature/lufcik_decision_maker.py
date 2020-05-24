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
open_max = int(parser.get('main', 'open_max'))

print("Read from config file \n\t kafka_topic: {} \n\t open_max: {}").format(kafka_topic, open_max)


consumer = KafkaConsumer(kafka_topic,
                         bootstrap_servers=['sensu:9092'],
                         auto_offset_reset='latest',
                         enable_auto_commit=True,
                         group_id='lufcik_decision_maker',
                         )

def read_open_level():
    return int(parser.get('main', 'open_current'))

def set_open_level(level):
    print("Setting open_current to {}").format(level)
    parser.set('main', 'open_current', str(level))
    #parser.write(sys.stdout)
    with open(parser_file, 'w') as configfile:
        parser.write(configfile)
    return 0

def f_open():
    print("Action called for opening")
    open_current = read_open_level()
    print("open_max: {0}\t open_current: {1}\t").format(open_max, open_current)
    if open_current >= open_max:
        print("-> (NO) already open to max: {0}").format(open_max)
    else:
        print("-> (YES) opening more")
        set_open_level(open_current + 1) 

    
def f_close():
    print("Action called for closing")
    open_current = read_open_level()
    print("open_max: {0}\t open_current: {1}\t").format(open_max, open_current)
    if open_current <= 0:
        print("-> (NO) already closed and on level: {0}").format(open_current)
    else:
        print("-> (YES) closing")
        set_open_level(open_current - 1) 

# acutal execution

set_open_level(2)
#open_current = read_open_level()
#print("Currently we are open: {}").format(open_current)
#sleep(2)
#set_open_level(20)
#open_current = read_open_level()
#print("Currently we are open: {}").format(open_current)


print("Will read from kafka topic: {}").format(kafka_topic)
for message in consumer:
    message = message.value
    print('Message received: {}'.format(message))

    if message == "open":
        f_open()

    if message == "close":
        f_close()

    sleep(1)
