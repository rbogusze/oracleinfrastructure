SELECT
    TRUNC(sample_time,'MI') minute
  , sql_plan_hash_value
  , COUNT(*)/60 avg_act_ses
FROM
    v$active_session_history
  -- dba_hist_active_sess_history
WHERE
    sql_id = '&1'
GROUP BY
    TRUNC(sample_time,'MI') 
  , sql_plan_hash_value
ORDER BY
    minute, sql_plan_hash_value
/
