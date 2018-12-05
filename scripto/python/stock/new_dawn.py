# coding: utf8
from cassandra.cluster import Cluster

cluster = Cluster(['192.168.1.233','192.168.1.236','192.168.1.27'])

# Get the distinct list of stocks I already have
def check_quotes():
    session = cluster.connect('stock')
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

    return my_quotes

print "Get the distinct list of stocks I already have"
my_quotes = check_quotes()
            
print "WIP capture the current quotes"

print "WIP save in cassandra"






