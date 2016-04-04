-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

clear breaks computes  col
break on report
compute sum of line_wias on report
compute sum of line_wiash on report
compute sum of order_wias on report
compute sum of order_wiash on report
col line_status format a25
set pages 100 lines 150

spool q4
prompt ========================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING: 
prompt +++++++++++++++++++++++++++++++
prompt Estimate WIAS and WIAS_H impact (rows) for INCOMPLETE OEOL wf items which have ACTIVE OMERROR/WFERROR child wf items 
prompt 
prompt HOW TO INTERPRET THE OUTPUT:
prompt ++++++++++++++++++++++++++++
prompt 1) Direct impact (LINE_WIAS / LINE_WIASH - columns in the output)
prompt
prompt 2) In-Direct impact (ORDER_WIAS / ORDER_WIASH - columns in the output)
prompt    (These Order lines in ERROR are further impacting the closure of the corresponding Order headers and OEOH wf)
prompt
prompt SUGGESTED THINGS TO DO: 
prompt ++++++++++++++++++++++
prompt Review the output of $FND_TOP/sql/wfstat.sql for these OEOL Lines and see why there are so many OMERROR/WFERROR child items created.
prompt Maybe you will be able to catch something systemic which can be fixed with a little review and thought.
prompt ========================================================================================================================================
select distinct 
                --m.header_id,
                m.header_status, 
                --m.line_id,
                m.line_status, 
                m.line_end_date, 
                sum(u.wias_impact_total) order_wias, 
                sum(u.wiash_impact_total) order_wiash, 
                sum(m.line_wias) line_wias, 
                sum(m.line_wiash) line_wiash
from 
    (select 
            header_id, 
            header_status, 
            --line_id, 
            line_status, 
            line_end_date, 
            sum(WIAS_IMPACT) line_wias,
            sum(wiash_impact) line_wiash
       from merged_oeoh_oeol_wf  
      where LINE_END_DATE='NULL'
        and LINE_REC_OPEN_CHILDREN > 1
   group by
            header_id, 
            header_status, 
            --line_id,
            line_status, 
            line_end_date
    ) m,
    unique_orders u
where m.header_id=u.header_id
group by
         --m.header_id,
         m.header_status,
         --m.line_id,
         m.line_status,
         m.line_end_date
order by  m.header_status, 
          m.line_status
/
spool off
exit
/

