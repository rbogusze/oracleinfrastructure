select
    name 
from
    system_privilege_map
where
    lower(name) like lower('%&1%')
/

