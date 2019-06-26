# coding: utf8
from json import dumps
import time
import io
import socket
import thread
import random

# $ sudo pip install python-dateutil

sleep_time = 1 #in seconds

# Define a function for the thread

def update_string (dictionary_id):
    print "Hello, will update %s" % dictionary_id
    print "Before change: %s" % strings_dict[dictionary_id]
    strings_dict[dictionary_id] = "0000changed_that0000"
    print "After change: %s" % strings_dict[dictionary_id]


def trigger_random_update ():
    random_seed = random.randint(0, 9)
    print "String random: %s" % random_seed
    update_string(random_seed)


# main 

print "Ala ma kota"

strings_dict = {
  0: "000000000000000000",
  1: "111111111111111111",
  2: "222222222222222222",
  3: "333333333333333333",
  4: "444444444444444444",
  5: "555555555555555555",
  6: "666666666666666666",
  7: "777777777777777777",
  8: "888888888888888888",
  9: "999999999999999999"
}

while True:

    trigger_random_update()
 
    print "Sleeping"
    time.sleep(1)






