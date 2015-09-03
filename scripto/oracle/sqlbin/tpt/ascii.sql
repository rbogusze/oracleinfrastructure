select
    r*4+0, chr(r*4+0),
    r*4+1, chr(r*4+1),
    r*4+2, chr(r*4+2),
    r*4+3, chr(r*4+3)
from (
    select
        rownum-1 r
    from 
        dual connect by level <=64
)
/
