DECLARE
    cmd VARCHAR2(1000);
BEGIN
    FOR i IN (SELECT owner,index_name FROM dba_indexes WHERE table_owner = '&1' AND table_owner NOT IN('SYS', 'SYSTEM')) LOOP
        cmd := 'ALTER INDEX '||i.owner||'.'||i.index_name||' VISIBLE';
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd;
    END LOOP;
END;
/

