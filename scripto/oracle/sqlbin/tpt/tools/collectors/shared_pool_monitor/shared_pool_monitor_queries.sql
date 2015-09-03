SELECT
     SAMPLE_TIME                      
  ,  SUBPOOL                         
  ,  DURATION                        
  ,  FLUSHED_CHUNKS_D                
  ,  LRU_OPERATIONS_D                
  ,  RESERVED_SCANS                  
  ,  RESERVED_MISSES                 
  ,  UNSUCCESSFUL_FLUSHES            
  ,  LAST_UNSUCC_MISS_REQ_SIZE       
  ,  LAST_UNSUCC_FLUSH_REQ_SIZE      
FROM
     sys.SPMON_HEAP_ACTIVITY_VIEW
WHERE
    sample_time BETWEEN %FROM_DATE% AND %TO_DATE%

