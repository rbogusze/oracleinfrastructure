prompt Show table stats
set linesize 150
select owner, TABLE_NAME, LAST_ANALYZED, SAMPLE_SIZE, NUM_ROWS from all_tables
where owner not in ('SYSMAN','SYS','OLAPSYS','MDSYS','CTXSYS','WMSYS','SYSTEM','XDB','ORDSYS','EXFSYS','DBSNMP')
and NUM_ROWS != 0
--order by TABLE_NAME
order by NUM_ROWS
/
