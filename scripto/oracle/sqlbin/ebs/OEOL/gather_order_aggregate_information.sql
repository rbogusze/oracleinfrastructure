------------------------------------------------------------------------------------
-- Created -- gverma -- 22nd Feb 2007
--
-- This script creates and populates the table unique_orders with a 
-- high level summary information about each order in the system
--
-- A bulk collection strategy was used for this information gathering since it
-- was found to be EXTREMELY performance efficient. All the information was gathered
-- into memory at one shot in pl/sql tables and then all the calculations were done in 
-- memory and written in batch fashion to the unique_orders table.
--
-- Doing it the traditional way 
-- of querying up one order at a time was proving out to be a non-option and 
-- was taking HOURS!!
------------------------------------------------------------------------------------

set echo on time on timing on

drop table unique_orders;

create table  unique_orders( header_id number, 
                             om_begin_date date,
                             om_percent_closed number, 
                             wf_percent_closed number, 
                             incomplete_line_status varchar2(2000), 
                             wias_impact_total number, 
                             wiash_impact_total number
                            );
commit;

set serveroutput on size 100000 time on timing on
declare

cursor get_all_lines_info
is
select m.header_id, 
       o.creation_date ,
       decode(m.line_status,'CANCELLED','COMPLETED','CLOSED','COMPLETED',m.line_status) ,
       decode(m.line_end_date,'NULL','NOT_COMPLETED','COMPLETED') ,
       m.wias_impact,
       m.wiash_impact 
from merged_oeoh_oeol_wf m,
     oe_order_headers_all o
where m.header_id=o.header_id
order by m.header_id;

TYPE numlistTAB IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE datelistTAB IS TABLE OF date INDEX BY BINARY_INTEGER;
TYPE chrlistTAB IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;

l_hdrlistTAB         numlistTAB;
l_hdrbegindateTAB    datelistTAB;
l_om_statusTAB       chrlistTAB;
l_wf_statusTAB       chrlistTAB;
l_om_pct_listTAB     numlistTAB;
l_wf_pct_listTAB     numlistTAB;
l_wias_impactTAB     numlistTAB;
l_wiash_impactTAB    numlistTAB;

wf_complete_count number:=0;
om_complete_count number:=0;
total_lines_count number:=0;
wf_pct_done       number:=0;
om_pct_done       number:=0;
incomplete_line_statuses varchar2(4000) ;
wias_impact_total number:=0;
wiash_impact_total number:=0;

batchsize         number:= 100;
j   number:=0;
prev_hdr          number;
prev_hdr_begin_date          date;

-- aggregate plsql information variables
l_unq_hdrTAB         numlistTAB;
l_unq_hdrbegindateTAB    datelistTAB;
l_unq_om_pctTAB         numlistTAB;
l_unq_wf_pctTAB         numlistTAB;
l_unq_wias_impactTAB         numlistTAB;
l_unq_wiash_impactTAB         numlistTAB;
l_unq_incmp_statusTAB chrlistTAB;

begin

 dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || ' opening get_all_lines_info');
 
 -- first retreive all the information from the master table
 open get_all_lines_info;
 fetch get_all_lines_info bulk collect into l_hdrlistTAB, 
                                            l_hdrbegindateTAB,
                                            l_om_statusTAB, 
                                            l_wf_statusTAB, 
                                            l_wias_impactTAB, 
                                            l_wiash_impactTAB;
 close get_all_lines_info;

 dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || ' Started processing for ' || l_hdrlistTAB.count || ' lines');

 if l_hdrlistTAB.count > 0 then
   prev_hdr:=l_hdrlistTAB(1);
   prev_hdr_begin_date:=l_hdrbegindateTAB(1);
   j:=0;
 else 
   dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || ' no information to process!! ');
   return;
 end if;

 -- now process one row at a time, assuming that the information is sorted as per order number
 FOR i IN l_hdrlistTAB.FIRST..l_hdrlistTAB.LAST 
 LOOP
   -- if this is a new order, then reset all counters
   if l_hdrlistTAB(i) != prev_hdr 
   then
     j:=j+1;
    
     l_unq_hdrTAB(j):=prev_hdr;
     l_unq_hdrbegindateTAB(j):=prev_hdr_begin_date;
     l_unq_wf_pctTAB(j):=(wf_complete_count/total_lines_count)*100;
     l_unq_om_pctTAB(j):=(om_complete_count/total_lines_count)*100;
     l_unq_incmp_statusTAB(j):=incomplete_line_statuses;
     l_unq_wias_impactTAB(j):=wias_impact_total;
     l_unq_wiash_impactTAB(j):=wiash_impact_total;
     
     wf_complete_count:=0;
     om_complete_count:=0;
     total_lines_count:=0;
     wias_impact_total:=0;
     wiash_impact_total:=0;
     incomplete_line_statuses:=NULL;

     prev_hdr:=l_hdrlistTAB(i);
     prev_hdr_begin_date:=l_hdrbegindateTAB(i);

   end if;

   -- process wf completion information
   if l_wf_statusTAB(i) = 'COMPLETED' 
   then
     wf_complete_count:=wf_complete_count+1;  
   end if; 

   -- process om completion information
   if l_om_statusTAB(i) = 'COMPLETED' 
   then
     om_complete_count:=om_complete_count+1;  
   else
     if (nvl(instr(incomplete_line_statuses,l_om_statusTAB(i)),0) = 0)
     then
        incomplete_line_statuses:=ltrim(incomplete_line_statuses|| ' ') || l_om_statusTAB(i);
     end if;
   end if; 

   total_lines_count:=total_lines_count+1;   
   wias_impact_total:=wias_impact_total+l_wias_impactTAB(i);
   wiash_impact_total:=wiash_impact_total+l_wiash_impactTAB(i);

   --dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || ' did # ' || i );

 END LOOP;  

 j:=j+1;
    
 l_unq_hdrTAB(j):=prev_hdr;
 l_unq_hdrbegindateTAB(j):=prev_hdr_begin_date;
 l_unq_om_pctTAB(j):=(om_complete_count/total_lines_count)*100;
 l_unq_wf_pctTAB(j):=(wf_complete_count/total_lines_count)*100;
 l_unq_incmp_statusTAB(j):=incomplete_line_statuses;
 l_unq_wias_impactTAB(j):=wias_impact_total;
 l_unq_wiash_impactTAB(j):=wiash_impact_total;

  --
  -- Perform a bulk insert now 
  -- this was chosen due to performance reasons
  --
  FORALL j IN l_unq_hdrTAB.FIRST..l_unq_hdrTAB.LAST
   insert into unique_orders(header_id, 
                             om_begin_date,
                             OM_PERCENT_CLOSED, 
			     wf_percent_closed, 
			     incomplete_line_status, 
			     wias_impact_total, 
			     wiash_impact_total
			    )
		      values(l_unq_hdrTAB(j),
                             l_unq_hdrbegindateTAB(j),
			     l_unq_om_pctTAB(j),
			     l_unq_wf_pctTAB(j),
			     l_unq_incmp_statusTAB(j),
			     l_unq_wias_impactTAB(j),
			     l_unq_wiash_impactTAB(j)
			    );  
  COMMIT;

   dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || 'Ended processing for ' || l_hdrlistTAB.count || ' line');
   dbms_output.put_line(to_char(sysdate,'dd-mon-rr hh24:mi') || 'Total Unique orders processed: ' || j);

exception 
when others then
   dbms_output.put_line('error while processing ' || sqlerrm);
   if (get_all_lines_info%isopen) then close get_all_lines_info; end if;
   rollback;
end;
/
exit
/
