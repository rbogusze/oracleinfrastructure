prompt Show top space users per tablespace - show each partition separately...

col topseg_segment_name head SEGMENT_NAME for a30
col topseg_seg_owner HEAD OWNER FOR A30

select * from (
	select 
		tablespace_name, 
		owner topseg_seg_owner, 
		segment_name topseg_segment_name, 
		--partition_name,
		segment_type, 
		round(SUM(bytes/1048576)) MB,
    case when count(*) > 1 then count(*) else null end partitions
	from dba_segments
	where upper(tablespace_name) like upper('%&1%')
  group by
		tablespace_name, 
		owner, 
		segment_name,
		segment_type 
	order by MB desc
)
where rownum <= 30;

