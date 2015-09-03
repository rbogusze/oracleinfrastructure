col view_name for a30
col text for a100 word_wrap

prompt Show SQL text of views matching "&1"...

select view_name, text from dba_views where upper(view_name) like upper('&1');
select view_name, view_definition text from v$fixed_View_definition where upper(view_name) like upper('&1');

