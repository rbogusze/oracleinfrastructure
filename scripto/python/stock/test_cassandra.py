# coding: utf8
from cassandra.cluster import Cluster

cluster = Cluster(['192.168.1.233'])

session = cluster.connect('remi_test')

rows = session.execute('SELECT * FROM table1')
for user_row in rows:
    print user_row.name, user_row.id, user_row.temperature

print "ala"

