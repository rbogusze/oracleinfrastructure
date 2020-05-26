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


producer = KafkaProducer(bootstrap_servers=['sensu:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

while True:
    # Search for current weather in London (Great Britain)
    observation = owm.weather_at_place('Lodz,PL')
    w = observation.get_weather()
    temp_outside = float(w.get_temperature('celsius')['temp'])
    send_to_kafka = {'send_time' : datetime.now().replace(microsecond=0).isoformat(), 'reference_time' : w.get_reference_time(timeformat='iso'), 'temp_outside' : str(temp_outside)}
    print("Sending to kafka topic: temperature_outside, value: {}").format(send_to_kafka)
    print(w)
    producer.send('temperature_outside', value=send_to_kafka)
    sleep(10)

