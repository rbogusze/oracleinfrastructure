SELECT 
    (to_date(&1) - to_date('01011970','ddmmyyyy')) * 24*60*60 SECONDS_EPOCH
FrOM DUAL
/

