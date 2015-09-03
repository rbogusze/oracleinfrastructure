SELECT
    TRUNC(timestamp#,'MI') minute
  , userid
  , userhost
  , COUNT(*)
FROM
    sys.aud$
WHERE
    timestamp# BETWEEN TO_DATE('20101030 18:00', 'YYYYMMDD HH24:MI')
                   AND TO_DATE('20101030 19:00', 'YYYYMMDD HH24:MI')
GROUP BY
    TRUNC(timestamp#,'MI') --minute
  , userid
  , userhost
ORDER BY
    minute
  , userid
  , userhost
/

