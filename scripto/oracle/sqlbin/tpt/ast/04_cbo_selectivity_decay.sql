DROP TABLE selectivity_test;

CREATE TABLE selectivity_test AS
SELECT sysdate - rownum d
FROM dual connect by level <= 365;

@gts selectivity_test

@minmax d selectivity_test

@descxx selectivity_test

