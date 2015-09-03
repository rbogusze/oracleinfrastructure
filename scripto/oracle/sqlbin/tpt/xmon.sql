-- v$sql_plan_monitor IO figures buggy as of 12.1.0.1.0

COL xmon_plan_operation HEAD PLAN_LINE FOR A70


SELECT 
    plan_line_id id 
  , LPAD(' ',plan_depth) || plan_operation 
      ||' '||plan_options||' ' 
      ||plan_object_name xmon_plan_operation 
  , ROUND(physical_read_bytes / 1048576) phyrd_mb 
  , ROUND(io_interconnect_bytes / 1048576) ret_mb 
  , (1-(io_interconnect_bytes/NULLIF(physical_read_bytes,0)))*100 "SAVING%" 
FROM 
    v$sql_plan_monitor 
WHERE 
    sql_id = '&1'
AND sql_exec_start = (SELECT MAX(sql_exec_start) FROM v$sql_monitor WHERE sql_id='&1')
/
