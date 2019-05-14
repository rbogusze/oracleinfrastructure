# coding: utf8
from time import sleep
from json import dumps
from kafka import KafkaProducer


producer = KafkaProducer(bootstrap_servers=['192.168.1.167:9092'],
                         value_serializer=lambda x: 
                         dumps(x).encode('utf-8'))

for e in range(1000):
    data = {'number' : e}
    producer.send('temperature', value=data)
    producer.send('first_topic', value=data)
    sleep(1)

