col segstat_statistic_name head STATISTIC_NAME for a35

SELECT * FROM (
  SELECT 
	owner, 
	object_name, 
	statistic_name segstat_statistic_name,
	value 
  FROM 
	v$segment_statistics 
  WHERE 
	lower(statistic_name) LIKE lower('%&1%')
   order by value desc
)
WHERE rownum <= 40
/
