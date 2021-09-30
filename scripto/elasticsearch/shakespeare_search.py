# simple test to get some data out of ES, uses shakespear index
from datetime import datetime
#from elasticsearch import Elasticsearch
from elasticsearch5 import Elasticsearch
es = Elasticsearch(["red01", "red02", "red03"], port=9200, sniff_on_start=True, sniff_on_connection_fail=True, sniffer_timeout=60)

res = es.search(index="shakespeare", body={"query": {"match_phrase": {"text_entry" : "to be or not to be"}}})
print("Got %d Hits:" % res['hits']['total'])
for hit in res['hits']['hits']:
    print("%(line_id)s %(play_name)s: %(text_entry)s" % hit["_source"])
