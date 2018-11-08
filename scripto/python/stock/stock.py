# coding: utf8

import subprocess
import csv
import sys
import datetime as dt

akcje_cda = 0.5
akcje_gtn = 60

akcje_wartosc = 0
gotowka = 33

hour = dt.datetime.today().hour

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
