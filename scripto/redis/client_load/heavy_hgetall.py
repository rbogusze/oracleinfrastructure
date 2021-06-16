from redis.sentinel import Sentinel
import redis
import time
import uuid

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

while True:
    r.hgetall("remi_dict")
    #print("hgetall complete, repeating")
    # this is causing OOM, not what I want now
    #r.keys("*")
    #print("finished keys command")
