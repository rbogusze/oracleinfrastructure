SELECT
    NVL(qc_instance_id, inst_id)           user_inst_id
  , MIN(TO_CHAR(sql_exec_id,'XXXXXXXX'))   min_sql_exec_id
  , MAX(TO_CHAR(sql_exec_id,'XXXXXXXX'))   max_sql_exec_id
FROM
    gv$active_session_history
GROUP BY
    NVL(qc_instance_id, inst_id)
ORDER BY
    user_inst_id
/

