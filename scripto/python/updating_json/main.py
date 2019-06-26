# coding: utf8
from json import dumps
import time
import io
import socket
import thread

# $ sudo pip install python-dateutil

sleep_time = 1 #in seconds

# Define a function for the thread
def print_time( threadName, delay):
   count = 0
   while count < 5:
      time.sleep(delay)
      count += 1
      print "%s: %s" % ( threadName, time.ctime(time.time()) )


# main 

print "Ala ma kota"

string0 = "000000000000000000"
string1 = "111111111111111111"
string2 = "222222222222222222"
string3 = "333333333333333333"
string4 = "444444444444444444"
string5 = "555555555555555555"
string6 = "666666666666666666"
string7 = "777777777777777777"
string8 = "888888888888888888"
string9 = "999999999999999999"

while True:
    random_seed = 2
    string_name = "string"
    string_random = string_name + str(random_seed)

    print "String random: %s" % string_random    

    print "Now: %s" % globals()[string_random]
    time.sleep(1)




# Create two threads as follows
try:
   thread.start_new_thread( print_time, ("Thread-1", 1, ) )
   thread.start_new_thread( print_time, ("Thread-2", 1, ) )
except:
   print "Error: unable to start thread"

while 1:
   pass




