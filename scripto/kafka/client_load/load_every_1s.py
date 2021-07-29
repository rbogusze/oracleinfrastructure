# Read kafka topic where I send all the logs and do the parsing to see it nicely online 
# with colors and stuff

from time import sleep
from json import dumps
from json import loads
from kafka import KafkaProducer

producer = KafkaProducer(bootstrap_servers=['192.168.1.152:9092','192.168.1.153:9092','192.168.1.154:9092'],
                         value_serializer=lambda x: dumps(x).encode('utf-8'))

for e in range(24*60*60):
    data = {'number' : e}
    producer.send('mm_test1', value=data)
    sleep(1)

