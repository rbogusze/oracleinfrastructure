# read from Kafka but only between selected offsets
import os
from kafka import KafkaConsumer
from kafka.structs import TopicPartition
import psycopg2 as pg
import pandas.io.sql as psql
from pathlib import *



topics = 'remi_logs'
kafka_broker='192.168.1.161:9092'

output_tmp_dir = str(Path.home()) + "/tmp/"

connection = pg.connect("host=192.168.1.162 dbname=celebration user=celebrate password=forever")
connection.autocommit = True

def save_file_from_kafka(playlist_seq, file_name, offset_start, offset_end):
    
    Path(output_tmp_dir + str(playlist_seq)).mkdir(parents=True, exist_ok=True)
    
    output_tmp_file = output_tmp_dir + str(playlist_seq) + "/" + file_name
    print(f"output_tmp_file: {output_tmp_file}")
    
    # skip download if output_tmp_file if it exists
    if os.path.exists(output_tmp_file):
        print(f"File: {output_tmp_file} already exists. Skipping")
        return 0

        
    consumer=KafkaConsumer(bootstrap_servers=[kafka_broker])

    mypartition = TopicPartition(topics, 0)
    consumer.assign([mypartition])

    print(f"mypartition: {mypartition}")
    consumer.seek(partition=mypartition, offset=offset_start)

    for msg in consumer:
        #print(msg.value)
        #print(msg.offset)
        # write to file
        newFile = open(output_tmp_file, "ab")
        newFile.write(bytes(msg.value))
        newFile.close()

        if msg.offset == offset_end:
            print("Reached my end offset")
            break



            

# get current sequence for playlist
cursor = connection.cursor()
cursor.execute("SELECT last_value from playlist_seq;")
playlist_seq = cursor.fetchone()[0]
print(f"playlist_seq: {playlist_seq}")
print(type(playlist_seq))
cursor.close()

# get list for this playlist id
dataframe = psql.read_sql(f'SELECT * FROM playlist where playlist_id = {playlist_seq}', connection)

playlist_dict = dataframe.to_dict('series')
#playlist_dict = dict(dataframe.values)

#playlist_dict
# for key, value in playlist_dict.items():
#     #print(key)
#     print(value)



for x in range(0, len(playlist_dict['song_title'])):
    print(x)
    song_title = playlist_dict['song_title'][x]
    print(f"song_title: {song_title}")    
    song_offset_start = int(playlist_dict['song_offset_start'][x])
    song_offset_end = int(playlist_dict['song_offset_end'][x])
#     print(type(song_offset_start))
    
    #download from kafka
    save_file_from_kafka(playlist_seq=playlist_seq, file_name=str(x).zfill(2)+"_"+song_title,offset_start=song_offset_start, offset_end=song_offset_end)
    #break

