-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

break on yyyymm skip 1
compute sum of ORDER_WIAS_IMPACT on yyyymm
compute sum of ORDER_WIASH_IMPACT on yyyymm
set lines 150 pages 1000
col oeol_wf_completion_range format a10
col om_completion format a10
col INCOMPLETE_LINE_STATUS format a60
col line_statuses_summary format a30
col header_status format a15
col hdr_wf_completed_or_not format a15

spool q11_3
prompt =================================================================================================================================
prompt WHAT IS THIS REPORT? --> This is the detailed drill down report of q11_2.sql at the Order level information
prompt 
prompt     THE PHILOSOPHY OF THIS REPORT IS: 
prompt     +++++++++++++++++++++++++++++++++
prompt     Workflow is only there to facilitate OM processing. If OM status of Order is closed/cancelled, corresponding 
prompt     open OEOH/OEOL workflow records become irrelevant. This report considers OM as the source of processing required.
prompt
prompt --> PLEASE NOTE THAT  AGGREGATION IS DONE on Month-Year WHEN ORDER WAS CREATED
prompt 
prompt HOW TO INTERPRET THE OUTPUT:
prompt +++++++++++++++++++++++++++
prompt 1) Since All these orders dont need any more OM processing to be done, neither the OEOH or OEOL wf are
prompt    relevant and can simply be aborted / purged. Please contact Workflow Development via Oracle Support for evaluating this.
prompt 
prompt 2) This report should trigger an investigation on specific ORDERSs as to why they have open OEOEH or child OEOL wfs in the first
prompt    place ? The primary cause of this would be customizations in the OEOH/OEOL workflow. 
prompt 
prompt    --> For more information, please see Note 402144.1 - Best practice considerations for Order management workflow customizations
prompt =================================================================================================================================

select distinct 
       m.order_number,
       to_number(to_char(u.om_begin_date,'yyyymm')) yyyymm,
       range(u.WF_PERCENT_CLOSED,5,100) || ' %' oeol_wf_completion_range,
       m.header_status,
       decode(header_begin_date,'PURGED', 'PURGED',
                                 decode(header_end_date,'NULL','not completed!', 'completed')
             ) hdr_wf_completed_or_not,
       nvl(u.INCOMPLETE_LINE_STATUS,'All lines processed as per OM') line_statuses_summary,
       sum(m.WIAS_IMPACT) ORDER_WIAS_IMPACT,
       sum(m.WIASH_IMPACT) ORDER_WIASH_IMPACT
from  unique_orders  u,
      merged_oeoh_oeol_wf m
where rtrim(u.INCOMPLETE_LINE_STATUS) is null
  and u.WF_PERCENT_CLOSED != 100
  and u.header_id=m.header_id
group by 
         m.order_number,
         to_number(to_char(u.om_begin_date,'yyyymm')),
         range(u.WF_PERCENT_CLOSED,5,100) || ' %',
         m.header_status,
         decode(header_begin_date,'PURGED', 'PURGED',
                                   decode(header_end_date,'NULL','not completed!', 'completed')
               ),
         nvl(u.INCOMPLETE_LINE_STATUS,'All lines processed as per OM')
having  m.header_status in ('CLOSED','CANCELLED')
order by yyyymm, 
         ORDER_WIAS_IMPACT desc
/
spool off
exit
/

