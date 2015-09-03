select * from table( dbms_xplan.display_cursor(null, null, 'ALIAS +PEEKED_BINDS +ALLSTATS LAST +MEMSTATS LAST') );
