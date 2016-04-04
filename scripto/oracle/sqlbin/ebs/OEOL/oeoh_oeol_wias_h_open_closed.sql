set time on timing on echo off pages 10000;
set verify off head off;
set linesize 200 ;

column ITEM_type     format   a10;
column ITEM_KEY     format    a15;
column parent_ITEM_type     format   a10;
column parent_ITEM_KEY     format    a15;
column HISTORY      format    a07;
column STATEMENT    format    a51;
column ITEM_TYPE    format    a05;
column DISPLAY_NAME format    a80;
column AVG_LIFE     format    9999.99;
column MIN_LIFE     format    9999.99;
column MAX_LIFE     format    9999.99;
column DEV          format    9999.99;
column P_DAYS       format    99999;
column END_DATE     format    a10;
column header_END_DATE     format    a10;
column line_END_DATE     format    a10;
column BEGIN_DATE   format    a10;
column header_BEGIN_DATE   format    a10;
column line_BEGIN_DATE   format    a10;
column root  format    a30;
column flow_status_code format    a25;
column where_flow format    a80;
column order_number format    999999999;
column wias_impact format     999999999;
column wiash_impact format    999999999;
column header_id    format    99999999;

rem set timing on time on 

spool oeoh_oeol_wias_h_open_closed.lst
select oh.order_number, 
       oh.flow_status_code,
       wf_line.parent_item_type,
       wf_line.parent_item_key,
       nvl(to_char(wf_header.begin_date),'PURGED') header_begin_date,
       nvl(to_char(wf_header.end_date),'NULL') header_end_date,
       sta.item_type       ITEM_TYPE, 
       sta.item_key        ITEM_KEY, 
       ol.flow_status_code ,
       wf_line.begin_date line_begin_date,
       nvl(to_char(wf_line.end_date),'NULL') line_end_date,
       count(1)            WIASH_IMPACT
from oe_order_headers_all oh,
     oe_order_lines_all ol,
     wf_items wf_header,
     wf_items wf_line,
     wf_item_activity_statuses_h sta
where sta.item_type = 'OEOL'
  and sta.item_key  = ol.line_id
  and ol.header_id=oh.header_id
  --
  --
  -- the outer join had to be put to accomodate the case of a purged OEOH wf item
  -- otherwise, what was happening was that the corresponding OEOL record was not getting selected
  -- leading to missing information and a mismatch with wf_item_activity_statuses
  --
  --
  and wf_line.parent_item_type=wf_header.item_type(+)
  and wf_line.parent_item_key=wf_header.item_key(+)
  --
  --
  and wf_line.item_type='OEOL'
  and wf_line.item_key=to_char(ol.line_id)
group by oh.order_number, 
         oh.flow_status_code,
         wf_line.parent_item_type,
         wf_line.parent_item_key,
         nvl(to_char(wf_header.begin_date),'PURGED') ,
         nvl(to_char(wf_header.end_date),'NULL') ,
         sta.item_type       ,
         sta.item_key        ,
         ol.flow_status_code ,
         wf_line.begin_date ,
         nvl(to_char(wf_line.end_date),'NULL') 
having count(1) > 0
order by count(1) desc;
spool off
quit
