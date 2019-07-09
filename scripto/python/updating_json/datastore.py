#!/usr/bin/env python3
from google.cloud import datastore
# Create & store an entity
client = datastore.Client(project="remi-test-241607")
entity = datastore.Entity(key=client.key('stringi', '5629499534213120'))
entity.update({
    'foo': u'bar',
    'baz': 1337,
    'qux': False,
})
# Actually save the entity
client.put(entity)
