from time import sleep
from json import dumps
from json import loads
from kafka import KafkaConsumer

consumer = KafkaConsumer(
            'temperature',
            bootstrap_servers=['192.168.1.167:9092'],
            auto_offset_reset='latest',
            enable_auto_commit=True,
            group_id='my-group',
            value_deserializer=lambda x: loads(x.decode('utf-8')))

for message in consumer:
    message = message.value
    print(message)
