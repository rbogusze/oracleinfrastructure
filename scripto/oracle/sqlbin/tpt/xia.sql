prompt Display Execution plan in advanced format for sqlid &1

--select * from table(dbms_xplan.display_cursor('&1',null,'ADVANCED +ALLSTATS LAST +PEEKED_BINDS'));
select * from table(dbms_xplan.display_cursor('&1',null,'ADVANCED +ALLSTATS LAST +PEEKED_BINDS'));
