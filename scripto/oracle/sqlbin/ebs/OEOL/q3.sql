-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

clear breaks
break on report on YYYYMM 
compute sum of wias_count on report
compute sum of wiash_count on report
col hdr_wf_completed_or_not format a15
col line_wf_completed_or_not format a15
col YYYYMM format a10
col header_status format a15
col line_status format a15

set pages 100 lines 120

spool q3
prompt ==========================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING: 
prompt ++++++++++++++++++++++++++++++
prompt Estimate WIAS and WIAS_H impact (rows) for CLOSED/COMPLETED oeol lines which have open OMERROR/WFERROR child wf items. 
prompt 
prompt SUGGESTED THINGS TO DO: 
prompt ++++++++++++++++++++++
prompt Review Note 398822.1, especially Patch 5604904 DATA FIX TO PURGE OUT-OF-DATE OM ERROR FLOWS (OMERROR  WFERROR)
prompt
prompt If these lines dont have any ACTIVE ERROR activities, patch 5604904 will be helpful in completing 
prompt such open WFERROR/OMERROR which should not be open anymore since the parent OEOH/OEOL wf items are 
prompt either completed or dont have any ACTIVE ERROR activities
prompt ==========================================================================================================================

select distinct
                substr(line_end_date,4) YYYYMM, 
                header_status, 
                decode(header_begin_date,'PURGED', 'PURGED',
                                         decode(header_end_date,'NULL','not completed!', 'completed')
                      ) hdr_wf_completed_or_not,
                line_status, 
                decode(line_begin_date,'PURGED', 'PURGED',
                                         decode(line_end_date,'NULL','not completed!', 'completed')
                      ) line_wf_completed_or_not,
                sum(WIAS_IMPACT) wias_count, sum(WIASH_IMPACT) wiash_count
from merged_oeoh_oeol_wf
 where LINE_END_DATE != 'NULL'
   and LINE_REC_OPEN_CHILDREN > 0
group by
                substr(line_end_date,4),
                header_status, 
                decode(header_begin_date,'PURGED', 'PURGED',
                                         decode(header_end_date,'NULL','not completed!', 'completed')
                      ) ,
                line_status, 
                decode(line_begin_date,'PURGED', 'PURGED',
                                         decode(line_end_date,'NULL','not completed!', 'completed')
                      ) 
order by to_number(to_char(to_date(substr(line_end_date,4),'mon-rr'),'yyyymm'))
/
spool off
exit
/

