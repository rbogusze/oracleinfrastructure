prompt Show size of tablespaces
set pagesize 50
column TBS_FULL format a10
SELECT Total.name "Tablespace Name", TO_CHAR(ROUND(100-(Free_space*100/total_space), 2)) TBS_full, round(total_space) "total_space(MB)", round(Free_space) "Free_space(MB)"
FROM
 ( select tablespace_name, sum(bytes/1024/1024) Free_Space
   from sys.dba_free_space
   group by tablespace_name
 ) Free,
 ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
   from sys.v_$datafile a, sys.v_$tablespace B
   where a.ts# = b.ts#
   group by b.name
 ) Total
WHERE Free.Tablespace_name = Total.name
order by (Free_space*100/total_space) desc;
