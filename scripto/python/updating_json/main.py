# coding: utf8
import time
import io
import multiprocessing
from random import randint
import logging
import mysql.connector

start_time = time.time()

logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
#logging.basicConfig(level=logging.WARN, format='%(asctime)s - %(levelname)s - %(message)s')
logging.debug('This is a log message.')

backend_mysql = True

sleep_time = 1 #in seconds
iterations = 2

cnx = mysql.connector.connect(
  host="localhost",
  user="remik",
  passwd="remik",
  database="remik"
)

cursor = cnx.cursor()


# Define a function for the thread

def update_string (dictionary_id, worker_num):
    logging.debug("[%s] Before change: %s" % (worker_num, strings_dict[dictionary_id]))

    # Get
    tmp_str = strings_dict[dictionary_id]

    if backend_mysql:
       logging.debug("Get from mysql")
       query = ("SELECT stringi_text FROM remik.stringi where stringi_id = %s" % dictionary_id)

       cursor.execute(query)
       
       for stringi_text in cursor:
         print "From DB: %s" % stringi_text
       tmp_str = str(stringi_text)
    
    # Prepare random update 
    random_index = randint(0, 19)
    random_seed = randint(0, 9)
    tmp_bstr = bytearray(tmp_str)
    logging.debug("[%s] Hello, will update dict %s index %s to value %s" % (worker_num, dictionary_id, random_index, random_seed))
    tmp_bstr[random_index] = str(random_seed)

    # Update
    if backend_mysql:
       logging.debug("Update to mysql")

    strings_dict[dictionary_id] = str(tmp_bstr)

    logging.debug("[%s] After change : %s" % (worker_num, strings_dict[dictionary_id]))


def trigger_random_update (worker_num):
    i = 1
    while i < iterations:
      random_seed = randint(0, 9)
      logging.debug("String random: %s" % random_seed)
      update_string(random_seed, worker_num)
      i += 1


# main 

print "Ala ma kota"

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


trigger_random_update(999)

print "Sleep baby"
time.sleep(1000)


PROCESSES = 10
WORKER_CALLS = 10

def worker(num):
    """worker function"""
    print 'Starting worker', num
    trigger_random_update(num)
    #time.sleep(randint(2,4))
    print '[%s] Exiting worker' % num
    return "ok"

if __name__ == '__main__':
    pool = multiprocessing.Pool(processes=PROCESSES)
    pool_outputs = pool.map(worker, range(WORKER_CALLS))
    pool.close()
    pool.join()
    print 'Pool:', pool_outputs


print("--- %s seconds ---" % (time.time() - start_time))
