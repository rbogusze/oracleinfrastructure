col hp_addrlen new_value _hp_addrlen

set termout off
select vsize(addr)*2 hp_addrlen from x$dual;
set termout on

select * from x$ksmhp where KSMCHDS = hextoraw(lpad('&1', &_hp_addrlen, '0'));