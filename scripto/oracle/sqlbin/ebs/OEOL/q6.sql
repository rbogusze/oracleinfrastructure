-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- Please read through the header of the report to have a better understanding of its function.
-- =====================================================================================================

compute sum of wias_count on HEADER_MON_RR
compute sum of wiash_count on HEADER_MON_RR

col HEADER_MON_RR format a10
col hdr_wf_completed_or_not format a25
col line_wf_completed_or_not format a25
col header_status format a15
col line_status format a15

set pages 100 lines 150
break on report on HEADER_MON_RR skip 1

compute sum of wias_count on HEADER_MON_RR
compute sum of wiash_count on HEADER_MON_RR

col HEADER_MON_RR format a10
col hdr_wf_completed_or_not format a25
col line_wf_completed_or_not format a25
col header_status format a15
col line_status format a15

set pages 100 lines 150

spool q6_2

prompt ===========================================================================================================================================
prompt THIS REPORT DOES THE FOLLOWING:
prompt ++++++++++++++++++++++++++++++
prompt Shows Monthly Aggregate WIAS (WF_ITEM_ACTIVITY_STATUSES) and WIAS_H (WF_ITEM_ACTIVITY_STATUSES_H) impact (rows) for DISTINCT COMBINATIONS of 
prompt OM Header Status, OEOH status,  OM line status, OEOL status for Orders which have ALL lines CLOSED/CANCELLED
prompt
prompt --> PLEASE NOTE THAT AGGREGATION IS DONE ON Month-Year WHEN THE Order WAS CREATED
prompt
prompt HOW TO INTERPRET THE OUTPUT:
prompt ++++++++++++++++++++++++++++
prompt 1) Ideally speaking, All rows should have hdr_wf_completed_or_not='COMPLETED', line_wf_completed_or_not='COMPLETED',
prompt    header_status and line_status=CLOSED/CANCELLED.
prompt
prompt 2) Simply speaking, If the OM status=CLOSED/CANCELLED the corresponding WF status (OEOH/OEOL) should also be 'completed'.
prompt
prompt    --> If this is not the case, its a good candidate for investigation and reviewing data fix patches in Note 398822.1 will help.
prompt    --> Note 402144.1 - Best practices considerations for OM workflow customizations should also be reviewed.
prompt ===========================================================================================================================================

select distinct substr(m1.header_begin_date,4,7) HEADER_MON_RR,
                m1.header_status,
                decode(header_begin_date,'PURGED', 'PURGED',
                                         decode(header_end_date,'NULL','not completed!', 'completed')
                      ) hdr_wf_completed_or_not,
                m1.line_status,
                decode(line_begin_date,'PURGED', 'PURGED',
                                         decode(line_end_date,'NULL','not completed!', 'completed')
                      ) line_wf_completed_or_not,
                sum(m1.wias_impact) wias_count, sum(m1.wiash_impact) wiash_count
from merged_oeoh_oeol_wf m1
where
 --
 -- Can un-comment this predicate below to filter data for a particular month only
 --
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
 -- Had to put this clause to make sure that it didnt query Order records which had corresponding OEOH wf records purged
 -- due to manual Workflow un-supported tweaking!!
 --
 and header_begin_date!='PURGED'
group by
        substr(m1.header_begin_date,4,7),
        m1.header_status,
        decode(header_begin_date,'PURGED', 'PURGED',
                                 decode(header_end_date,'NULL','not completed!', 'completed')
              ),
        m1.line_status,
        decode(line_begin_date,'PURGED', 'PURGED',
                                decode(line_end_date,'NULL','not completed!', 'completed')
              )
order by to_number(to_char(to_date(substr(m1.header_begin_date,4,7),'mon-rr'),'YYYYMM'))
/
spool off
exit
/

