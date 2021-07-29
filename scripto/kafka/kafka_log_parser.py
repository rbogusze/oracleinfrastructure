# Read kafka topic where I send all the logs and do the parsing to see it nicely online 
# with colors and stuff

from time import sleep
from json import dumps
from json import loads
from kafka import KafkaConsumer

consumer = KafkaConsumer(
    'remi_logs',
     bootstrap_servers=['192.168.1.104:9092'],
     auto_offset_reset='latest',
     enable_auto_commit=True,
     group_id='console-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

for message in consumer:
    message = message.value
    #print(type(message))
    mhost = message['host']
    mpath = message['path']
    mpath_last = mpath.split('/')[-1]
    mmessage = message['message']
    
    print(f"[{mhost} {mpath_last}] {mmessage}")
