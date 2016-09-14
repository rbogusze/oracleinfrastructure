--Exerything that has been executed only once is just a wastege of space, and indication that we use code that is not reusable.
select executions, count(*) from v$sql group by executions order by 2 desc;

--How many unique SQLs do we have in shared pool.
select count(*) from v$sql;

--Just looking at how usefull parsing and storing parsed statement can be let's just sort it by executions count
select executions from v$sql order by executions desc;

--What shared pool areas take largest amount of space
select name, round(bytes/(1024 * 1024)) size_mb, resizeable from v$sgainfo order by 2 desc;
select * from V$LIBRARY_CACHE_MEMORY ;
select pool, name, round(bytes/(1024 * 1024)) size_mb from v$sgastat where pool='shared pool' and bytes > (1024 * 1024) order by size_mb desc;

-- SHARED_POOL_SIZE is too small if REQUEST_FAILURES is greater than zero and increasing.
select * from V$SHARED_POOL_RESERVED;

-- group those executed only once by the module from which they are coming from
select module, count(*) from v$sql where executions = 1 group by module order by 2 desc;

-- show SQLs from particular module
select * from v$sql where executions = 1 and module = 'e:AR:frm:XXXLCMCUST';

