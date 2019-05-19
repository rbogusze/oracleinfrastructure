# coding: utf8
from time import sleep
from json import dumps
from json import loads
from kafka import KafkaConsumer
import mysql.connector


consumer = KafkaConsumer(
    'temperature',
     bootstrap_servers=['192.168.1.167:9092'],
     auto_offset_reset='latest',
     enable_auto_commit=True,
     group_id='my-group',
     value_deserializer=lambda x: loads(x.decode('utf-8')))

mydb = mysql.connector.connect(
    host="192.168.1.167",
    user="remik",
    passwd="remik",
    database="sensors"
)

#for message in consumer:
#    message = message.value
#    collection.insert_one(message)
#    print('{} added to {}'.format(message, collection))

mycursor = mydb.cursor()
sql = "INSERT INTO temperature (reading_location, reading_date, reading_value) VALUES (%s, FROM_UNIXTIME(%s/1000), %s)"

for message in consumer:
    message = message.value
#    print(message)
#    print(message['reading_date'])
    val = (message['reading_location'], message['reading_date'], message['reading_value'])
    mycursor.execute(sql, val)
    mydb.commit()
