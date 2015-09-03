select owner, type_name, typecode, attributes, methods 
from dba_types
where lower(type_name) like lower('&1')
/
