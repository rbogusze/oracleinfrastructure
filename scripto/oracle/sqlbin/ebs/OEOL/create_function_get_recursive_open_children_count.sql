-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- This script creates  the function for getting a count of ((great)..grand) child workflow items for
-- a particular item_key and item_type
-- =====================================================================================================

create or replace function get_rec_open_child_count(itemtype varchar2, itemkey varchar2)
return number
is
 open_child_wf_items number;
begin

   select count(1) --wi2.item_type, wi2.item_key
   into open_child_wf_items
   from WF_ITEMS WI2
   WHERE WI2.END_DATE IS NULL
   START WITH WI2.ITEM_TYPE = itemtype
   AND WI2.ITEM_KEY = itemkey
   CONNECT BY PRIOR WI2.ITEM_TYPE = WI2.PARENT_ITEM_TYPE
   AND PRIOR WI2.ITEM_KEY = WI2.PARENT_ITEM_KEY;
   
   return open_child_wf_items;

exception 
  when  others 
  then
    return 0;
end;
/

