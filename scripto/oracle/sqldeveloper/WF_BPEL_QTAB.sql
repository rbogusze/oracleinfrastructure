select * from GV$QMON_TASKS;
select * from GV$QMON_SERVER_STATS;
show parameter aq;

select * from dba_objects where object_name like 'AQ$_WF_BPEL_QTAB%';
select * from dba_objects where object_name like '%WF_BPEL_QTAB%' and owner='APPS';

select count(*), msg_state from AQ$WF_BPEL_QTAB group by msg_state;
/*
COUNT(*)	MSG_STATE
20418882	READY
11146	EXPIRED
19766924	PROCESSED
*/

select count(*) from AQ$_WF_BPEL_QTAB_I;
--20422322
select count(*) from AQ$_WF_BPEL_QTAB_L;
--0
select count(*) from AQ$_WF_BPEL_QTAB_H;
--40196958
select count(*) from AQ$_WF_BPEL_QTAB_T;
--0

select * from dba_segments where segment_name like '%WF_BPEL_QTAB%' and owner='APPS';
select sum(bytes)/1024/1024 MB from dba_segments where segment_name='AQ$_WF_BPEL_QTAB_S';
-- 2MB
select sum(bytes)/1024/1024 MB from dba_segments where segment_name='WF_BPEL_QTAB';
-- 33537MB
select sum(bytes)/1024/1024 MB from dba_segments where segment_name='AQ$_WF_BPEL_QTAB_L';
-- 1MB


