COL begin_interval_time FOR A30
COL end_interval_time FOR A30
COL stat_name FOR A50

SELECT
    begin_interval_time, end_interval_time, stat_name
  , CASE WHEN value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) < 0 THEN value ELSE value - LAG(value) OVER (PARTITION BY stat_name ORDER BY begin_interval_time) END value
FROM
     dba_hist_sysstat
   NATURAL JOIN
     dba_hist_snapshot
WHERE
    stat_name LIKE '%parallelized'
ORDER BY
    begin_interval_time, stat_name
/
