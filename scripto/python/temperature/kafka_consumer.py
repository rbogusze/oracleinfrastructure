#!/usr/bin/python
# coding: utf8
from time import sleep
from json import loads
from kafka import KafkaConsumer

consumer = KafkaConsumer('temperature',
                         bootstrap_servers=['sensu:9092'],
                         auto_offset_reset='latest',
                         enable_auto_commit=True,
                         group_id='test-group2',
                         value_deserializer=lambda x: loads(x.decode('utf-8')))

for message in consumer:
    message = message.value
    print('Message received: {}'.format(message))
