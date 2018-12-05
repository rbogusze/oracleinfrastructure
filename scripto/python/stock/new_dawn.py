# coding: utf8
from cassandra.cluster import Cluster
import subprocess
import lcddriver
import time
import csv
import sys
import datetime as dt
import dateutil.parser
import os

# $ sudo pip install python-dateutil

cluster = Cluster(['192.168.1.233','192.168.1.236','192.168.1.27'])
session = cluster.connect('stock')

# Get the distinct list of stocks I already have
def check_quotes():
    #session = cluster.connect('stock')
    rows = session.execute('SELECT * FROM transactions')
    my_quotes = []
    for tran in rows:
            print tran.asset, tran.tran_date, tran.amount, tran.price
            my_quotes.append(tran.asset)

    print my_quotes
    # turn the list to only distinct elements
    my_quotes = list(set(my_quotes))
    for x in range(len(my_quotes)):
        print "Element: %d, has value: %s" % (x, my_quotes[x])

    #session.shutdown()
    return my_quotes

# capture the quotes I am interested with
def capture_current_quotes(my_quotes):
    print "F: capture_current_quotes"
    for x in range(len(my_quotes)):
        print "Element: %d, has value: %s" % (x, my_quotes[x])

        # Get the quotes from stooq.pl
        subprocess.check_call(['wget', '-O', my_quotes[x] + '.csv', 'https://stooq.pl/q/l/?s=' + my_quotes[x] + '&e=csv'])

        # Getting data that I want out of the downloaded file
        with open(my_quotes[x] + '.csv', 'r') as fp:
            reader = csv.reader(fp, delimiter=',', quotechar='"')
            # next(reader, None)  # skip the headers
            data_read = [row for row in reader]
        print(data_read)
        print(data_read[0][3])

        print "Data out of csv file but in iso format: %s" % str(dateutil.parser.parse(data_read[0][1]).date())
        
        # Save the quotes in Cassandra
        cass_insert = "INSERT INTO stock.quotes (asset, quote_date, price) values ('" + my_quotes[x] + "', '" \
                      + str(dateutil.parser.parse(data_read[0][1]).date()) \
                      + "', " \
                      + str(data_read[0][3]) \
                      + ");"
        print "cass_insert: %s" % cass_insert
        cass_return = session.execute(cass_insert)


print "Get the distinct list of stocks I already have"
my_quotes = check_quotes()
            
print "capture the current quotes"
capture_current_quotes(my_quotes)


session.shutdown()





