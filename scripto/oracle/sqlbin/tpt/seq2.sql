select * from dba_sequences 
where
    upper(sequence_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND sequence_owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
/

