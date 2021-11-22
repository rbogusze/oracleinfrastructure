# Read kafka topic where I send all the logs and do the parsing to see it nicely online 
# with colors and stuff

from time import sleep
from json import dumps
from json import loads
from kafka import KafkaProducer
from kafka.errors import KafkaError

producer = KafkaProducer(bootstrap_servers=['192.168.1.171:9092','192.168.1.172:9092','192.168.1.173:9092'],
                         acks=-1,
                         value_serializer=lambda x: dumps(x).encode('utf-8'))

for e in range(24*60*60):
    data = {'number' : e}
    print(f"sending {data}")
    #producer.send('testing_idempotency', value=data)
    future = producer.send('testing_idempotency', value=data)
    try:
        record_metadata = future.get(timeout=10)
    except KafkaError:
        # Decide what to do if produce request failed...
        print("Failure.")
    pass
    print("Kafka insert debug topic: %s partition %s offset %s" % (record_metadata.topic, record_metadata.partition, record_metadata.offset))
    #producer.flush()
    sleep(1)

