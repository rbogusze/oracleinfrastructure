SELECT
    name
  , offloadable
--  , usage
  , minargs
  , maxargs
--  , descr 
FROM
    v$sqlfn_metadata 
WHERE 
    UPPER(name) LIKE UPPER('%&1%')
/

