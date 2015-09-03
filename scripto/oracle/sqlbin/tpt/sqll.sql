col sqll_sql_text head SQL_TEXT word_wrap

select sql_text sqll_sql_text from v$sqltext where hash_value = &1 order by piece;