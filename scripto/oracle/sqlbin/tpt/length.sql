select 
    length('&1') len_dec 
  , '0x'||trim(to_char(length('&1'), 'XXXXXXXXXXXXXXXX')) len_hex 
from dual
/
