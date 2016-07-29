select * from v$instance;
SELECT * FROM all_mviews;
SELECT * FROM all_mviews WHERE mview_name LIKE 'XX_%_MV';

column MVIEW_NAME format a30
set linesize 200

SELECT mview_name,
  update_log,
  refresh_mode,
  refresh_method,
  build_mode,
  fast_refreshable,
  last_refresh_type
FROM all_mviews
WHERE mview_name LIKE 'XX_%_MV' order by mview_name;
--WHERE mview_name LIKE 'WF_%_MV' order by mview_name;


--check for any existing materialized view logs
SELECT * FROM dba_mview_logs;


SELECT COUNT(*) FROM XX_PO_LINE_LOCATIONS_ALL_MV;

select dbms_metadata.get_ddl('MATERIALIZED_VIEW', 'XX_PO_LINE_LOCATIONS_ALL_MV') from dual;
"
  CREATE MATERIALIZED VIEW "APPS"."XX_PO_LINE_LOCATIONS_ALL_MV" ("LINE_LOCATION_ID", "PO_HEADER_ID", "PO_LINE_ID", "PO_RELEASE_ID", "SHIPMENT_NUM", "QUANTITY", "QUANTITY_RECEIVED", "QUANTITY_BILLED", "QUANTITY_ACCEPTED", "CLOSED_CODE", "LAST_UPDATE_DATE")
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 1048576 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "APPS_TS_TX_DATA" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND START WITH sysdate+0 NEXT SYSDATE+1/96
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE QUERY REWRITE
  AS SELECT "A1"."LINE_LOCATION_ID" "LINE_LOCATION_ID","A1"."PO_HEADER_ID" "PO_HEADER_ID","A1"."PO_LINE_ID" "PO_LINE_ID","A1"."PO_RELEASE_ID" "PO_RELEASE_ID","A1"."SHIPMENT_NUM" "SHIPMENT_NUM","A1"."QUANTITY" "QUANTITY","A1"."QUANTITY_RECEIVED" "QUANTITY_RECEIVED","A1"."QUANTITY_BILLED" "QUANTITY_BILLED","A1"."QUANTITY_ACCEPTED" "QUANTITY_ACCEPTED","A1"."CLOSED_CODE" "CLOSED_CODE","A1"."LAST_UPDATE_DATE" "LAST_UPDATE_DATE" FROM "PO"."PO_LINE_LOCATIONS_ALL" "A1";"


SELECT mview_name,
  update_log,
  refresh_mode,
  refresh_method,
  build_mode,
  fast_refreshable,
  last_refresh_type
FROM all_mviews
WHERE mview_name in ('XX_PO_LINE_LOCATIONS_ALL_MV','XX_AP_INVOICES_ALL_MV','XX_PO_RELEASES_ALL_MV','XX_AP_BANK_MV') order by mview_name;

SELECT mview_name,
  update_log,
  refresh_mode,
  refresh_method,
  build_mode,
  fast_refreshable,
  last_refresh_type
FROM all_mviews
WHERE mview_name LIKE 'XX_%_MV' 
and last_refresh_type = 'COMPLETE'
order by mview_name;

--check the jobs that refresh MV
select * from dba_jobs where what like '%dbms_refresh%XX_%';
select job,interval, what from dba_jobs where what like '%dbms_refresh%XX_%';

--is any job running now
select /*+ RULE */ sid,job from dba_jobs_running;



