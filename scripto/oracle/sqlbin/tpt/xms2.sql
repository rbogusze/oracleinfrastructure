select * from table(dbms_xplan.display_cursor(format=>'ALLSTATS LAST'));
