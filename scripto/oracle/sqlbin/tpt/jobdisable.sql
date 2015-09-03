select 'exec dbms_scheduler.disable( '''||owner||'.'||job_name||''' );' 
from dba_scheduler_jobs where lower(job_name) like lower('&1');
