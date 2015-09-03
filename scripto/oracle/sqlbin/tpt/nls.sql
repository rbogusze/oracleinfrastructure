col nls_parameter head PARAMETER for a30
col nls_value head VALUE for a50

select
    parameter nls_parameter
  , value     nls_value
from nls_session_parameters 
order by 
    parameter
/

