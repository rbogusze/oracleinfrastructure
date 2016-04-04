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

spool q11
prompt ============================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING:
prompt ++++++++++++++++++++++++++++++
prompt Trend monthly (order creation_date) sorted aggregate ON ORDERS which have ALL lines CANCELLED/CLOSED per Order Management.
prompt 
prompt -->THIS REPORT CONSIDERS ORDER MANAGEMENT STATUS AS THE SOURCE OF TRUTH.
prompt 
prompt HOW TO INTERPRET THE OUTPUT:
prompt +++++++++++++++++++++++++++
prompt 1) Ideally speaking, All these Orders should be CLOSED and OEOH workflow should be COMPLETED as well. Any outstanding Errors for OEOH 
prompt    workflow should be resolved by running $FND_TOP/sql/wfstat.sql for specific OEOH item_keys and reading through the output.
prompt 
prompt 2) It also shows the % of INCOMPLETE child OEOL wfs per Order. Ideally speaking, All the OEOL child WFs should be COMPLETED as well.
prompt    Running  $FND_TOP/sql/wfstat.sql for specific OEOL items and reading through the output/history is warranted.
prompt 
prompt 3) This report should trigger an investigation as to why the corresponding Orders have open child OEOL wfs in the first
prompt    place ? One of the main causes of this can be customizations in the OEOH/OEOL workflow. For more information, 
prompt    please see Note 402144.1 - Best practice considerations for Order management workflow customizations
prompt ============================================================================================================================================

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
  and u.header_id=m.header_id
  and u.WF_PERCENT_CLOSED!=100
group by to_number(to_char(u.om_begin_date,'yyyymm')),
         u.om_PERCENT_CLOSED || ' %',
         range(u.WF_PERCENT_CLOSED,5,100) || ' %',
         m.header_status,
         decode(header_begin_date,'PURGED', 'PURGED',
                                   decode(header_end_date,'NULL','not completed!', 'completed')
               ),
         nvl(u.INCOMPLETE_LINE_STATUS,'All lines processed as per OM')
order by yyyymm, 
         WIAS_IMPACT desc
/
spool off
exit
/

