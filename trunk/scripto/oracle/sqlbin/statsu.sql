prompt Show user table stats
set linesize 150
select TABLE_NAME, LAST_ANALYZED, SAMPLE_SIZE, NUM_ROWS from user_tables
where NUM_ROWS != 0
--order by TABLE_NAME
order by NUM_ROWS
/
