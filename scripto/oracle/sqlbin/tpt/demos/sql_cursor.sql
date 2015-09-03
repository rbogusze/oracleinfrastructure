set echo on

select curno,status,pers_heap_mem,work_heap_mem from v$sql_cursor where status != 'CURNULL';
pause

var x refcursor
exec open :x for select * from all_objects order by dbms_random.random;
pause

declare r all_objects%rowtype; begin fetch :x into r; end;
/

pause

select curno,status,pers_heap_mem,work_heap_mem from v$sql_cursor where status != 'CURNULL';

set echo off
