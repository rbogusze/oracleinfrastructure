-- oracle 11.2
PROMPT Display top-level call names matching %&1% (Oracle 11.2+)
SELECT
    *
FROM 
    v$toplevelcall
WHERE
    UPPER(top_level_call_name) LIKE UPPER('%&1%')
/

