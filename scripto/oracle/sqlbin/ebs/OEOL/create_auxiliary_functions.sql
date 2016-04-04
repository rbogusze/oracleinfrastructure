prompt =================================================================================================
prompt Created gverma - 22nd feb 2007
prompt
prompt This script creates some supporting functions which are used in the analytic reports
prompt
prompt =================================================================================================

define location=&1
prompt
prompt Running create_function_get_recursive_open_children_count.sql now
prompt
@&&location./create_function_get_recursive_open_children_count.sql  

prompt
prompt Running create_function_get_recursive_open_parent_count.sql now
prompt
@&&location./create_function_get_recursive_open_parent_count.sql    

prompt
prompt Running create_function_range.sql now
prompt
@&&location./create_function_range.sql                             

exit
/
