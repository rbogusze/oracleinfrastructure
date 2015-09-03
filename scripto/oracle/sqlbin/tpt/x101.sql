-- oracle 10.1 version (in 10.2+ use x.sql)
select * from table(dbms_xplan.display_cursor(null,null));
--select * from table(dbms_xplan.display_cursor(null,null,'RUNSTATS_LAST'));
