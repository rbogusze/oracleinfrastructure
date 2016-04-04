set lines 300 time on timing on echo on pages 10000

col wiash_impact format 999999
col hdr_rec_open_children format 999999
col line_rec_open_children format 999999

spool merge_oeoh_oeol_wf.lst

select w1.*, nvl(WIASH_IMPACT,0) wiash_impact ,
       GET_REC_OPEN_PARENT_COUNT(w1.line_type,to_char(w1.line_id))    line_rec_open_parent,  
       GET_REC_OPEN_CHILD_COUNT(w1.line_type,to_char(w1.line_id))     line_rec_open_children
from oeoh_oeol_wias w1,
     oeoh_oeol_wias_h w2
where w1.line_id=w2.line_id(+)
/
spool off
exit
/
