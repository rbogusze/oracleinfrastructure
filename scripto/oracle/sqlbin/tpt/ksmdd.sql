SELECT 
    addr
  , indx
  , inst_id
  , name
  , DECODE(BITAND(flags,1),1,'DYN ','') flags
  , elements_chunk
  , items_pt
  , initentries
  , numentries
  , curentries
  , numchunks
  , elemsize
  , heap
  , secondary
FROM
    X$KSMDD
WHERE
    LOWER(name) LIKE LOWER('%&1%')
ORDER BY
    addr
/
