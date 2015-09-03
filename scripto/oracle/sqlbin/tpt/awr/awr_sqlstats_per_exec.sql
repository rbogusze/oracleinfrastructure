SET pagesize 5000 tab off verify off linesize 999 trimspool on trimout on null ""


SELECT
    CAST(begin_interval_time AS DATE) sample_time
  , sql_id
  , executions_delta executions
  , rows_processed_delta rows_processed
  , ROUND(rows_processed_delta / NULLIF(executions_delta,0))       rows_per_exec
  , ROUND(buffer_gets_delta    / NULLIF(executions_delta,0))       lios_per_exec
  , ROUND(disk_reads_delta     / NULLIF(executions_delta,0))       blkrd_per_exec
  , ROUND(cpu_time_delta       / NULLIF(executions_delta,0)/1000) cpu_ms_per_exec
  , ROUND(elapsed_time_delta   / NULLIF(executions_delta,0)/1000) ela_ms_per_exec
  , ROUND(iowait_delta         / NULLIF(executions_delta,0)/1000) iow_ms_per_exec
  , ROUND(clwait_delta         / NULLIF(executions_delta,0)/1000) clw_ms_per_exec
  , ROUND(apwait_delta         / NULLIF(executions_delta,0)/1000) apw_ms_per_exec
  , ROUND(ccwait_delta         / NULLIF(executions_delta,0)/1000) ccw_ms_per_exec
FROM
    dba_hist_snapshot
  NATURAL JOIN
    dba_hist_sqlstat
WHERE
    begin_interval_time > SYSDATE - 7
AND sql_id = '&1'
ORDER BY
    sample_time
/

