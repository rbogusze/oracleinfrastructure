SELECT 
    s1.event
  , s1.blocking_session
  , s1.blocking_session_Status
  , s1.final_blocking_session
  , s1.final_blocking_session_status
  , s2.state
  , s2.event 
FROM 
    v$session s1
  , v$session s2 
WHERE 
    s1.state = 'WAITING' 
AND s1.event = 'enq: HV - contention'
AND s1.final_blocking_session = s2.sid
/

