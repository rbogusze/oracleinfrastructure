set pages 999
set lines 99

ttitle 'Contents of Data Buffers'

drop table PGF_DIAG_T1;

create table PGF_DIAG_T1 as
select
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   count(distinct file# || block#)         num_blocks
from
   dba_objects  o,
   v$bh         bh
where
   o.data_object_id  = bh.objd
and
   o.owner not in ('SYS','SYSTEM')
and
   bh.status != 'free'
group by
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
order by
   count(distinct file# || block#) desc
;

column c0 heading "Owner"                                    format a12
column c1 heading "Object|Name"                              format a30
column c2 heading "Object|Type"                              format a8
column c3 heading "Number of|Blocks in|Buffer|Cache"         format 99,999,999
column c4 heading "Percentage|of object|blocks in|Buffer"    format 999
column c5 heading "Buffer|Pool"                              format a7
column c6 heading "Block|Size"                               format 99,999
column c7 heading "MB in|Cache"                               format 99999

select
   PGF_DIAG_T1.owner                                          c0,
   object_name                                       c1,
   case when object_type = 'TABLE PARTITION' then 'TAB PART'
        when object_type = 'INDEX PARTITION' then 'IDX PART'
        else object_type end c2,
   sum(num_blocks)                                     c3,
   (sum(num_blocks)/greatest(sum(blocks), .001))*100 c4,
   buffer_pool                                       c5,
   sum(bytes)/sum(blocks)                            c6,
   round(sum(num_blocks)/1024/1024*sum(bytes)/sum(blocks))                            c7
from
   PGF_DIAG_T1,
   dba_segments s
where
   s.segment_name = PGF_DIAG_T1.object_name
and
   s.owner = PGF_DIAG_T1.owner
and
   s.segment_type = PGF_DIAG_T1.object_type
and
   nvl(s.partition_name,'-') = nvl(PGF_DIAG_T1.subobject_name,'-')
group by
   PGF_DIAG_T1.owner,
   object_name,
   object_type,
   buffer_pool
having
   sum(num_blocks) > 10
order by
   sum(num_blocks) desc
;


ttitle 'Summary of the space in cache that are used.'
SELECT SUM(num_blocks) "Busy Blocks in cache"
  , round(SUM(num_blocks) * (SUM(bytes) / SUM(blocks))/1024/1024) "MB in cache occupied by blocks"
FROM PGF_DIAG_T1,
  dba_segments s
WHERE s.segment_name = PGF_DIAG_T1.object_name
 AND s.owner = PGF_DIAG_T1.owner
 AND s.segment_type = PGF_DIAG_T1.object_type
;

ttitle 'Raw cache size.'
select id, name "Cache name", block_size, buffers, round(block_size*buffers/1024/1024) MB  from v$buffer_pool;
