-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

break on yyyymm skip 1
compute sum of WIAS_IMPACT on yyyymm
compute sum of WIASH_IMPACT on yyyymm
set lines 150 pages 1000 
col oeol_wf_completion_range format a10
col om_completion format a10
col INCOMPLETE_LINE_STATUS format a60
col line_statuses_summary format a30
col header_status format a15
col hdr_wf_completed_or_not format a25

spool q11_2
prompt =======================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING:
prompt +++++++++++++++++++++++++++++++
prompt Trend monthly (based on Order creation date) aggregate information on orders having OM header status as CLOSED/CANCELLED 
prompt AND OM lines status as CANCELLED/CLOSED.  This report considers OM status as the source of truth.
prompt 
prompt UNIQUE INFORMATION SHOWN BY THIS REPORT:
prompt ++++++++++++++++++++++++++++++++++++++++
prompt 1) The OEOH and child OEOL workflows' statuses should be COMPLETED. It shows the % range of INCOMPLETE child OEOL wf items/Order.
prompt
prompt 2) This report should trigger an investigation as to why the underlying Orders have open OEOH or child OEOL WFs in the first place ? 
prompt    
prompt 3) For drilling down more on this summary, run @q11_3.sql drill down report
prompt    
prompt    ---> For more information, please see Note 402144.1 - Best practice considerations for Order management workflow customizations
prompt =======================================================================================================================================

select distinct 
       to_number(to_char(u.om_begin_date,'yyyymm')) yyyymm,
       u.om_PERCENT_CLOSED || ' %'om_completion,
       range(u.WF_PERCENT_CLOSED,5,100) || ' %' oeol_wf_completion_range,
       m.header_status,
       decode(header_begin_date,'PURGED', 'PURGED',
                                 decode(header_end_date,'NULL','not completed!', 'completed')
             ) hdr_wf_completed_or_not,
       nvl(u.INCOMPLETE_LINE_STATUS,'All lines processed as per OM') line_statuses_summary,
       sum(m.WIAS_IMPACT) WIAS_IMPACT,
       sum(m.WIASH_IMPACT) WIASH_IMPACT
from  unique_orders  u,
      merged_oeoh_oeol_wf m
where rtrim(u.INCOMPLETE_LINE_STATUS) is null
  and u.WF_PERCENT_CLOSED != 100
  and u.header_id=m.header_id
group by to_number(to_char(u.om_begin_date,'yyyymm')),
         u.om_PERCENT_CLOSED || ' %',
         range(u.WF_PERCENT_CLOSED,5,100) || ' %',
         m.header_status,
         decode(header_begin_date,'PURGED', 'PURGED',
                                   decode(header_end_date,'NULL','not completed!', 'completed')
               ),
         nvl(u.INCOMPLETE_LINE_STATUS,'All lines processed as per OM')
having  m.header_status in ('CLOSED','CANCELLED')
order by yyyymm, 
         WIAS_IMPACT desc
/
spool off
exit
/

