-- 3600 MHz  SPARC-T5 Elapsed: 00:00:02.61
-- Intel(R) Xeon(R) CPU E5-2609 v2 @ 2.50GHz Elapsed: 00:00:01.80
select count(*) from (SELECT 'F' || TO_CHAR(Level - 1)          AS FibonacciOrdinal,
       (      (POWER(1 + SQRT(5), Level - 1) 
          -    POWER(1 - SQRT(5), Level - 1))
       / (POWER(2, Level - 1) * SQRT(5))) AS FibonacciNumber
FROM Dual d
CONNECT BY Level <= 4500000);
