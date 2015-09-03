SELECT plan_hash_value, MIN(sql_id), MAX(sql_id), SUM(sharable_mem), COUNT(*) FROM v$sql GROUP BY plan_hash_value HAVING COUNT(*) > 100
/
