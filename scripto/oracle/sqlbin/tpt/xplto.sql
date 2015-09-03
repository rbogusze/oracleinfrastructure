prompt Show execution plan operations and options matching &1 (11g+)

SELECT RPAD('OPERATION',20) "TYPE", TO_CHAR(indx,'XX') hex, xplton_name FROM x$xplton WHERE lower(xplton_name) LIKE lower('%&1%')
UNION ALL
SELECT 'OPTION', TO_CHAR(indx,'XX'), xpltoo_name FROM x$xpltoo WHERE lower(xpltoo_name) LIKE lower('%&1%')
/
 
