from redis.sentinel import Sentinel
import redis

sentinel = Sentinel([('192.168.1.152', 26379),
                     ('192.168.1.153',26379),
                     ('192.168.1.154',26379)],
                   )
# you will need to handle yourself the connection to pass again the password
# and avoid AuthenticationError at redis queries
host, port = sentinel.discover_master("mymaster")

#redis_client = redis.StrictRedis(
#            host=host,
#            port=port,
#            password= YOUR_REDIS_PASSWORD
#        )

#r = redis.Redis(
#host='192.168.1.153',
#port=6379,)

print(f"host: {host} port: {port}")

r = redis.Redis(
host=host,
port=port)

i = 1

while True:
    store = "store" + str(i)
    r.set('ikea', store)
    reading = r.get('ikea').decode('utf-8')
    if store == reading:
        if (i % 1000 == 0):
            print(f"Stored and received the same: {reading}")
    else:
        print(f"I received something different. store: {store} received: {reading}")
        break
    i += 1
