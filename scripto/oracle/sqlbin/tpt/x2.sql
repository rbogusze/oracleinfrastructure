set termout off

0 explain plan for

run

set termout on

select * from table(dbms_xplan.display);

