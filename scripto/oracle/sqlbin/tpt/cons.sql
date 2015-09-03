column cons_column_name heading COLUMN_NAME format a30
column cons_owner heading OWNER format A30

prompt Show constraints on table &1....

select
     co.owner cons_owner,
     co.table_name,
     co.constraint_name,
     co.constraint_type,
     co.r_constraint_name,
     cc.column_name          cons_column_name,
     cc.position,
     co.status,
     co.validated
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and upper(co.table_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND co.owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
order by
     cons_owner,
     table_name,
     constraint_type,
     constraint_name,
     position,
     column_name
/

