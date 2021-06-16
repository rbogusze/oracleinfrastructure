from redis.sentinel import Sentinel
import redis
import time
import sys
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("-f", "--file", dest="filename")
parser.add_argument("-s", "--sentinels", dest="sentinels")
parser.add_argument("-m", "--master", dest="master")
parser.add_argument("-a", "--password", dest="password")
parser.add_argument("-p", "--port", dest="port")

args = parser.parse_args()

sentinels = vars(args)["sentinels"]
master = vars(args)["master"]
password = vars(args)["password"]
port = vars(args)["port"]

print(f"sentinels: {sentinels}")
print(f"master: {master}")
print(f"password: {password}")
print(f"port: {port}")

sentinels = sentinels.split(",")
print(f"sentinels: {sentinels}")

if len(sentinels) == 2:
    sentinel = Sentinel([(sentinels[0],port),(sentinels[1],port)])
if len(sentinels) == 3:
    sentinel = Sentinel([(sentinels[0],port),(sentinels[1],port),(sentinels[2],port)])


# this is what Sentinel returns
host, port = sentinel.discover_master(master)

print("If below you can see the current master and port, it means that Sentinel works")
print(f"host: {host} port: {port}")

r = redis.Redis(
host=host,
port=port,
password=password)

i = 1

while True:
    key = "sanity_check" + str(i)
    store = "sanity_check" + str(i)
   
    r.set(key, store)
    reading = r.get(key).decode('utf-8')
    if store == reading:
        print(f"Stored and received the smae:\n key: {key}\n value: {reading}")
    else:
        print(f"I received something different. store: {store} received: {reading}")
        break
    i += 1
    time.sleep(0.1)
    break
