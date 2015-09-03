SELECT
    *
FROM
    dba_hist_sqltext
WHERE
    sql_id = '&1'
/
