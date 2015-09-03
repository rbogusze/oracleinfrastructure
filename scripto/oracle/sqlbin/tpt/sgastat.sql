select * from v$sgastat 
where lower(name) like lower('%&1%') 
or    loweR(pool) like lower('%&1%')
order by name
/
