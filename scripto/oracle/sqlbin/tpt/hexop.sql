select 
    to_char( to_number('&1', 'XXXXXXXXXXXXXXXXXX') &2 to_number('&3', 'XXXXXXXXXXXXXXXXXX'), 'XXXXXXXXXXXXXXXXXX') hex,
    to_number('&1', 'XXXXXXXXXXXXXXXXXX') &2 to_number('&3', 'XXXXXXXXXXXXXXXXXX') dec
from 
    dual
/
