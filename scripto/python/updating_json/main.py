# coding: utf8
import sys
import time
import io
from random import randint
import logging
import unicodedata

start_time = time.time()

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.debug('This is a log message.')

backend_mysql = False
backend_redis = False


sleep_time = 1 #in seconds
iterations = 2 #nr of changes

# mysql
if backend_mysql:
   import mysql.connector

   logging.debug("[%s] Setup mysql connection" % worker_num)
   cnx = mysql.connector.connect(
#  host="localhost",
     host="sensu",
     user="remik",
     passwd="remik",
     database="remik",
     charset='ascii'
   )
   cursor = cnx.cursor()

# redis
if backend_redis:
   import redis
   logging.debug("[%s] Setup redis connection" % worker_num)
   #redis_host = "localhost"
   redis_host = "10.0.0.1"
   redis_port = 6379
   redis_password = ""
   try:
       r = redis.StrictRedis(host=redis_host, port=redis_port, password=redis_password, decode_responses=True)
   except Exception as e:
       print(e)


# Define a function for the thread

def update_string (dictionary_id, worker_num):
    logging.debug("[%s] Before change: %s" % (worker_num, strings_dict[dictionary_id]))

    # Get
    tmp_str = strings_dict[dictionary_id]

    if backend_mysql:
       logging.debug("[%s] Get from mysql" % worker_num)
       query = ("SELECT stringi_text FROM remik.stringi where stringi_id = %s" % dictionary_id)

       cursor.execute(query)
       rows = cursor.fetchall()
       
       for stringi_text in rows:
         tmp_str = stringi_text[0].encode("ascii")
         logging.debug("[%s] From DB: %s" % (worker_num, tmp_str))

    if backend_redis:
       logging.debug("[%s] Get from redis" % worker_num)
       tmp_str = str(r.get(dictionary_id))
       logging.debug("[%s] From redis: %s" % (worker_num, tmp_str))
     
    
    # Prepare random update 
    random_index = randint(0, 19)
    random_seed = randint(0, 9)
    tmp_bstr = bytearray(tmp_str)
    logging.debug("[%s] Hello, will update dict %s index %s to value %s" % (worker_num, dictionary_id, random_index, random_seed))
    tmp_bstr[random_index] = str(random_seed)

    # Update dictionary
    strings_dict[dictionary_id] = str(tmp_bstr)
    logging.debug("[%s] After change : %s" % (worker_num, strings_dict[dictionary_id]))

    # Update MYSQL
    if backend_mysql:
       logging.debug("Update to mysql with: %s" % str(tmp_bstr))
       query = ("""UPDATE stringi SET stringi_text = '%s' WHERE stringi_id = %s""" % (str(tmp_bstr), dictionary_id))
       cursor.execute(query)
       cnx.commit()

    if backend_redis:
       logging.debug("[%s} Update to redis with: %s" % (worker_num, str(tmp_bstr)))
       r.set(dictionary_id, str(tmp_bstr))


def trigger_random_update (worker_num):
    i = 1
    while i < iterations:
      random_seed = randint(0, 9)
      logging.debug("String random: %s" % random_seed)
      update_string(random_seed, worker_num)
      i += 1


# main 


strings_dict = {
  0: "00000000000000000000",
  1: "11111111111111111111",
  2: "22222222222222222222",
  3: "33333333333333333333",
  4: "44444444444444444444",
  5: "55555555555555555555",
  6: "66666666666666666666",
  7: "77777777777777777777",
  8: "88888888888888888888",
  9: "99999999999999999999"
}


trigger_random_update(sys.argv[1])



print("--- %s seconds ---" % (time.time() - start_time))
