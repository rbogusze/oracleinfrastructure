col sgares_parameter head PARAMETER for a30
col sgares_component head COMPONENT for a30

SELECT
    component		sgares_component
  , oper_type
  , oper_mode
  , parameter		sgares_parameter
  , initial_size
  , target_size
  , final_size
  , status
  , start_time
  , end_time
FROM
	v$sga_resize_ops
ORDER BY
	start_time
/
