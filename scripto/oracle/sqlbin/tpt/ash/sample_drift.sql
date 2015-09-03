select to_char(sample_time,'YYYYMMDD HH24:MI'), sample_time-lag(sample_time) over(order by sample_time) from (select distinct sample_time from v$active_session_history);

