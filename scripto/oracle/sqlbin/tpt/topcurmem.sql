SELECT * FROM (
    SELECT
        sharable_mem, sql_id, hash_value, SUBSTR(sql_text,1,100) sql_text_partial
    FROM
        v$sql
    ORDER BY
        sharable_mem DESC
)
WHERE rownum <= 20
/

