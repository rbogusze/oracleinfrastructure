select     &1 , count(*) 
from       &2 
group by   &1
order by   count(*) desc
/
