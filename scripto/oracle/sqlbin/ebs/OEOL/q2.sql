-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

clear breaks

break on report on line_end_date
compute sum of wias_count on report
compute sum of wiash_count on report
col header_status format a15
col hdr_wf_completed_or_not format a15
col line_status format a15
col oeol_wf_completed_or_not format a15
set pages 100 lines 120 

spool q2
prompt ===============================================================================================================================
prompt WHAT DOES THIS REPORT DO?:
prompt +++++++++++++++++++++++++
prompt This report summarizes header status and oeol wf items which ended on a particular date and which are PERFECTLY eligible to
prompt to be purged by the regular FNDPURGE concurrent job
prompt 
prompt THESE CRITERIA IS SATISFIED:
prompt ++++++++++++++++++++++++++++
prompt
prompt 1) Parent WF (OEOH  + possible all recursive (great)..grand) WFERROR/OMERROR children of OEOH wf item) are closed
prompt 2) Child  WF (OEOL + possible  all recursive (great)..grand) WFERROR/OMERROR children of OEOL wf items) are closed
prompt 
prompt ===============================================================================================================================

select distinct line_end_date, 
                round(sysdate-to_date(line_end_date,'dd-mon-rrrr'),2) Age_in_days, 
                header_status, 
                decode(header_begin_date,'PURGED', 'PURGED',
                                         decode(header_end_date,'NULL','not completed!', 'completed')
                      ) hdr_wf_completed_or_not,
                line_status, 
                decode(line_begin_date,'PURGED', 'PURGED',
                                         decode(line_end_date,'NULL','not completed!', 'completed')
                      ) oeol_wf_completed_or_not,
                sum(WIAS_IMPACT) wias_count, sum(WIASH_IMPACT) wiash_count
from merged_oeoh_oeol_wf
 where LINE_END_DATE !='NULL'
   and LINE_REC_OPEN_PARENT = 0
   and LINE_REC_OPEN_CHILDREN=0
group by line_end_date, 
         round(sysdate-to_date(line_end_date,'dd-mon-rrrr'),2),
         header_status, 
         decode(header_begin_date,'PURGED', 'PURGED',
                                  decode(header_end_date,'NULL','not completed!', 'completed')
               ),
         line_status, 
         decode(line_begin_date,'PURGED', 'PURGED',
                                 decode(line_end_date,'NULL','not completed!', 'completed')
               ) 
order by decode(line_end_date,'NULL',0,to_number(to_char(to_date(line_end_date,'dd-mon-rr'),'yyyymmdd')))
/
spool off
exit
/

