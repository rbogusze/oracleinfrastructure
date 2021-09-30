# simple test to get some data out of ES, uses shakespear index
from datetime import datetime
#from elasticsearch import Elasticsearch
from elasticsearch5 import Elasticsearch
import random
import time

es = Elasticsearch(["red01", "red02", "red03"], port=9200, sniff_on_start=True, sniff_on_connection_fail=True, sniffer_timeout=60)


word_file = "./wordlist.10000"
WORDS = open(word_file).read().splitlines()


# Do this search in endless loop
while True:

    word = random.choice(WORDS)
    print(f"--- Searching for: {word}")

    #search_phrase = "to be or not to be"
    search_phrase = word

    res = es.search(index="shakespeare", body={"query": {"match_phrase": {"text_entry" : search_phrase}}})
    print("Got %d Hits:" % res['hits']['total'])
    for hit in res['hits']['hits']:
        print("%(line_id)s %(play_name)s: %(text_entry)s" % hit["_source"])

    time.sleep(1)
