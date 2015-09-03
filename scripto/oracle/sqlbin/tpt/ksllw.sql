select 
    indx,
    trim(to_char(indx, 'XXXX')) ihex,
    ksllwnam, 
    ksllwlbl 
from x$ksllw 
where 
    lower(to_char(indx)) like lower('&1')
or  lower(trim(to_char(indx, 'XXXX'))) like lower('&1')
/