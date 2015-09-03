-- hack but ain't working 

CREATE OR REPLACE FUNCTION f 
    RETURN sys.dbms_debug_vc2coll PIPELINED
AS
BEGIN
    FOR i IN 1..3 LOOP
        FOR r IN (
            --SELECT USERENV('Instance')||','||TO_CHAR(sid)||','||TO_CHAR(serial#)||','||sql_id||','||state||','||event  val
            --FROM v$session
            --WHERE status = 'ACTIVE' AND type = 'USER'
            WITH sq AS (SELECT /*+ NO_MERGE MATERIALIZE */ * FROM v$instance) SELECT TO_CHAR(instance_number)||' '||host_name val FROM sq
        ) LOOP
            PIPE ROW (r.val);
        END LOOP;
        DBMS_LOCK.SLEEP(1);
    END LOOP;
END;
/

SHOW ERR;

