# coding: utf8
from cassandra.cluster import Cluster
from cassandra.policies import ConstantReconnectionPolicy, DCAwareRoundRobinPolicy
import subprocess
import lcddriver
import time
import csv
import sys
import datetime as dt
import dateutil.parser
import os

# Settings
cluster = Cluster(contact_points=['192.168.1.20'], idle_heartbeat_interval=5,load_balancing_policy=DCAwareRoundRobinPolicy(), reconnection_policy=ConstantReconnectionPolicy(delay=5, max_attempts=50), idle_heartbeat_timeout=5)
cluster.connect_timeout = 30
session = cluster.connect('stock')
display = lcddriver.lcd()

checked_quotes_last_time = 0
checked_frequency = 60 * 60  # in seconds

lang = "en"
#lang = "pl"

messages = {
    "curr_en": "$",
    "curr_pl": "zl",
    "sum_en": "Sum",
    "sum_pl": "Razem",
    "stock_en": "Stock",
    "stock_pl": "Akcje",
    "cash_en": "Cash",
    "cash_pl": "Gotowka",
    "gain_en": "Gain",
    "gain_pl": "Zysk",
    "loss_en": "Loss",
    "loss_pl": "Strata"
}



# Functions

# Get the distinct list of stocks I already have
def check_quotes():

    rows = session.execute('SELECT * FROM transactions')
    my_quotes = []
    for tran in rows:
            #print tran.asset, tran.tran_date, tran.amount, tran.price
            my_quotes.append(tran.asset)

    #print my_quotes
    # turn the list to only distinct elements
    my_quotes = list(set(my_quotes))
    #for x in range(len(my_quotes)):
    #    print "Element: %d, has value: %s" % (x, my_quotes[x])

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

def ask_cassandra_stock_quote(quote_name, quote_date):
    keep_asking = True

    while keep_asking:
        cass_sql = "select price from stock.quotes where asset='" + quote_name + "' and quote_date='" + quote_date + "';"
        print "About to ask for: %s" % cass_sql
        rows_price = session.execute(cass_sql)
        if not rows_price:
            print "Does not exist. I will ask for one day before that"
            tmp_date = dt.datetime.strptime(quote_date, '%Y-%m-%d')
            tmp_date = tmp_date - dt.timedelta(days=1)
            quote_date = tmp_date.strftime('%Y-%m-%d')
            print "Will ask for: %s" % quote_date
        else:
            keep_asking = False

    return rows_price
                

def my_stock_value(my_quotes, for_date):
    my_stock_sum = 0
    for x in range(len(my_quotes)):
        print "-" * 30
        print "Checking the quantity for %s" % (my_quotes[x])

        cass_select = "select sum(amount) as sum_amount from stock.transactions where asset = '" + my_quotes[x] + "';"
        print "Asking cassandra for: %s" % cass_select
        rows = session.execute(cass_select)
        for row in rows:
            print "I have %f pieces of %s " % (float(row.sum_amount), str(my_quotes[x]))

            # I know now how much I have of a particular stock, now what is the current value I ask the stock.quotes table
            #cass_select_price = "select price from stock.quotes where asset='" + my_quotes[x] + "' and quote_date='" + for_date + "';"
            #cass_select_price = "select price from stock.quotes where asset='" + my_quotes[x] + "' and quote_date='" + for_date + "';"
            #rows_price = session.execute(cass_select_price)
            rows_price = ask_cassandra_stock_quote(my_quotes[x], for_date)
            for row_price in rows_price:
                print row_price.price
                print "Current value for: %s is: %f" % (my_quotes[x], (row.sum_amount * row_price.price))
                my_stock_sum += (row.sum_amount * row_price.price)
    print "Value in stock: %d" % my_stock_sum

    return my_stock_sum
     

# Is it time to display (If it is a night I disable the LCD display)
def time_to_display():
    hour = dt.datetime.today().hour

    LCD_BACKLIGHT = 0x08
    LCD_NOBACKLIGHT = 0x00    

    print "Deciding if I should turn the display on or off"
    if (hour >= 21 or hour < 9):
        print "Time to turn off backlight and forget about anything"
        display.lcd_device.write_cmd(LCD_NOBACKLIGHT)
        time.sleep(5)
        return False
    else:
        print "Time to turn on backlight"
        display.lcd_device.write_cmd(LCD_BACKLIGHT)
        return True
                                                        
def my_savings_value():
    cass_select = "select sum(amount) as sum_amount from stock.savings;"
    print "Asking cassandra for: %s" % cass_select
    rows = session.execute(cass_select)
    for row in rows:
        print "I have savings of %s " % str(row.sum_amount)
    return row.sum_amount
                                    

def print_to_lcd(line1, line2):
    print "First line: %s" % line1
    print "Second line: %s" % line2
    display.lcd_clear()                  # Clear the display of any data
    display.lcd_display_string(line1, 1) # Write line of text to first line of display
    display.lcd_display_string(line2, 2) # Write line of text to second line of display
            

# main endless loop


while True:
    if not time_to_display():
        continue
    
    now = int(time.time())
    if (now - checked_quotes_last_time) > checked_frequency:
        print "Time to check the quotes."

        print "Get the distinct list of stocks I already have"
        my_quotes = check_quotes()

        print "capture the current quotes"
        capture_current_quotes(my_quotes)
        
        checked_quotes_last_time = now
        #time.sleep(3)
    else:
        print "\*" * 30
        print "I was checking quotes recently, not doing that now. "
        #time.sleep(15)

    # What is my current stock value
    my_stock = my_stock_value(check_quotes(), str(dt.datetime.now().date()))
    my_savings = my_savings_value()

    my_stock_yesterday = my_stock_value(check_quotes(), str(dt.datetime.now().date() - dt.timedelta(1)))

    print_to_lcd(messages["stock_" + lang] + ": " + str(int(my_stock)) + messages["curr_" + lang] , messages["cash_" + lang] + ": " + str(int(my_savings)) + messages["curr_" + lang] )
    time.sleep(3)
    if my_stock >= my_stock_yesterday:
        print_to_lcd(messages["sum_" + lang] + ": " + str(int((my_stock + my_savings))) + messages["curr_" + lang] , messages["gain_" + lang] + ": " + str(int(my_stock - my_stock_yesterday)) + messages["curr_" + lang])
    else:
        print_to_lcd(messages["sum_" + lang] + ": " + str(int((my_stock + my_savings))) + messages["curr_" + lang] , messages["loss_" + lang] + ": " + str(int(my_stock_yesterday - my_stock)) + messages["curr_" + lang])
    
    time.sleep(3)


session.shutdown()





