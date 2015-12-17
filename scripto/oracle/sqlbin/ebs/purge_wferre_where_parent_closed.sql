DECLARE 
CURSOR Ab_wf IS 
SELECT /*+ FULL(a) parallel(a,8) */ item_key
FROM wf_items a
WHERE item_type = 'WFERROR' and parent_item_key in (select /*+ FULL(b) parallel(b,8) */ item_key from wf_items b where end_date is not NULL) ;

counter number(4) default 0;

BEGIN 
FOR i IN Ab_wf LOOP 
WF_ENGINE.abortProcess('WFERROR', i.item_key); 

counter := counter + 1 ;
   
If counter >= 50 then
  counter := 0;
  commit;
end if;

END LOOP; 

COMMIT; 
END; 
