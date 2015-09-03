prompt Show captured binds from V$SQL_BIND_CAPTURE...

SELECT
  HASH_VALUE          
, SQL_ID              
, CHILD_NUMBER        
, NAME                
, POSITION            
, DUP_POSITION        
, DATATYPE            
, DATATYPE_STRING     
, CHARACTER_SID       
, PRECISION           
, SCALE               
, MAX_LENGTH          
, WAS_CAPTURED        
, LAST_CAPTURED       
, VALUE_STRING        
, VALUE_ANYDATA  
FROM
  v$sql_bind_capture
WHERE
    hash_value IN (&1)
AND child_number like '&2'
/
