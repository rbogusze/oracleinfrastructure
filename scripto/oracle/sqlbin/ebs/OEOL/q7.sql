-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

col line_mon_rr format a10
break on report
compute sum of wias_count on report
compute sum of wiash_count on report
col line_status format a30
set pages 1000 lines 150

spool q7
prompt ========================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING:
prompt +++++++++++++++++++++++++++++++
prompt Finds OM and/or WF DATA CORRUPTION / Out Of Sync cases for these kind of Orders : 
prompt    
prompt   a) Header is CLOSED in OM,but the one of OEOH/OEOL wf is NOT CLOSED
prompt   b) Header is NOT CLOSED in OM, but the OEOH wf is CLOSED
prompt   c) Line is CLOSED in OM, but the OEOL wf is NOT CLOSED
prompt   d) Line is NOT CLOSED in OM, but the OEOL wf is CLOSED
prompt    
prompt HOW TO INTERPRET THE OUTPUT AND WHAT TO DO:
prompt ++++++++++++++++++++++++++++++++++++++++++
prompt 1) Root causes for these data corruption scenarios need to be found. This simply has to be done. Many data corruption cases can be a result
prompt    of un-supported customization practices. Please review Note 402144.1 - Best practice considerations for OM workflow customizations.
prompt
prompt 2) PLEASE IGNORE rows with header_completed_or_not='PURGED' and line_wf_completed_or_not='completed' and line_status = CLOSED/CANCELLED 
prompt
prompt 3) REMAINING ALL ROWS ARE CAUSE FOR CONCERN AND OUTLINE AT LEAST ONE DATA CORRUPTION SCENARIO
prompt ========================================================================================================================================

  select distinct header_status, 
                  decode(header_begin_date,'PURGED', 'PURGED',
                                           decode(header_end_date,'NULL','not completed!', 'completed')
                        ) hdr_wf_completed_or_not,
                  line_status, 
                  decode(line_begin_date,'PURGED', 'PURGED',
                                           decode(line_end_date,'NULL','not completed!', 'completed')
                        ) line_wf_completed_or_not,
                  sum(wias_impact) wias_count, sum(wiash_impact) wiash_count
  from merged_oeoh_oeol_wf m
  where 
          --
          -- a) Header is CLOSED in OM,but the one of OEOH/OEOL wf is NOT CLOSED
          --
          (header_status in ('CLOSED','CANCELLED') and (line_end_date='NULL' or header_end_date='NULL'))
          --
          OR
          --
          -- b) Header is NOT CLOSED in OM, but the OEOH wf is CLOSED
          --
          (header_status not in ('CLOSED','CANCELLED') and header_end_date!='NULL')
          OR
          --
          -- c) Line is CLOSED in OM, but the OEOL wf is NOT CLOSED
          --
          (line_status in ('CLOSED','CANCELLED') and line_end_date='NULL')
          OR
          --
          -- d) Line is NOT CLOSED in OM, but the OEOL wf is CLOSED
          --
          (line_status NOT in ('CLOSED','CANCELLED') and line_end_date!='NULL')
  group by header_status,   
           decode(header_begin_date,'PURGED', 'PURGED',
                                     decode(header_end_date,'NULL','not completed!', 'completed')
                 ),
           line_status, 
           decode(line_begin_date,'PURGED', 'PURGED',
                                   decode(line_end_date,'NULL','not completed!', 'completed')
                 ) 
  order by header_status, hdr_wf_completed_or_not, line_status, line_wf_completed_or_not
/
spool off
exit
/

