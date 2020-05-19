#!/usr/bin/python
# coding: utf8
from time import sleep
from json import loads
from kafka import KafkaConsumer

consumer = KafkaConsumer('lufcik',
                         bootstrap_servers=['sensu:9092'],
                         auto_offset_reset='latest',
                         enable_auto_commit=True,
                         group_id='lufcik_decision_maker',
                         )

print("Listening to Kafka topic 'lufcik'")
for message in consumer:
    message = message.value
    print('Message received: {}'.format(message))
    sleep(1)
