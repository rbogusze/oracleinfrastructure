-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

break on report
compute sum of wias_count on report
compute sum of wiash_count on report
col line_wf_completed_or_not format a15
col hdr_wf_completed_or_not format a15

prompt ===========================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING:
prompt ++++++++++++++++++++++++++++++
prompt
prompt This report will DRILL DOWN on orders which have OM header_status and OM line_status columns = CLOSED/CANCELLED 
prompt and EITHER (hdr_wf_completed_or_not OR line_wf_completed_or_not column ) = 'not completed!'. All these are cause for worry.
prompt
prompt This report is a subset of q6_3.sql
prompt
prompt --> Recursive Open Parent workflow count = ((great)..grand) Parent workflow items count
prompt --> Recursive Open Child workflow count = ((great)..grand) Child workflow items count
prompt
prompt BOTH Recursive Open Parent workflow count and  Recursive Open Child workflow count Should be 0 for OEOL to be purged automatically
prompt
prompt HOW TO INTERPRET THE OUTPUT:
prompt ++++++++++++++++++++++++++++
prompt 1) Ideally speaking, All rows should have hdr_wf_completed_or_not='COMPLETED', line_wf_completed_or_not='COMPLETED',
prompt    header_status and line_status=CLOSED/CANCELLED.
prompt
prompt  ==> PLEASE NOTE that One row of output could be potentially corresponding to Multiple "Similar" Order Lines in One Order.
prompt
prompt 2) Simply speaking, If the OM status=CLOSED/CANCELLED the corresponding WF status (OEOH/OEOL) should also be 'completed'.
prompt
prompt    --> If this is not the case, its a good candidate for investigation and reviewing data fix patches in Note 398822.1 will help.
prompt    --> Note 402144.1 - Best practices considerations for OM workflow customizations should also be reviewed.
prompt ===========================================================================================================================================

spool q6_4

select distinct m1.order_number,
                m1.header_status,
                decode(header_begin_date,'PURGED', 'PURGED',
                                         decode(header_end_date,'NULL','not completed!', 'completed')
                      ) hdr_wf_completed_or_not,
                m1.line_status,
                decode(line_begin_date,'PURGED', 'PURGED',
                                         decode(line_end_date,'NULL','not completed!', 'completed')
                      ) line_wf_completed_or_not,
                line_rec_open_parent,
                line_rec_open_children,
                sum(m1.wias_impact) wias_count, sum(m1.wiash_impact) wiash_count
from merged_oeoh_oeol_wf m1
where
 --to_char(to_date(line_begin_date,'dd-mon-rr'),'yyyymm')='200510'
 --and
 --
 -- have to use this criteria to rein in cases which have lines with OM status completed
 --
 (line_status in ('CLOSED','CANCELLED')
 or
 --
 -- have to use this criteria to rein in cases which have lines with completed OEOL wf
 --
 line_end_date !='NULL'
 )
 --
 -- make sure the order which the line belongs to doesnt have any other line which is not 'CLOSED','CANCELLED'
 --
 and not exists
 (select null from merged_oeoh_oeol_wf m2 where m1.header_id=m2.header_id and m2.line_status not in ('CLOSED','CANCELLED') )
 --
 -- Had to put this to make sure that it didnt query Order records which had corresponding OEOH wf records purged
 -- due to some manual tweaking!!
 --
 and header_begin_date!='PURGED'
 --
 --
 and (decode(header_end_date,'NULL','not completed!', 'completed')='not completed!'
      or 
      decode(line_end_date,'NULL','not completed!', 'completed')='not completed!'
     )
 and header_status in ('CLOSED','CANCELLED')
 and line_status in ('CLOSED','CANCELLED')
group by
        order_number,
        m1.header_status,
        decode(header_begin_date,'PURGED', 'PURGED',
                                 decode(header_end_date,'NULL','not completed!', 'completed')
              ),
        m1.line_status,
        decode(line_begin_date,'PURGED', 'PURGED',
                                decode(line_end_date,'NULL','not completed!', 'completed')
              ),
                line_rec_open_parent,
                line_rec_open_children
/
spool off
exit
/
