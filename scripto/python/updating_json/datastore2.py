from google.cloud import datastore
# Create, populate and persist an entity with keyID=1234
client = datastore.Client()
key = client.key('stringi', 5629499534213120)
entity = datastore.Entity(key=key)
entity.update({
    'foo': u'bar',
    'baz': 1337,
    'qux': False,
})
client.put(entity)
# Then get by key for this entity
result = client.get(key)
print(result)
