-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- This script creates the function for calculating a range of a particular data point between min 
-- and max limits and a specified step interval.
-- =====================================================================================================

create or replace function  range(point number, bracketsize number, maxlimit number) return varchar2
as
lower_bound  number:=0;
upper_bound  number:=0;
begin
 if bracketsize > maxlimit then
   return 'Exceeded ' || to_char(maxlimit)  || '. Not Allowed.';
 else
  upper_bound :=lower_bound+bracketsize;
  while (upper_bound <= maxlimit)
  loop
    if point between lower_bound and upper_bound then
      return to_char(lower_bound) ||' - '||to_char(upper_bound);
    end if;
    lower_bound:=lower_bound+bracketsize;
    upper_bound:=lower_bound+bracketsize;
  end loop;
 end if;
 return to_char(lower_bound) ||' - '||to_char(upper_bound);
end;
/

select range(40,20,100) from dual;
select range(40,30,100) from dual;
select range(40,10,100) from dual;
