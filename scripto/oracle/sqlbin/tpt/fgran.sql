select
        *
from 
	x$ksmge 
where 
	to_number(substr('&1', instr(lower('&1'), 'x')+1) ,lpad('X',vsize(addr)*2,'X')) 
	between 
		to_number(baseaddr,lpad('X',vsize(addr)*2,'X'))
	and	to_number(baseaddr,lpad('X',vsize(addr)*2,'X')) + gransize - 1
/