prompt Display bloom filters used by a PX session from V$SQL_JOIN_FILTER...

SELECT
    QC_SESSION_ID    qc_sid    
  , QC_INSTANCE_ID   inst_id 
  , SQL_PLAN_HASH_VALUE sql_hash_value
  , LENGTH     bytes_total
  , LENGTH * 8 bits_total
  , BITS_SET   bits_set
  , TO_CHAR(ROUND((bits_set/(length*8))*100,1),'999.0')||' %' pct_set          
  , FILTERED             
  , PROBED               
  , ACTIVE               
FROM
    GV$SQL_JOIN_FILTER
WHERE
  qc_session_id LIKE 
        upper(CASE 
          WHEN INSTR('&1','@') > 0 THEN 
              SUBSTR('&1',INSTR('&1','@')+1)
          ELSE
              '&1'
          END
             ) ESCAPE '\'
AND qc_instance_id LIKE
    CASE WHEN INSTR('&1','@') > 0 THEN
      UPPER(SUBSTR('&1',1,INSTR('&1','@')-1))
    ELSE
      USERENV('instance')
    END ESCAPE '\'
/

