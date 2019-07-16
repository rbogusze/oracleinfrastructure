# coding: utf8
from cassandra.cluster import Cluster

cluster = Cluster(['192.168.1.20'])

session = cluster.connect('stock')

rows = session.execute('SELECT * FROM transactions')
for user_row in rows:
    print user_row.asset, user_row.tran_date, user_row.amount

