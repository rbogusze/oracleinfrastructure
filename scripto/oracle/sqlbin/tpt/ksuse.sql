select 
    decode(bitand(ksuseflg,19),17,'BACKGROUND',1,'USER',2,'RECURSIVE','?') status1
  , s.* 
from 
    x$ksuse s 
where 
    &1
/
