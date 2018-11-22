# coding: utf8
# Simple string program. Writes and updates strings.
# Demo program for the I2C 16x2 Display from Ryanteck.uk
# Created by Matthew Timmons-Brown for The Raspberry Pi Guy YouTube channel

# Import necessary libraries for communication and display use
import lcddriver
import time
import subprocess
import csv
import sys
import datetime as dt
import os

akcje_cda = 0.5
akcje_gtn = 60

gotowka = 33

LCD_DISPLAYCONTROL = 0x08
LCD_DISPLAYON = 0x04
LCD_DISPLAYOFF = 0x00

# Load the driver and set it to "display"
# If you use something from the driver library use the "display." prefix first
display = lcddriver.lcd()




# Main body of code
try:
    while True:
        # Remember that your sentences can only be 16 characters long!
        print("Writing to display")
        #display.lcd_display_string("Greetings Human!", 1) # Write line of text to first line of display
        #display.lcd_display_string("Demo Pi Guy code", 2) # Write line of text to second line of display
        #time.sleep(1)                                     # Give time for the message to be read
        #display.lcd_clear()                               # Clear the display of any data
        #time.sleep(1)                                     # Give time for the message to be read

	hour = dt.datetime.today().hour
	minute = dt.datetime.today().minute
	second = dt.datetime.today().second

        print "Deciding if I should turn the display on or off"
        if (hour > 20 or hour < 9):
           print "Time to go to sleep"
           display.lcd_write(LCD_DISPLAYCONTROL | LCD_DISPLAYOFF)
        else:
           print "Time to wake up"
        display.lcd_write(LCD_DISPLAYCONTROL | LCD_DISPLAYON)


        print "Jest teraz %d:%d:%d" % (hour, minute, second)
        akcje_wartosc = 0

        stock_mtime = os.path.getmtime('cdr.csv')
        print "'cdr.csv' mtime: %d" % stock_mtime 
        unix_timestamp = int(time.time())
        print unix_timestamp
        print "It is now: %d which is %d after that" % (unix_timestamp, unix_timestamp - stock_mtime)

	if ((unix_timestamp - stock_mtime) > (24 * 60 * 60)):
    	    print "Hour is right, getting new numbers." 
            subprocess.check_call(['wget', '-O', 'cdr.csv', 'https://stooq.pl/q/l/?s=cdr&e=csv'])
            subprocess.check_call(['wget', '-O', 'gtn.csv', 'https://stooq.pl/q/l/?s=gtn&e=csv'])
        else:
            print "Hour is young, not getting new numbers" 

                # for CDA
        with open('cdr.csv', 'r') as fp:
            reader = csv.reader(fp, delimiter=',', quotechar='"')
            # next(reader, None)  # skip the headers
            data_read = [row for row in reader]

        print(data_read)
        print(data_read[0][3])

        print "Wartosc akcji cda %d " % (float(data_read[0][3]) * akcje_cda)
        akcje_wartosc = akcje_wartosc + float(data_read[0][3]) * akcje_cda

        # for GTN
        with open('gtn.csv', 'r') as fp:
            reader = csv.reader(fp, delimiter=',', quotechar='"')
            # next(reader, None)  # skip the headers
            data_read = [row for row in reader]

        print(data_read)
        print(data_read[0][3])

        print "Wartosc akcji gtn %d " % (float(data_read[0][3]) * akcje_gtn)
        akcje_wartosc = akcje_wartosc + float(data_read[0][3]) * akcje_gtn


        # suma
        print "W akcjach mam: %d zł" % akcje_wartosc
        print "W gotówce mam: %d zł" % gotowka
        display.lcd_display_string("Akcje: " + str(int(akcje_wartosc)) + "zl", 1) # Write line of text to first line of display
        display.lcd_display_string("Gotowka: " + str(int(gotowka)) + "zl", 2) # Write line of text to second line of display
        time.sleep(3)                                     # Give time for the message to be read
        display.lcd_clear()                               # Clear the display of any data
        time.sleep(0.5)                                     # Give time for the message to be read
        print "Razem: %d" % int(akcje_wartosc + gotowka)
        display.lcd_display_string("Razem: " + str(int(akcje_wartosc + gotowka)) + "zl", 1) # Write line of text to first line of display
        time.sleep(3)                                     # Give time for the message to be read
        display.lcd_clear()                               # Clear the display of any data
        time.sleep(0.5)                                     # Give time for the message to be read


except KeyboardInterrupt: # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
    print("Cleaning up!")
    display.lcd_clear()
