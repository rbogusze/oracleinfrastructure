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

akcje_cda = 0.5
akcje_gtn = 60

gotowka = 33


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
        akcje_wartosc = 0

	if (hour % 4 == 0):
    	    print "Hour is %d, it is 4, getting new numbers." % hour
            subprocess.check_call(['wget', '-O', 'cdr.csv', 'https://stooq.pl/q/l/?s=cdr&e=csv'])
            subprocess.check_call(['wget', '-O', 'gtn.csv', 'https://stooq.pl/q/l/?s=gtn&e=csv'])
        else:
            print "Hour is %d, it is not 4, not getting new numbers" % hour

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
        time.sleep(5)                                     # Give time for the message to be read
        display.lcd_clear()                               # Clear the display of any data
        time.sleep(0.5)                                     # Give time for the message to be read
        display.lcd_display_string("Razem: " + str(int(akcje_wartosc + gotowka)) + "zl", 1) # Write line of text to first line of display
        time.sleep(5)                                     # Give time for the message to be read
        display.lcd_clear()                               # Clear the display of any data
        time.sleep(0.5)                                     # Give time for the message to be read


except KeyboardInterrupt: # If there is a KeyboardInterrupt (when you press ctrl+c), exit the program and cleanup
    print("Cleaning up!")
    display.lcd_clear()
