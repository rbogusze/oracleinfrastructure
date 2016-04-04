-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- This script creates the function for getting a recursive count of ((great)..grand) parent 
-- workflow items.
-- =====================================================================================================

create or replace function get_rec_open_parent_count(itemtype varchar2, itemkey varchar2)
return number
is
 open_parent_wf_items number;
begin

   select count(1) --wi2.item_type, wi2.item_key
   into open_parent_wf_items
   from WF_ITEMS WI2
   WHERE WI2.END_DATE IS NULL
   START WITH WI2.ITEM_TYPE = itemtype
   AND WI2.ITEM_KEY = itemkey
   CONNECT BY PRIOR WI2.PARENT_ITEM_TYPE = WI2.ITEM_TYPE
   AND PRIOR WI2.PARENT_ITEM_KEY = WI2.ITEM_KEY;
   
   return open_parent_wf_items;

exception 
  when  others 
  then
    return 0;
end;
/
