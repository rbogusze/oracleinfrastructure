select 
    sysdate,
    (to_date(sysdate) - to_date('01011970','ddmmyyyy')) * 24*60*60 SECONDS_EPOCH,
    to_char((to_date(sysdate) - to_date('01011970','ddmmyyyy')) * 24*60*60, 'XXXXXXXX') SEC_HEX
from 
    dual
/
