col ol_sql_text head SQL_TEXT for a80 word_wrap

select
    owner
  , name
  , category
  , used
  , enabled
  , sql_text     ol_sql_text
from
    dba_outlines
where
    lower(owner) like lower('&1')
and lower(name)  like lower('&2')
/

