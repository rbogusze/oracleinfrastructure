#!/usr/bin/python
# coding: utf8

# get temperature readings
# following: https://rk.edu.pl/pl/pogoda-w-pythonie/

from time import sleep
from datetime import datetime
from json import dumps
from kafka import KafkaProducer
from ConfigParser import SafeConfigParser
import pyowm


print("Reading configuration file")
parser_file = '/etc/lufcik.ini'

parser = SafeConfigParser()
parser.read(parser_file)

owm_key = parser.get('main', 'owm_key')

owm = pyowm.OWM(owm_key)  # You MUST provide a valid API key

# Search for current weather in London (Great Britain)
observation = owm.weather_at_place('Lodz,PL')

producer = KafkaProducer(bootstrap_servers=['sensu:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

while True:
    w = observation.get_weather()
    temp_outside = float(w.get_temperature('celsius')['temp'])
    #print("{} Sending to kafka topic: temperature_outside, value: {}").format(datetime.now().isoformat(), temp_outside)
    producer.send('temperature_outside', value=temp_outside)
    sleep(10)

